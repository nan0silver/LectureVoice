import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:second_flutter_app/jsonObject/ocr_image_object.dart';
import 'dart:io';
import 'dart:async';

import '../jsonObject/ocr_base_object.dart';

class NaverOcrConnection {
  //Future<OcrBaseObject>? get ocr_result => null;

  late List<OcrBaseObject> _ocrBaseObjectList=[];
  late OcrBaseObject _ocrBaseObject;
  Dio ocrDio = new Dio();

  Future<dynamic> naverOcrRequest(String url) async{

    var params = {
      "images" : [
        {
          "format": "png",
          "name": "medium",
          "data": null,
          "url": url
          //"url": "https://firebasestorage.googleapis.com/v0/b/diagramproject-f4e78.appspot.com/o/test%2Fimage_file_1?alt=media&token=3dc9a01e-fb04-4839-a5e2-1765d45cea4b"
        }
      ],
      "lang": "ko",
      "requestId": "string",
      "resultType": "string",
      "timestamp": 0,
      "version": "V1"
    };

    try{
      Response responseOCR = await ocrDio.post(
        'https://tc61wu7n11.apigw.ntruss.com/custom/v1/20088/38629e69fbf3c3640428ce080d3b72bdfd5c15b29f5e9472460db30cf365cf48/general', //주소
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          "X-OCR-SECRET" : "Z3lMQ1VMS0F5cWdobFhaWmRIVFRMbmxGU05LWHR3SEU="
        }),
        data: jsonEncode(params),
      );

      debugPrint("Start naver ocr dio request");

      if (responseOCR.statusCode == 200) {
        debugPrint("response Ocr status code is 200");

        _ocrBaseObject = OcrBaseObject.fromJson(responseOCR.data);
        debugPrint("*********Success OCR Request*******");

        //return responseOCR.data;
        return _ocrBaseObject;

      }else {
        debugPrint(responseOCR.statusCode as String?);
        debugPrint("Failure ocr request");
        return _ocrBaseObjectList;
      }

    }catch (e) {
      String error = e.toString();
      debugPrint("error = $error");
      debugPrint("*_*_*_*_*_*_*_OCR Error_*_*_*_*_*_*_*");

      List<dynamic> errorList = [];
      return errorList;
    }
  }

}