import 'package:flutter/cupertino.dart';
import 'package:second_flutter_app/jsonObject/ocr_fields_object.dart';

class OcrImageObject {

  //            "uid": "1cb660a424804c1a9b5e7665b66f07fa",
  //             "name": "medium",
  //             "inferResult": "SUCCESS",
  //             "message": "SUCCESS",
  //             "validationResult": {
  //                 "result": "NO_REQUESTED"
  //             },
  //             "fields": [

  final String uid;
  final String name;
  final String inferResult;
  final String message;
  //final String validationResult;
  final List<OcrFieldsObject> fields;

  const OcrImageObject({
    required this.uid,
    required this.name,
    required this.inferResult,
    required this.message,
    //required this.validationResult,
    required this.fields,
  });

  factory OcrImageObject.fromJson(Map<String, dynamic> json) {

    debugPrint("ocr image object parsing start");
    var field = json['fields'] as List;
    debugPrint("field's runtimeType = ${field.runtimeType}");
    List<OcrFieldsObject> fieldList = field.map((i) => OcrFieldsObject.fromJson(i)).toList();

    return OcrImageObject(
      uid: json['uid'] as String,
      name: json['name'] as String,
      inferResult: json['inferResult'] as String,
      message: json['message'] as String,
      //validationResult: json['validationResult'] as String,
      fields: fieldList,
    );
  }

}