
import 'package:second_flutter_app/jsonObject/ocr_vertices_object.dart';

class OcrBoundingpolyObject {

  //     "vertices": []

  final List<OcrVerticesObject> vertices;

  const OcrBoundingpolyObject({
    required this.vertices,
  });

  factory OcrBoundingpolyObject.fromJson(Map<String, dynamic> json) {

    var vertice = json['vertices'] as List;
    //print("vertice's runtimeType = ${vertice.runtimeType}");
    List<OcrVerticesObject> verticeList = vertice.map((i) => OcrVerticesObject.fromJson(i)).toList();


    return OcrBoundingpolyObject(
      vertices: verticeList,
    );
  }

}