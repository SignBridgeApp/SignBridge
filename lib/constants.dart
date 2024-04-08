import 'dart:io';
import 'package:flutter/material.dart';

const Color silver = Color.fromARGB(255, 224, 231, 241);
const Color black = Color.fromARGB(255, 19, 19, 19);
const Color grey = Colors.grey;
const Color blue = Colors.blue;
const Color lightblue = Colors.lightBlue;

final bool isAndroid = Platform.isAndroid;
final bool isIos = Platform.isIOS;

const Map<String, String> langs = {
  "en_US": "English",
  "hi": "Hindi",
  "kn": "Kannada",
};

const String baseURL = "https://bipinkrish-signbridge.hf.space";
const String text2signURL = "$baseURL/text2sign";
const String sign2imgURL = "$baseURL/sign2img";
const String text2glossURL = "$baseURL/text2gloss";
