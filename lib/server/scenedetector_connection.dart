import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';

class SceneDetectorConnection {

  var baseurl = 'http://127.0.0.1:8000';
  //http://127.0.0.1:5000/find_scenes - 로컬
  //var baseurl = 'http://192.168.153.81:5000';
  //http://192.168.153.81:5000/find_scenes - 연구실 서버컴
  var sceneDio = Dio();

  Future<List<dynamic>> sceneDetectorRequest (String videoPath) async {
    try {
      //Response response = await sceneDio.get('$baseurl/find_scenes');

      var formData = FormData.fromMap({'video_path': videoPath});
      Response response = await sceneDio.post('$baseurl/find_scenes', data: formData);
      String responseString = response.data;
      debugPrint("==debugPrint==");
      debugPrint(responseString);
      debugPrint("==============");

      List<dynamic> data = jsonDecode(response.data);

      debugPrint("done!!");
      return data;
    } catch (e) {
      debugPrint("e start");
      debugPrint(e as String?);
      debugPrint("fail!!");
      List<List<dynamic>> error = [[e]];
      return error;
    }
  }

}