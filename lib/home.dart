import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translator/translator.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:signbridge/constants.dart';
import 'package:signbridge/requests.dart';
import 'package:signbridge/theme.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
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
    textController.addListener(_latestValue);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void _latestValue() {
    translatedText = textController.text;
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

    return Builder(
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return Scaffold(
          body: Stack(
            children: [
              SlidingUpPanel(
                minHeight: height * 0.25,
                maxHeight: height * 0.40,
                color: themeProvider.themeData.colorScheme.background,
                boxShadow: const [BoxShadow(blurRadius: 1.0, color: silver)],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
                panel: getPanel(),
                // Body
                body: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.0),
                      topRight: Radius.circular(24.0),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 30),
                  child: FutureBuilder(
                    future: getGloss(translatedText),
                    builder:
                        (BuildContext context, AsyncSnapshot glossSnapshot) {
                      if (glossSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return getCenteretLoader();
                      } else if (glossSnapshot.hasError) {
                        return Text('Error: ${glossSnapshot.error}');
                      } else if (glossSnapshot.hasData) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            getPoseAndWordsVis(height, glossSnapshot),
                            getHamVis(height, glossSnapshot),
                          ],
                        );
                      } else {
                        return const Center(
                          child: Text(
                            "Talk something or type",
                            style: TextStyle(color: grey),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              // ThemeToggleButton
              const Padding(
                padding: EdgeInsets.only(top: 40, right: 10),
                child: Align(
                  alignment: Alignment.topRight,
                  child: ThemeToggleButton(),
                ),
              ),
              // Tools
              getMicButton(),
              getLangButton(),
              // Tranaslated text
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
                ),
            ],
          ),
        );
      },
    );
  }

  Align getMicButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AvatarGlow(
          glowColor: isListening ? blue : lightblue,
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
                color: isListening ? blue : lightblue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isListening ? blue : lightblue,
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Icon(
                  Icons.mic,
                  color: silver,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Align getLangButton() {
    return Align(
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
    );
  }

  Column getPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 20, right: 10, top: 16),
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
      ],
    );
  }

  SizedBox getPoseAndWordsVis(double height, AsyncSnapshot glossSnapshot) {
    return SizedBox(
      height: height * 0.55,
      child: FutureBuilder(
        future: getPose(glossSnapshot.data),
        builder: (BuildContext context, AsyncSnapshot poseSnapshot) {
          if (poseSnapshot.connectionState == ConnectionState.waiting) {
            return getCenteretLoader();
          } else if (poseSnapshot.hasError) {
            return Text('Error:${poseSnapshot.error}');
          } else if (poseSnapshot.hasData) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.memory(
                  poseSnapshot.data.pose,
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(height: height * 0.02),
                Text(
                  poseSnapshot.data.words.join(" "),
                  style: const TextStyle(
                    color: grey,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          } else {
            return getCenteretLoader();
          }
        },
      ),
    );
  }

  SizedBox getHamVis(double height, AsyncSnapshot glossSnapshot) {
    return SizedBox(
      height: height * 0.15,
      child: FutureBuilder(
        future: getSign(glossSnapshot.data),
        builder: (BuildContext context, AsyncSnapshot signSnapshot) {
          if (signSnapshot.connectionState == ConnectionState.waiting) {
            return getCenteretLoader();
          } else if (signSnapshot.hasError) {
            return Text('Error: ${signSnapshot.error}');
          } else if (signSnapshot.hasData) {
            return FutureBuilder(
                future: getImg(signSnapshot.data),
                builder: (BuildContext context, AsyncSnapshot imgSnapshot) {
                  if (imgSnapshot.connectionState == ConnectionState.waiting) {
                    return getCenteretLoader();
                  } else if (imgSnapshot.hasError) {
                    return Text('Error: ${imgSnapshot.error}');
                  } else if (imgSnapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Image.memory(
                        imgSnapshot.data,
                        fit: BoxFit.fitWidth,
                      ),
                    );
                  } else {
                    return getCenteretLoader();
                  }
                });
          } else {
            return getCenteretLoader();
          }
        },
      ),
    );
  }

  Center getCenteretLoader() {
    return const Center(
      child: CircularProgressIndicator(
        color: grey,
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
