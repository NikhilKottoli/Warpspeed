import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http_parser/http_parser.dart';

class VoiceAgentScreen extends StatefulWidget {
  const VoiceAgentScreen({super.key});

  @override
  State<VoiceAgentScreen> createState() => _VoiceAgentScreenState();
}

class _VoiceAgentScreenState extends State<VoiceAgentScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool isRecording = false;
  String statusMessage = '';
  String serverResponse = '';
  String? recordedFilePath;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      setState(() => statusMessage = 'Microphone permission not granted');
    }
  }
  Future<void> playBase64Audio(String base64String) async {
    try {
      // 1. Decode base64 to bytes
      final audioBytes = base64Decode(base64String);

      // 2. Get temp directory and create .wav file
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/tts_output.wav';
      final audioFile = File(filePath);
      await audioFile.writeAsBytes(audioBytes);

      // 3. Initialize and start player
      await _player.openPlayer();
      await _player.startPlayer(fromURI: filePath, codec: Codec.pcm16WAV);

      print("✅ Playing audio...");
    } catch (e) {
      print("❌ Failed to play audio: $e");
    }
  }

  Future<String> _getTempWavPath() async {
    final directory = Directory('/storage/emulated/0/Download');
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
    }
    return '${directory.path}/recorded_audio.wav';
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      setState(() => statusMessage = 'Microphone permission not granted');
      return;
    }

    final path = await _getTempWavPath();
    recordedFilePath = path;

    await _recorder.start(
      RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        bitRate: 256000,
        numChannels: 1,
      ),
      path: path,
    );

    setState(() {
      isRecording = true;
      statusMessage = 'Recording...';
      serverResponse = '';
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();

    setState(() {
      isRecording = false;
      statusMessage = 'Uploading...';
    });

    if (path != null) {
      recordedFilePath = path;
      final file = File(path);
      if (await file.exists()) {
        await _uploadAudio(file);
      } else {
        setState(() => statusMessage = 'Recording file not found');
      }
    } else {
      setState(() => statusMessage = 'Recording failed or canceled');
    }
  }

  Future<void> _uploadAudio(File audioFile) async {
    try {
      var uri = Uri.parse('https://api.sarvam.ai/speech-to-text-translate');
      final request = http.MultipartRequest('POST', uri)
        ..headers['api-subscription-key'] = 'sk_vyja2u8y_8V8D4I7wA0f0iok2awYT9pqV'
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          audioFile.path,
          contentType: MediaType('audio', 'wav'),
        ));


      final response = await http.Response.fromStream(await request.send());
      print(response.body);
      if (response!=null) {
        final data = jsonDecode(response.body);
        setState(() {
          serverResponse = data['transcript'] ?? 'No response text';
          statusMessage = 'Success';
        });
        final text = data['transcript'];
        uri = Uri.parse('http://10.156.104.229:3000/audio/process-speech');
        final response1 = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'text': text,
          }),
        );
        final data1 = jsonDecode(response1.body);
        print(response1.body);
        setState(() {
          serverResponse = data1['aiResponse'] ?? 'No response text';
          statusMessage = 'Success';
        });
        uri = Uri.parse('https://api.sarvam.ai/text-to-speech');
        final response2 = await http.post(
          uri,
          headers: {
            'api-subscription-key': 'sk_vyja2u8y_8V8D4I7wA0f0iok2awYT9pqV', // Replace with actual key
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'text': data1['aiResponse'],
            'target_language_code': 'en-IN',
          }),
        );
        print(response2.body);
        final data2 = jsonDecode(response2.body);
        final base64Audio = data2['audios'][0]; // Your string
        await playBase64Audio(base64Audio);




      } else {
        setState(() => statusMessage = 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => statusMessage = 'Upload error: $e');
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

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
