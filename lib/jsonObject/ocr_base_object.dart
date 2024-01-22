import 'package:flutter/cupertino.dart';
import 'package:second_flutter_app/jsonObject/ocr_image_object.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class OcrBaseObject {

  //     "version": "V1",
  //     "requestId": "string",
  //     "timestamp": 1688907683359,
  //     "images": []

  final String version;
  final String requestId;
  final int timestamp;
  final OcrImageObject images;

  const OcrBaseObject({
    required this.version,
    required this.requestId,
    required this.timestamp,
    required this.images,
  });

  factory OcrBaseObject.fromJson(Map<String, dynamic> json) {
    debugPrint("ocr base object parsing start");

    return new OcrBaseObject(
      version: json['version'],
      requestId: json['requestId'],
      timestamp: json['timestamp'],
      images: OcrImageObject.fromJson(json['images'][0]),
    );
  }

}