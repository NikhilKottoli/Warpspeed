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
import 'package:dart_rss/dart_rss.dart';
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
  List<Map<String, String>> newsList = [];
  bool isLoadingNews = true;
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  String? recordedFilePath;
  String selectedLanguageCode = 'en-IN';


  List<Map<String, String>> supportedLanguages = [
    {'label': 'English', 'code': 'en-IN'},
    {'label': 'Hindi', 'code': 'hi-IN'},
    {'label': 'Bengali', 'code': 'bn-IN'},
    {'label': 'Telugu', 'code': 'te-IN'},
    {'label': 'Marathi', 'code': 'mr-IN'},
    {'label': 'Tamil', 'code': 'ta-IN'},
    {'label': 'Urdu', 'code': 'ur-IN'},
    {'label': 'Gujarati', 'code': 'gu-IN'},
    {'label': 'Kannada', 'code': 'kn-IN'},
    {'label': 'Odia', 'code': 'or-IN'},
    {'label': 'Malayalam', 'code': 'ml-IN'},
    {'label': 'Punjabi', 'code': 'pa-IN'},
    {'label': 'Assamese', 'code': 'as-IN'},
    {'label': 'Maithili', 'code': 'mai-IN'},
    {'label': 'Santali', 'code': 'sat-IN'},
    {'label': 'Konkani', 'code': 'kok-IN'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    fetchAgriNews();
  }

  Future<void> _initializeRecorder() async {
    await Permission.microphone.request();
    await Permission.storage.request();
    await _recorder.openRecorder();
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
    final directory = await getTemporaryDirectory();
    return '${directory.path}/recorded_audio.wav';
  }

  Future<void> fetchAgriNews() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.thehindu.com/sci-tech/agriculture/feeder/default.rss'));

      if (response.statusCode == 200) {
        final feed = RssFeed.parse(response.body);


        final items = feed.items;

        List<String> textsToTranslate = [];
        List<Map<String, String>> limitedNewsItems = [];
        int charCount = 0;
        for (var item in items) {
          final title = item.title ?? '';
          final summary = item.description ?? '';
          final combined = "$title\n\n$summary";

          textsToTranslate.add(item.title ?? '');
          textsToTranslate.add(item.description ?? '');
          limitedNewsItems.add({'title': title, 'summary': summary});
          charCount += combined.length;
        }
        final translatedTexts = textsToTranslate;
        List<Map<String, String>> translatedNews = [];
        for (int i = 0; i < translatedTexts.length; i += 2) {
          translatedNews.add({
            'title': translatedTexts[i],
            'summary': translatedTexts[i + 1],
          });
        }
        print(translatedNews);
        setState(() {
          newsList = translatedNews;
          isLoadingNews = false;
        });
      } else {
        setState(() {
          isLoadingNews = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingNews = false;
      });
    }
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
  Future<String> translateText(String input, String targetLangCode) async {
    final uri = Uri.parse('https://api.sarvam.ai/translate');

    final response = await http.post(
      uri,
      headers: {
        'api-subscription-key': 'sk_vyja2u8y_8V8D4I7wA0f0iok2awYT9pqV',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'input': input,
        'source_language_code': 'auto',
        'target_language_code': targetLangCode,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['translated_text'] as String ;
    } else {
      print("Translation error: ${response.body}");
      return input; // fallback to original text
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Krishi Sathi AI',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1), // matches card transparency
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedLanguageCode,
                      icon: const Icon(Icons.language, color: Colors.white),
                      dropdownColor: const Color(0xFF0083B0), // blue dropdown
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      onChanged: (String? newCode) async {
                        if (newCode != null) {
                          print(newCode);
                          setState(() {
                            selectedLanguageCode = newCode;
                            isLoadingNews = true;
                          });

                        }
                      },
                      items: supportedLanguages.map((lang) {
                        return DropdownMenuItem<String>(
                          value: lang['code'],
                          child: Text(lang['label'] ?? ''),
                        );
                      }).toList(),
                    ),
                  ),
                )
              )
          ],
            centerTitle: true,
          ),
        ),
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
                          border:
                              Border.all(color: Colors.white.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Card content
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal:20),
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
                            ),

                            // Top-right sound button
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.volume_up,
                                    color: Colors.white),
                                onPressed: () async {
                                  final fullText =
                                      '${news['title']}. ${news['summary']}';
                                  final translated = await translateText(fullText, selectedLanguageCode);



                                  final uri = Uri.parse('https://api.sarvam.ai/text-to-speech');
                                  final response2 = await http.post(
                                    uri,
                                    headers: {
                                      'api-subscription-key': 'sk_vyja2u8y_8V8D4I7wA0f0iok2awYT9pqV', // Replace with actual key
                                      'Content-Type': 'application/json',
                                    },
                                    body: jsonEncode({
                                      'text': translated,
                                      'target_language_code': selectedLanguageCode,
                                    }),
                                  );
                                  print(response2.body);
                                  final data2 = jsonDecode(response2.body);
                                  final base64Audio = data2['audios'][0]; // Your string
                                  await playBase64Audio(base64Audio);
                                },
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
