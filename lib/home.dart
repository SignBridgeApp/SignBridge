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
  bool speechEnabled = false;
  bool isActive = false;

  final SpeechToText v2t = SpeechToText();
  final GoogleTranslator translator = GoogleTranslator();

  String selectedId = "en_US";
  String translatedText = "";
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initSpeech();
    updateStatus();
    textController.addListener(_latestValue);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void updateStatus() async {
    isActive = await getStatus();
    refresh();
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
        translatedText = textController.text.trim().toLowerCase();
      } else {
        Translation translation =
            await translator.translate(textController.text, to: 'en');
        translatedText = translation.text.trim().toLowerCase();
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
        final primaryColor = themeProvider.isDarkMode ? black : white;
        final secondaryColor = themeProvider.isDarkMode ? silver : black;
        final tertiaryColor = themeProvider.isDarkMode ? grey : black;

        return Scaffold(
          backgroundColor: primaryColor,
          body: Stack(
            children: [
              SlidingUpPanel(
                minHeight: height * 0.25,
                maxHeight: height * 0.25,
                color: primaryColor,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 1.0,
                    color: secondaryColor,
                  )
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
                panel: getPanel(secondaryColor, tertiaryColor),
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
                        return getCenteretLoader(tertiaryColor);
                      } else if (glossSnapshot.hasError) {
                        return Text('Error: ${glossSnapshot.error}');
                      } else if (glossSnapshot.hasData) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            getPoseAndWordsVis(
                              height,
                              glossSnapshot,
                              tertiaryColor,
                            ),
                            getHamVis(
                              height,
                              glossSnapshot,
                              tertiaryColor,
                              themeProvider.isDarkMode,
                            ),
                          ],
                        );
                      } else {
                        return Center(
                          child: Text(
                            isActive
                                ? "Talk something or type"
                                : 'Failed to connect. check "Base URL"',
                            style: TextStyle(
                              color: tertiaryColor,
                            ),
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
              getMicButton(secondaryColor),
              getLangButton(secondaryColor, tertiaryColor),
              getURLButton(secondaryColor),
              // Tranaslated text
              if (selectedId != "en_US" && translatedText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 50, left: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      translatedText,
                      style: TextStyle(
                        color: tertiaryColor,
                        fontSize: 20,
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

  Align getURLButton(Color secondaryColor) {
    Future<String?> askURL() {
      return showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          String name = '';
          return AlertDialog(
            title: Text(
              'Enter Base URL',
              style: TextStyle(color: secondaryColor),
            ),
            content: TextField(
              minLines: 1,
              maxLines: 100,
              controller: TextEditingController(text: baseURL),
              style: TextStyle(color: secondaryColor),
              onChanged: (value) {
                name = value;
              },
              onSubmitted: (value) => Navigator.of(context).pop(value),
              decoration: const InputDecoration(
                hintText: 'Enter Base URL',
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                child: const Text('Set'),
                onPressed: () {
                  Navigator.of(context).pop(name);
                },
              ),
            ],
          );
        },
      );
    }

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.red,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextButton(
            onPressed: () async {
              String? url = await askURL();
              if (url != null) {
                baseURL = url;
                refresh();
                updateStatus();
              }
            },
            child: Icon(
              Icons.link_rounded,
              color: secondaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Align getMicButton(Color secondaryColor) {
    final nowColor = !isActive
        ? grey
        : isListening
            ? blue
            : lightblue;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AvatarGlow(
          glowColor: nowColor,
          animate: isActive && isListening,
          duration: const Duration(milliseconds: 1500),
          repeat: true,
          glowShape: BoxShape.circle,
          child: GestureDetector(
            onTap: () {
              if (!isActive) return;

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
                color: nowColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: nowColor,
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Icon(
                  Icons.mic_rounded,
                  color: secondaryColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Align getLangButton(Color secondaryColor, Color tertiaryColor) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? blue : grey,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextButton(
            onPressed: () {
              _showOptionsDialog(context, secondaryColor, tertiaryColor);
            },
            child: Text(
              langs[selectedId]!,
              style: TextStyle(
                color: secondaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Column getPanel(Color secondaryColor, Color tertiaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 20, right: 10, top: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: TextField(
            enabled: isActive,
            controller: textController,
            style: TextStyle(
              color: tertiaryColor,
              fontSize: 24,
            ),
            autocorrect: true,
            showCursor: true,
            cursorColor: secondaryColor,
            maxLines: 2,
            onChanged: (value) => textController.text = value.toLowerCase(),
            decoration: InputDecoration(
              hintText: 'Talk or type',
              border: InputBorder.none,
              hintStyle: TextStyle(color: tertiaryColor),
              suffixIcon: textController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: tertiaryColor,
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

  SizedBox getPoseAndWordsVis(
      double height, AsyncSnapshot glossSnapshot, Color tertiaryColor) {
    return SizedBox(
      height: height * 0.55,
      child: FutureBuilder(
        future: getPose(glossSnapshot.data),
        builder: (BuildContext context, AsyncSnapshot poseSnapshot) {
          if (poseSnapshot.connectionState == ConnectionState.waiting) {
            return getCenteretLoader(tertiaryColor);
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    poseSnapshot.data.words.join(" "),
                    style: TextStyle(
                      color: tertiaryColor,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          } else {
            return getCenteretLoader(tertiaryColor);
          }
        },
      ),
    );
  }

  SizedBox getHamVis(double height, AsyncSnapshot glossSnapshot,
      Color tertiaryColor, bool isDark) {
    return SizedBox(
      height: height * 0.12,
      child: FutureBuilder(
        future: getSign(glossSnapshot.data),
        builder: (BuildContext context, AsyncSnapshot signSnapshot) {
          if (signSnapshot.connectionState == ConnectionState.waiting) {
            return getCenteretLoader(tertiaryColor);
          } else if (signSnapshot.hasError) {
            return Text('Error: ${signSnapshot.error}');
          } else if (signSnapshot.hasData) {
            return FutureBuilder(
                future: getImg(signSnapshot.data, isDark),
                builder: (BuildContext context, AsyncSnapshot imgSnapshot) {
                  if (imgSnapshot.connectionState == ConnectionState.waiting) {
                    return getCenteretLoader(tertiaryColor);
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
                    return getCenteretLoader(tertiaryColor);
                  }
                });
          } else {
            return getCenteretLoader(tertiaryColor);
          }
        },
      ),
    );
  }

  Center getCenteretLoader(Color tertiaryColor) {
    return Center(
      child: CircularProgressIndicator(
        color: tertiaryColor,
      ),
    );
  }

  Future<void> _showOptionsDialog(
      BuildContext context, Color secondaryColor, Color tertiaryColor) async {
    String? selectedOption = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: ListTile(
            title: const Text('Select a language'),
            isThreeLine: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            minVerticalPadding: 0,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: secondaryColor,
              fontSize: 24,
            ),
            subtitle: const Text(
              "You need to have the language pack installed for the selected language.",
            ),
            subtitleTextStyle: TextStyle(
              fontStyle: FontStyle.italic,
              color: tertiaryColor,
              fontSize: 14,
            ),
          ),
          content: Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: SingleChildScrollView(
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
