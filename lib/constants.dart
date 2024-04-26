import 'dart:io';
import 'package:flutter/material.dart';

const Color silver = Color.fromARGB(255, 224, 231, 241);
const Color black = Color.fromARGB(255, 19, 19, 19);
const Color white = Colors.white;
const Color grey = Colors.grey;
const Color blue = Colors.blue;
const Color lightblue = Colors.lightBlue;

final bool isAndroid = Platform.isAndroid;
final bool isIos = Platform.isIOS;

const Map<String, String> langs = {
  "ar": "Arabic",
  "bn": "Bengali",
  "zh-CN": "Chinese",
  "de": "German",
  "en_US": "English",
  "es": "Spanish",
  "fr": "French",
  "gu": "Gujarati",
  "hi": "Hindi",
  "it": "Italian",
  "ja": "Japanese",
  "kn": "Kannada",
  "ko": "Korean",
  "ml": "Malayalam",
  "mr": "Marathi",
  "pt-BR": "Portuguese",
  "ru": "Russian",
  "ta": "Tamil",
  "te": "Telugu",
  "ur": "Urdu",
};

String baseURL = "https://bipinkrish-signbridge.hf.space";
