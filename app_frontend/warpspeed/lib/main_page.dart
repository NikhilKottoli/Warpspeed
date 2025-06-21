import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http_parser/http_parser.dart';
import 'voice_screen.dart';
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
  final List<Map<String, String>> newsList = [
    {
      'title': 'बारिश की चेतावनी: अगले 24 घंटे में भारी बारिश की संभावना',
      'summary': 'मौसम विभाग ने किसानों को अगले दो दिनों के लिए सावधानी बरतने की सलाह दी है।',
    },
    {
      'title': 'गेहूं का न्यूनतम समर्थन मूल्य बढ़ा',
      'summary': 'सरकार ने इस सीजन गेहूं का MSP ₹100 प्रति क्विंटल बढ़ा दिया है।',
    },
    {
      'title': 'नई किसान बीमा योजना शुरू',
      'summary': 'सरकार ने प्राकृतिक आपदाओं से सुरक्षा के लिए नई बीमा योजना लागू की है।',
    },
  ];
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
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Krishi Sathi AI'),
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Section
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundImage: AssetImage('assets/profile.jpg'),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Hello, Farmer!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Welcome to your smart assistant',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Section Title
                const Text(
                  '🌾 Agriculture News',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // News Cards
                Expanded(
                  child: ListView.builder(
                    itemCount: newsList.length,
                    itemBuilder: (context, index) {
                      final news = newsList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              news['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              news['summary'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Voice Agent Button

              ],
            ),
          ),
        ),
      ),
    );
  }

  }