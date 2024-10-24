import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';

class SceneDetectorConnection {

  var baseurl = 'http://127.0.0.1:8000';
  //http://127.0.0.1:5000/find_scenes - 로컬
  //var baseurl = 'http://192.168.153.81:5000';
  var sceneDio = Dio();

  Future<List<dynamic>> sceneDetectorRequest (String videoPath) async {
    try {
      //Response response = await sceneDio.get('$baseurl/find_scenes');

      var formData = FormData.fromMap({'video_path': videoPath});
      Response response = await sceneDio.post('$baseurl/find_scenes', data: formData);
      String responseString = response.data;
      debugPrint("==sever/screnedetector_connection debugPrint==");
      debugPrint(responseString);
      debugPrint("==============");

      List<dynamic> data = jsonDecode(response.data);
      return data;
    } catch (e) {
      debugPrint("ever/screnedetector_connection error start");
      debugPrint(e as String?);
      debugPrint("fail!!");
      List<List<dynamic>> error = [[e]];
      return error;
    }
  }

}