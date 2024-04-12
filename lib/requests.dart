// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:signbridge/constants.dart';

Future<Map<String, dynamic>?> fetchData(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Failed to fetch data. Status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error fetching data: $e');
    return null;
  }
}

Future<String?> getGloss(String text) async {
  if (text == "") return null;
  String url = "$text2glossURL?text=$text";
  var responseData = await fetchData(url);
  return responseData?['gloss'];
}

Future<String?> getSign(String gloss) async {
  if (gloss == "") return null;
  String url = "$gloss2signURL?gloss=$gloss";
  var responseData = await fetchData(url);
  return responseData?['sign'];
}
