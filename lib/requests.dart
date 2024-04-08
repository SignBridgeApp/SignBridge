// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:signbridge/constants.dart';

Future<String?> getSign(String text) async {
  if (text == "") return null;
  String url = "$text2signURL?text=$text";
  try {
    final response = await http.get(Uri.parse(url));
    var responseData = json.decode(response.body);
    return responseData['sign'];
  } catch (e) {
    print(e.toString());
    return null;
  }
}

Future<String?> getGloss(String text) async{
  if (text == "") return null;
  String url = "$text2glossURL?text=$text";
  try {
    final response = await http.get(Uri.parse(url));
    var responseData = json.decode(response.body);
    return responseData['gloss'];
  } catch (e) {
    print(e.toString());
    return null;
  }
}
