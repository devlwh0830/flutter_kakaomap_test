import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

getSchoolDistance(String x, String y) async {
  const String url = "https://apis-navi.kakaomobility.com/v1/directions";

  Map<String, String> headers = {
    "Authorization": "${dotenv.env['appKey']}",
    "Content-Type": "application/json",
  };

  Map<String, String> params = {
    "origin": "$x,$y", // 출발지
    "destination": "127.0055628030269,37.48373557342313", // 도착지
    "priority": "DISTANCE" // 거리순
  };

  Uri uri = Uri.parse(url);
  uri = uri.replace(queryParameters: params);
  var result;
  await http.get(uri, headers: headers).then((response) {
    if (response.statusCode == 200) {
      // 성공적으로 요청을 받았을 때의 처리
      print("Response: ${jsonDecode(response.body)['routes'][0]['summary']['distance']}m");
      // km 출력 (소수점은 첫번째 까지)
      result = "${double.parse((jsonDecode(response.body)['routes'][0]['summary']['distance'] / 1000).toString()).toStringAsFixed(1)}km";
    } else {
      // 요청이 실패했을 때의 처리
      print(response.body);
      return "Request failed with status: ${response.statusCode}";
    }
  }).catchError((error) {
    // 오류가 발생했을 때의 처리
    return "Error: $error";
  });
  return result;
}