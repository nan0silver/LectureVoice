import 'package:flutter/cupertino.dart';
import 'package:second_flutter_app/jsonObject/ocr_boundingpoly_object.dart';

class OcrFieldsObject {

  //                     "valueType": "ALL",
  //                     "boundingPoly": {
  //                         "vertices": []
  //                     },
  //                     "inferText": "Predicted",
  //                     "inferConfidence": 0.9993

  final String valueType;
  final OcrBoundingpolyObject boundingPoly;
  final String inferText;
  final double inferConfidence;

  const OcrFieldsObject({
    required this.valueType,
    required this.boundingPoly,
    required this.inferText,
    required this.inferConfidence,
  });

  factory OcrFieldsObject.fromJson(Map<String, dynamic> json) {

    debugPrint("********OCR Fields Object Start********");

    return OcrFieldsObject(
      valueType: json['valueType'] as String,
      boundingPoly: OcrBoundingpolyObject.fromJson(json['boundingPoly']),
      inferText: json['inferText'] as String,
      inferConfidence: json['inferConfidence'] as double,
    );
  }
}