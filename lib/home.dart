import 'dart:io';
import 'dart:typed_data';
import 'package:pose/pose.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var isListening = false;
  final SpeechToText v2t = SpeechToText();
  final GoogleTranslator translator = GoogleTranslator();
  bool speechEnabled = false;
  String recogWords = "";
  String words = "";

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    speechEnabled = await v2t.initialize();
    setState(() {});
  }

  void translateText() async {
    if (recogWords.isNotEmpty) {
      Translation translation =
          await translator.translate(recogWords, to: 'en');
      setState(() {
        words = translation.text;
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Bridge'),
      ),
      body: SlidingUpPanel(
        minHeight: 60,
        maxHeight: 500, //MediaQuery.of(context).size.height * 0.5,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        panel: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: const TextField(
                  maxLines: 10,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Enter your text here...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  words,
                  style: TextStyle(color: Colors.black),
                ),
              ), // This is an empty container to fill the remaining space
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AvatarGlow(
                  glowColor: Colors.blue,
                  animate: isListening,
                  duration: const Duration(milliseconds: 2000),
                  repeat: true,
                  child: GestureDetector(
                    onTapDown: (details) {
                      setState(() {
                        isListening = true;
                      });
                      if (speechEnabled) {
                        v2t.listen(
                          onResult: (result) {
                            setState(() {
                              //words = result.recognizedWords;
                              recogWords = result.recognizedWords;
                            });
                          },
                          localeId: 'hi'
                        );
                        translateText();
                      }
                    },
                    onTapUp: (details) {
                      setState(() {
                        isListening = false;
                      });
                      v2t.stop();
                      //translateText();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.blue, shape: BoxShape.circle),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Icon(
                          isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
          ),
          child: Center(
            child: Image.asset('assets/gif/demo.gif',width: 300,height: 500,)
          ),
        ),
      ),
    );
  }
}

/*import 'dart:io';
import 'dart:typed_data';
import 'package:pose/pose.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  final SpeechToText v2t = SpeechToText();
  final GoogleTranslator translator = GoogleTranslator();

  bool speechEnabled = false;
  String recogWords = "";
  String words = "";

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    speechEnabled = await v2t.initialize();
    setState(() {});
  }

  void startListening() async {
    await v2t.listen(onResult: onSpeechResult,localeId:'hi'); 
    setState(() {});
  }

  void stopListening() async {
    await v2t.stop();
    setState(() {});
    translateText();
  }

  void onSpeechResult(result) {
    setState(() {
      //words = "${result.recognizedWords}";
      recogWords = "${result.recognizedWords}";
    });
  }

  void translateText() async {
    if (recogWords.isNotEmpty) {
      Translation translation =
          await translator.translate(recogWords, to: 'en');
      setState(() {
        words = translation.text;
      });
    }
  }

Future<void> poseToGif() async {
  File file = File("assets/pose/sample.pose");
  Uint8List fileContent = file.readAsBytesSync();
  Pose pose = Pose.read(fileContent);
  PoseVisualizer p = PoseVisualizer(pose);
  p.saveGif("assets/gif/sample.gif", p.draw());
} 

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Bridge'),
      ),
      body: Column(
        children: [
          // Top 3/4th - Display Box
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey, 
              ),
              // use a GIF display widget here
              child: Center(
                child: Image.asset('assets/gif/demo.gif',width: 300,height: 500,)
              ),
            ),
          ),
          // Bottom 1/4th - Text Box
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    child: Text(words),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      //IconButton(onPressed: () {}, icon: const Icon(Icons.mic)),
                      FloatingActionButton(
                        onPressed:
                            v2t.isListening ? stopListening : startListening,
                        tooltip: "Listen",
                        child: Icon(
                            v2t.isNotListening ? Icons.mic_off : Icons.mic),
                      ),
                      IconButton(onPressed: poseToGif, icon: const Icon(Icons.send))
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/
