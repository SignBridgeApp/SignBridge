import 'package:flutter/material.dart';
import 'package:signbridge/constants.dart';
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
  bool isListening = false;
  final SpeechToText v2t = SpeechToText();
  final GoogleTranslator translator = GoogleTranslator();
  bool speechEnabled = false;
  String selectedId = "en_US";
  String translatedText = "";
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    speechEnabled = await v2t.initialize();
    refresh();
  }

  void translateText() async {
    if (textController.text.isNotEmpty) {
      if (selectedId == "en_US") {
        translatedText = textController.text;
      } else {
        Translation translation =
            await translator.translate(textController.text, to: 'en');
        translatedText = translation.text;
      }
    }
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: black,
      body: Stack(
        children: [
          SlidingUpPanel(
            minHeight: height * 0.25,
            maxHeight: height * 0.40,
            color: black,
            boxShadow: const [BoxShadow(blurRadius: 1.0, color: silver)],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
            panel: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    controller: textController,
                    style: const TextStyle(
                      color: grey,
                      fontSize: 24,
                    ),
                    autocorrect: true,
                    showCursor: true,
                    cursorColor: silver,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Talk or type',
                      border: InputBorder.none,
                      hintStyle: const TextStyle(color: grey),
                      suffixIcon: textController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: grey,
                              ),
                              onPressed: () {
                                textController.clear();
                                refresh();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                FutureBuilder(
                    future: getGloss(translatedText),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.data == null) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: silver,
                          ),
                        );
                      } else {
                        return Center(
                          child: Text(
                            snapshot.data,
                            style: TextStyle(color: grey, fontSize: 24),
                          ));
                      }
                    })
              ],
            ),
            body: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: FutureBuilder(
                  future: getSign(translatedText),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.data == null) {
                      return const CircularProgressIndicator(
                        color: silver,
                      );
                    } else {
                      return Image.network(
                        '$sign2imgURL?sign=${snapshot.data}&line_color=224,231,241,255',
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AvatarGlow(
                glowColor: lightblue,
                animate: isListening,
                duration: const Duration(milliseconds: 1500),
                repeat: true,
                glowShape: BoxShape.circle,
                child: GestureDetector(
                  onTap: () {
                    isListening = !isListening;
                    if (isListening) {
                      if (speechEnabled) {
                        v2t.listen(
                          onResult: (result) {
                            textController.text = result.recognizedWords;
                          },
                          localeId: selectedId,
                        );
                      }
                    } else {
                      v2t.stop();
                    }
                    translateText();
                    refresh();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: blue,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        isListening ? Icons.mic : Icons.mic_none,
                        color: silver,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: blue,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  onPressed: () {
                    _showOptionsDialog(context);
                  },
                  child: Text(
                    langs[selectedId]!,
                    style: const TextStyle(
                      color: silver,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (selectedId != "en_US" && translatedText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  translatedText,
                  style: const TextStyle(
                    color: grey,
                    fontSize: 24,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  Future<void> _showOptionsDialog(BuildContext context) async {
    String? selectedOption = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: grey,
            fontSize: 24,
          ),
          title: const Text('Select a language'),
          content: SingleChildScrollView(
            child: ListBody(
              children: langs.keys.map((String key) {
                return ListTile(
                  title: Text(langs[key]!),
                  onTap: () {
                    Navigator.of(context).pop(key);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selectedOption != null) {
      selectedId = selectedOption;
      refresh();
    }
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }
}
