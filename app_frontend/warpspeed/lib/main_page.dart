import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http_parser/http_parser.dart';

class VoiceAgentPage extends StatefulWidget {
  const VoiceAgentPage({super.key});

  @override
  State<VoiceAgentPage> createState() => _VoiceAgentPageState();
}

class _VoiceAgentPageState extends State<VoiceAgentPage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  bool isRecording = false;
  String statusMessage = '';
  String serverResponse = '';

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await Permission.microphone.request();
    await Permission.storage.request();
    await _recorder.openRecorder();
  }

  Future<String> _getTempWavPath() async {
    final directory = await getTemporaryDirectory();
    return '${directory.path}/recorded_audio.wav';
  }

  Future<void> _startRecording() async {
    final filePath = await _getTempWavPath();

    await _recorder.startRecorder(
      toFile: filePath,
      codec: Codec.pcm16WAV,
    );

    setState(() {
      isRecording = true;
      statusMessage = 'Recording...';
      serverResponse = '';
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stopRecorder();

    setState(() {
      isRecording = false;
      statusMessage = 'Uploading...';
    });

    if (path != null) {
      await _uploadAudio(File(path));
    } else {
      setState(() => statusMessage = 'Recording failed');
    }
  }

  Future<void> _uploadAudio(File audioFile) async {
    try {
      final uri = Uri.parse('http://localhost:3000/audio/process');

      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          audioFile.path,
          contentType: MediaType('audio', 'wav'),
        ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          serverResponse = data['text'] ?? 'No response text';
          statusMessage = 'Success';
        });
      } else {
        setState(() => statusMessage = 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => statusMessage = 'Upload error: $e');
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Voice Agent'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isRecording)
                  const SpinKitWave(
                    color: Colors.white,
                    size: 40.0,
                  ),
                const SizedBox(height: 30),

                // Glassmorphism card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Response:",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        serverResponse.isNotEmpty ? serverResponse : '---',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Glowing mic button
                GestureDetector(
                  onTap: isRecording ? _stopRecording : _startRecording,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRecording ? Colors.redAccent : Colors.white,
                      boxShadow: isRecording
                          ? [
                        BoxShadow(
                          color: Colors.redAccent.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ]
                          : [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.4),
                          blurRadius: 10,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Icon(
                      isRecording ? Icons.stop : Icons.mic,
                      size: 40,
                      color: isRecording ? Colors.white : Colors.blueAccent,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Status message
                if (statusMessage.isNotEmpty)
                  Text(
                    statusMessage,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
