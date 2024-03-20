import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

Future<String>  getSign(String text) async {
  String url = "https://bipinkrish-signbridge.hf.space/text2sign?text=${text}";
  final response = await http.get(Uri.parse(url));
  var responseData = json.decode(response.body);
  return responseData['sign'];
}
