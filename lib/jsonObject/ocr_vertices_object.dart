import 'package:flutter/cupertino.dart';

class OcrVerticesObject {

  //     {
  //                                 "x": 377.0,
  //                                 "y": 24.0
  //                             },

  final double x;
  final double y;

  const OcrVerticesObject({
    required this.x,
    required this.y,
  });

  factory OcrVerticesObject.fromJson(Map<String, dynamic> json) {

    debugPrint("OCR (x, y) = (${json['x']}, ${json['y']})");

    return OcrVerticesObject(
      x: json['x'] as double,
      y: json['y'] as double,
    );
  }
}