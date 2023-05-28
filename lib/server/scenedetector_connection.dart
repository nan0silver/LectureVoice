import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';

class SceneDetectorConnection {

  var baseurl = 'http://127.0.0.1:5000';
  var sceneDio = Dio();

  Future<List<dynamic>> sceneDetectorRequest () async {
    try {
      Response response = await sceneDio.get('$baseurl/find_scenes');
      String responseString = response.data;
      debugPrint("==debugPrint==");
      debugPrint(responseString);
      debugPrint("==============");

      //final resultData = jsonDecode(responseString);
      //final resultData = jsonDecode(responseString) as List<List<dynamic>>;

      //final responseData = response.data.cast<dynamic>().toList();
      //final resultData = responseData.map((data) => [data]).toList();

      List<dynamic> data = jsonDecode(response.data);

      print("done!!");
      return data;
    } catch (e) {
      print("e start");
      print(e);
      print("fail!!");
      List<List<dynamic>> error = [[e]];
      return error;
    }
  }

}