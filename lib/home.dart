// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signbridge/requests.dart';

import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';

import 'package:avatar_glow/avatar_glow.dart';
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
  bool pressed = false;
  Uint8List? imgdata;
  String selectedId = "";

  @override
  void initState() {
    super.initState();
    initSpeech();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      IdSelectionDialog();
    });
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

  Future<void> IdSelectionDialog() async {
    selectedId = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Select voice input language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('English'),
                  onTap: () {
                    Navigator.of(context).pop('en_US');
                  },
                ),
                ListTile(
                  title: const Text('Hindi'),
                  onTap: () {
                    Navigator.of(context).pop('hi');
                  },
                ),
                ListTile(
                  title: const Text('Kannada'),
                  onTap: () {
                    Navigator.of(context).pop('kn');
                  },
                )
              ],
            ),
          );
        });
  }

  @override
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
                  style: const TextStyle(color: Colors.black),
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
                            localeId: selectedId);
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
                      decoration: const BoxDecoration(
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
              child: FutureBuilder(
            future: getSign(words),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return const CircularProgressIndicator(
                  color: Colors.white,
                );
              } else {
                return Image.network(
                    'https://bipinkrish-signbridge.hf.space/sign2img?sign=${snapshot.data}');
              }
            },
          )),
        ),
      ),
    );
  }
}

/*child: !pressed
                  ? ElevatedButton(
                      onPressed: () async {
                        pressed = true;
                        setState(() {});
                        poseToGif();
                      },
                      child: const Text('Demo'),
                    )
                  : imgdata != null
                      ? Center(
                          child: Image.memory(
                            imgdata!,
                          ),
                        )
                      : const CircularProgressIndicator(),*/
