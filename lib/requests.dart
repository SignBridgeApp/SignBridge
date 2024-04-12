import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:signbridge/constants.dart';

Uint8List? imageFromBase64String(String? base64String) {
  if (base64String != null) {
    Uint8List bytes = base64.decode(base64String);
    return bytes;
  } else {
    return null;
  }
}

Future<Map<String, dynamic>?> fetchData(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    debugPrint("url: $url, status code: ${response.statusCode}");
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      debugPrint('Failed to fetch data. Status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    debugPrint('Error fetching data: $e');
    return null;
  }
}

Future<String?> getGloss(String text) async {
  if (text == "") return null;
  String url = "$text2glossURL?text=$text";
  var responseData = await fetchData(url);
  return responseData?['gloss'];
}

Future<String?> getSign(String text) async {
  if (text == "") return null;
  String url = "$text2glossURL?text=$text";
  var responseData = await fetchData(url);
  String gloss = responseData?['gloss'];
  String finalUrl = "$gloss2signURL?gloss=$gloss";
  var finalResponse = await fetchData(finalUrl);
  return finalResponse?['sign'];
}

Future<Uint8List?> getImg(String sign) async {
  if (sign == "") return null;
  String url = '$sign2imgURL?sign=$sign&line_color=224,231,241,255';
  var responseData = await fetchData(url);
  String? base64Image = responseData?['img'];
  return imageFromBase64String(base64Image);
}
