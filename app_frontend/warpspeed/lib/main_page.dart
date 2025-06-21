import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class VoiceAgentPage extends StatefulWidget {
  const VoiceAgentPage({super.key});

  @override
  _VoiceAgentPageState createState() => _VoiceAgentPageState();
}

class _VoiceAgentPageState extends State<VoiceAgentPage> with SingleTickerProviderStateMixin {
  bool isListening = false;
  String recognizedText = '';
  String responseStatus = '';
  final SpeechToText _speech = SpeechToText();
  final AudioPlayer _player = AudioPlayer();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
  }

  Future<void> startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(
        onResult: (result) {
          setState(() {
            recognizedText = result.recognizedWords;
          });
        },
      );
    } else {
      setState(() => responseStatus = 'Speech recognition not available');
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
    if (recognizedText.isNotEmpty) {
      sendToBackend(recognizedText);
    } else {
      setState(() => responseStatus = 'No input detected');
    }
  }

  Future<void> sendToBackend(String text) async {
    setState(() => responseStatus = 'Processing...');

    try {
      final response = await http.post(
        Uri.parse("http://localhost:3000/audio/generate-audio"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': text,
                        'target_language_code' : 'kn-IN'}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final audioUrl = data['audio_url'];

        if (audioUrl != null) {
          setState(() => responseStatus = 'Playing response...');
          await playAudio(audioUrl);
        } else {
          setState(() => responseStatus = 'No audio URL received');
        }
      } else {
        setState(() => responseStatus = 'Error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => responseStatus = 'Error: $e');
    }
  }

  Future<void> playAudio(String url) async {
    try {
      await _player.play(UrlSource(url));
    } catch (e) {
      setState(() => responseStatus = 'Audio playback error: $e');
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _player.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget buildWaveform() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 6,
              height: 20.0 + (_animationController.value * 20 * (index % 2 == 0 ? 1 : 0.5)),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Voice Agent'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isListening) ...[
                buildWaveform(),
                const SizedBox(height: 20),
              ],
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        "You said:",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        recognizedText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: Icon(
                  color: Colors.white,
                    isListening ? Icons.stop_circle_outlined : Icons.mic),
                label: Text(isListening ? "Stop Listening" : "Start Speaking",style: TextStyle(color:Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  backgroundColor: isListening ? Colors.redAccent : Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  setState(() => isListening = !isListening);
                  isListening ? startListening() : stopListening();
                },
              ),
              const SizedBox(height: 30),
              if (responseStatus.contains("Processing") || responseStatus.contains("Playing"))
                const SpinKitThreeBounce(
                  color: Colors.blueAccent,
                  size: 24.0,
                ),
              if (responseStatus.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    responseStatus,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
