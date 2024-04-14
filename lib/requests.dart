import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:signbridge/constants.dart';

class PoseAndWords {
  final Uint8List pose;
  final List words;

  PoseAndWords({required this.pose, required this.words});
}

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
    debugPrint("url: $url");
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      debugPrint(
          '$url failed, code: ${response.statusCode}, error: ${response.body}');
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

Future<String?> getSign(String gloss) async {
  if (gloss == "") return null;
  String url = "$gloss2signURL?gloss=$gloss";
  var responseData = await fetchData(url);
  return responseData?['sign'];
}

Future<Uint8List?> getImg(String sign) async {
  if (sign == "") return null;
  String url = '$sign2imgURL?sign=$sign&line_color=224,231,241,255';
  var responseData = await fetchData(url);
  String? base64Image = responseData?['img'];
  return imageFromBase64String(base64Image);
}

Future<PoseAndWords?> getPose(String gloss) async {
  if (gloss == "") return null;
  String url = "$gloss2poseURL?gloss=$gloss";
  var responseData = await fetchData(url);
  String? base64Image = responseData?['img'];
  return PoseAndWords(
      pose: imageFromBase64String(base64Image)!, words: responseData?['words']);
}
