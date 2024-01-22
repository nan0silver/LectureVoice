import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:second_flutter_app/server/naver_ocr_connection.dart';
import '../jsonObject/ocr_fields_object.dart';
import '../jsonObject/ocr_vertices_object.dart';

import 'package:fluttertoast/fluttertoast.dart';

class ImageProcessingScreen extends StatefulWidget{
  final List<String> timeline;
  final List<int> millitime;
  final List<String> imageURLList;

  const ImageProcessingScreen({Key? key, required this.timeline, required this.millitime, required this.imageURLList}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ImageProcessingScreen();
}

class _ImageProcessingScreen  extends State<ImageProcessingScreen> {

  NaverOcrConnection _naverOcrConnection = NaverOcrConnection();
  List<String> imageURL = [];
  List<String> inferTextSaveList = [];
  List<String> verticesSaveList = [];
  //String _processedImageBase64 = '';
  List<String> cutBase64List = [];
  List<CutBoundingVerticesClass> cutBoundingList = [];
  List<OcrVerticesClass> ocrVerticesList0 = [];
  List<OcrVerticesClass> ocrVerticesList2 = [];

  @override
  Widget build(BuildContext context) {

    int numberOfThumbnailImage = widget.timeline.length;
    imageURL = widget.imageURLList;
    //전 페이지에서 넘겨준 이미지 URL 리스트
    //이 url은 firebase에서 이미지 이름(타임라인)으로 다운받은 것
    //도데체 어디서 이미지 width를 500으로 바꿈..?
    print("number of image url list = ${imageURL.length}");

    return Scaffold(
        appBar: AppBar(
        title: Text("강의 동영상 이미지 처리 내용"),
        ),
    body: Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Column(
              children: [
                for (int i = 1; i <= numberOfThumbnailImage; i++)
                  Column(
                    children: [
                      returnTimeline(i),
                      Image.network(imageURL[(i-1)]),
                      FutureBuilder(
                          future: processImage3(imageURL[(i-1)]),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.connectionState != ConnectionState.done) {
                              return CircularProgressIndicator(); //동글동글 돌아가는 로딩서클
                            }
                            else if (snapshot.hasError) {
                              //Object error = snapshot.error!;
                              debugPrint(snapshot.error?.toString());
                              debugPrint("Lecture tet screen error!!!!!!!");
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    'Error!!'
                                ),
                              );
                            }else {
                              Map<String, dynamic> processImageResponse = snapshot.data;

                              var responseX = processImageResponse['x'].toDouble();
                              var responseY = processImageResponse['y'].toDouble();
                              var responseWidth = processImageResponse['width'].toDouble();
                              var responseHeight = processImageResponse['height'].toDouble();
                              String responseBase64 = processImageResponse['image'];
                              cutBase64List.add(responseBase64);
                              debugPrint("cutBase64List[${i-1}]에 base64 string 저장됨");
                              //cutBoundingList.add("[${i-1}] $responseX $responseY $responseWidth $responseHeight");

                              //uploadImage(cutBase64List[i-1], "${i-1}");

                              cutBoundingList.add(CutBoundingVerticesClass((i-1), responseX, responseY, responseWidth, responseHeight));


                              debugPrint("[${i-1} cut image] ($responseX, $responseY) width = $responseWidth, height = $responseHeight");

                              return Image.memory(base64Decode(responseBase64));
                            }
                          }),
                      ElevatedButton(
                        //해당 이미지에 대한 ocr 분석하는 버튼
                          onPressed: () async {
                            var OCRresult = await getOCRRequestByButton(imageURL[(i-1)]);

                            List<OcrFieldsObject> fieldsList = OCRresult.images.fields;
                            List<String> inferTextList = [];
                            inferTextSaveList.add("${i-1}. [${widget.timeline[i-1]}]");

                            int fieldIndex = 0;
                            for (var field in fieldsList) {
                              inferTextList.add(field.inferText);

                              //inferTextSaveFile.add(field.inferText);
                              //inferTextSaveFile.add("\t");

                              //verticesSaveList.add(field.boundingPoly.vertices);
                              List<OcrVerticesObject> verticesList = field.boundingPoly.vertices;

                              int idx = 0;
                              for (var vet in verticesList) {
                                //debugPrint("idx = $idx");
                                if (idx ==0) {
                                  //verticesSaveList.add("[${i-1}] ${vet.x} ${vet.y}");

                                  //ocr 감지 텍스트 박스의 왼쪽 위 좌표 (x0, y0)
                                  //cut image의 좌표(x,y)
                                  //x <= x0 && y <= y0
                                  ocrVerticesList0.add(OcrVerticesClass((i-1), fieldIndex, vet.x, vet.y));
                                  debugPrint("[${i-1} - $fieldIndex}] idx = 0 ${vet.x} ${vet.y}");
                                } else if(idx == 2) {

                                  //ocr 감지 텍스트 박스의 오른쪽 아래 좌표
                                  //x+w >= x2 && y+h >= y2
                                  //4개의 조건 만족시키는 텍스트박스 하나만 있어도 다이어그램이라 판단
                                  ocrVerticesList2.add(OcrVerticesClass((i-1), fieldIndex,vet.x, vet.y));
                                  debugPrint("[${i-1} - $fieldIndex] idx = 2 ${vet.x} ${vet.y}");
                                }
                                idx++;
                              }

                              fieldIndex++;
                            }
                            inferTextSaveList.addAll(inferTextList); //리스트를 통째로 넣음. 나중에 꺼내기 좋게
                            debugPrint("[${i-1}] inferTextList = $inferTextList");


                          },
                          child: const Text("OCR Button")
                      ),
                      ElevatedButton(
                        //해당 이미지 ocr 분석 후, cut된 이미지 안에 탐지된 글이 있는지 확인하는 작업
                          onPressed: () {
                            debugPrint("[Pressed Button [${i-1}]]");
                            debugPrint("$inferTextSaveList");

                            debugPrint("cutBoundingList : $cutBoundingList");
                            debugPrint("ocrVerticesList0 : $ocrVerticesList0");
                            debugPrint("ocrVerticesList2 : $ocrVerticesList2");

                            bool isThisDiagram = false;
                            cutBoundingList.sort((a,b) => a.index.compareTo(b.index)); //인덱스순으로 정렬
                            debugPrint("sorted cutBoundingList : $cutBoundingList");

                            double standardX = cutBoundingList[i-1].x;
                            double standardY = cutBoundingList[i-1].y;
                            double standardWidth = cutBoundingList[i-1].width;
                            double standardHeight = cutBoundingList[i-1].height;

                            //x <= x0 && y <= y0 && x+w >= x2 && y+h >= y2
                            for (var temp = 0; temp < ocrVerticesList0.length; temp++) {
                              if (ocrVerticesList0[temp].index == (i-1)) {
                                if (standardX <= ocrVerticesList0[temp].x
                                  && standardY <= ocrVerticesList0[temp].y
                                  && (standardX + standardWidth) >= ocrVerticesList2[temp].x
                                  && (standardY + standardHeight) >= ocrVerticesList2[temp].y) {
                                  isThisDiagram = true;
                                  debugPrint("isThisDiagram = true!!!!!");
                                  break;
                                }
                              }
                            }

                            if (isThisDiagram) {
                              debugPrint("@@@@@THIS IS RESULT THAT is This Diagram is true!@@@@@");

                              Fluttertoast.showToast(
                                msg: "This image contains DIAGRAM",
                                gravity: ToastGravity.BOTTOM,
                                toastLength: Toast.LENGTH_LONG,
                              );

                            } else {
                              debugPrint("@@@@@THIS IS RESULT THAT is This Diagram is false@@@@@");

                              Fluttertoast.showToast(
                                msg: "This is NOT diagram",
                                gravity: ToastGravity.BOTTOM,
                                toastLength: Toast.LENGTH_LONG,
                              );
                            }

                            uploadImage(cutBase64List[i-1], "${i-1}");


                          },
                          child: const Text("Is the cut image a diagram?")
                      ),

                      ElevatedButton(
                          onPressed: () async {
                            var result = await getDiagramSentense(cutBase64List[i-1], "${i-1}");

                            debugPrint(result);

                          },
                          child: const Text("Diagram analyze Button")
                      ),


                    ]
                  )
              ]
            )
          ]
        )
      )
    )
    );

  }

  Widget returnTimeline(int index) { //*** index is started from 1 ***
    List<String> timeline = widget.timeline;
    String tempTimeline = timeline[index-1];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        "$index. [$tempTimeline]",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  String changeToMillitime(String tempTimeline){
    String milliTime = "";

    List<String> timeSplit = tempTimeline.split(':');
    int hour = int.parse(timeSplit[0]);
    int min = int.parse(timeSplit[1]);
    int sec = int.parse(timeSplit[2]);
    print("hour = $hour, min = $min, sec = $sec");

    //milliTime = (hour*60*60*1000) + (min*60*1000) + (sec*1000) + secBack+1;
    print(milliTime);


    return milliTime;
  }

  Future<String> downloadThumbnail(int index) async{ //*** index is started from 1 ***
    List<int> millitime = widget.millitime;
    int tempMillTime = millitime[index-1];

    Reference _ref = FirebaseStorage.instance.ref().child("test/image_file_$tempMillTime");
    String _thumbnailImageURL = await _ref.getDownloadURL();
    print("thumbnail image url = $_thumbnailImageURL");


    return _thumbnailImageURL;
  }

  Future<String> getImageFromURL(String imageUrl) async {
    print("process Image's image url = $imageUrl");

    try {
      http.Response imageResponse = await http.get(Uri.parse(imageUrl));
      //List<int> imageBytes = imageResponse.bodyBytes;
      Uint8List imageBytes = imageResponse.bodyBytes;
      String imageString = String.fromCharCodes(imageBytes);
      debugPrint("get image success");
      //debugPrint(imageString);
      return imageString;

    }catch (e) {
      debugPrint("get Image From URL ERROR = $e");
      return "ERROR";
    }

  }


  Future<Map<String, dynamic>> processImage3(String imageUrlString) async {

    debugPrint("process Image 3 URL = $imageUrlString");

    final http.Response responseData = await http.get(Uri.parse(imageUrlString));
    Uint8List uint8list = responseData.bodyBytes;
    var buffer = uint8list.buffer;
    ByteData byteData = ByteData.view(buffer);
    var tempDir = await getTemporaryDirectory();
    File imageFile = await File('${tempDir.path}/img').writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    try {
      String flaskUrl = 'http://127.0.0.1:5000/process_image';
      //flask_rectangle_detect.py connection

      Map<String, String> headers = {
        'Content-Type': 'multipart/form-data',
      };

      var request3 = http.MultipartRequest("POST", Uri.parse(flaskUrl));

      request3.files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          //contentType: new MediaType('image', 'png')
      ));
      request3.headers.addAll(headers);

      //=================//
      var streamedResponse = await request3.send();
      var response = await http.Response.fromStream(streamedResponse);

      //=====//
      var decodeResponse = jsonDecode(response.body);


      //debugPrint("response = ${response.body}");
      //debugPrint("decode response = $decodeResponse");
      debugPrint("processImage3 response success");

      return decodeResponse;


    } on Exception catch (e) {
      debugPrint("Error = $e");
      Map<String, dynamic> errorResponse = jsonDecode("error");
      return errorResponse;
    }
  }

  Future<dynamic> isTextExist(String tempUrl) async {
    print("get OCR Request image url is ${tempUrl}");
    dynamic resultList = await _naverOcrConnection.naverOcrRequest(tempUrl);

    print("get naver ocr result success");

    return resultList;
  }

  Future<dynamic> getOCRRequestByButton(String tempUrl) async {
    print("get OCR Request image url is ${tempUrl}");
    dynamic resultList = await _naverOcrConnection.naverOcrRequest(tempUrl);

    print("get naver ocr result by button success");

    return resultList;
  }

  Future<dynamic> getDiagramSentense(String cropimageUrl, String imageNum) async {


    Reference _ref = FirebaseStorage.instance.ref().child('images/your_image_${imageNum}.jpg');
    String _url = await _ref.getDownloadURL();

    print("\n\nimage num ?? $imageNum");

    final http.Response responseData = await http.get(Uri.parse(_url));
    Uint8List uint8list = responseData.bodyBytes;
    var buffer = uint8list.buffer;
    ByteData byteData = ByteData.view(buffer);
    var tempDir = await getTemporaryDirectory();
    File imageFile = await File('${tempDir.path}/img').writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    print("crop image url = $_url");


    try {
      String flaskUrl2 = 'http://127.0.0.1:8001/arrow_detect';
      //flask_arrow_detect.py connection

      Map<String, String> headers = {
        'Content-Type': 'multipart/form-data',
      };

      var requestArrow = http.MultipartRequest("POST", Uri.parse(flaskUrl2));

      requestArrow.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        //contentType: new MediaType('image', 'png')
      ));
      requestArrow.files.add(await http.MultipartFile.fromString(
        'image_url',
        _url,
        //contentType: new MediaType('image', 'png')
      ));
      requestArrow.headers.addAll(headers);

      //=================//
      var streamedResponse = await requestArrow.send();
      var response = await http.Response.fromStream(streamedResponse);

      //=====//
      //var decodeResponse = jsonDecode(response.body);


      debugPrint("response = ${response.body}");
      //debugPrint("***** Crop Image Analysis decode response = $decodeResponse *****");
      debugPrint("cropImage analysis response success");

      return "good!";


    } on Exception catch (e) {
      debugPrint("Error = $e");
      Map<String, dynamic> errorResponse = jsonDecode("error");
      return errorResponse;
    }

  }

  Future<void> uploadImage(String base64Image, String imageNum) async {
    try {
      // 이미지를 디코딩하여 바이트 배열로 변환
      Uint8List _uint8list = base64.decode(base64Image);
      ByteData _byte = ByteData.view(_uint8list.buffer);
      Directory _systemDirectory = Directory.systemTemp;
      File _file = await File('${_systemDirectory.path}/my_image_$imageNum').writeAsBytes(
          _uint8list.buffer
              .asUint8List(_byte.offsetInBytes, _byte.lengthInBytes));

      DateTime dateTime = DateTime.now();

      // Firebase Storage에 접근
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference storageReference = storage.ref().child("images/your_image_${imageNum}.jpg");

      // 이미지 업로드
      await storageReference.putFile(_file);

      print("이미지 업로드 성공!");
    } catch (e) {
      print("이미지 업로드 실패: $e");
    }
  }

}

class CutBoundingVerticesClass{
  int index;
  double x;
  double y;
  double width;
  double height;

  CutBoundingVerticesClass(this.index, this.x, this.y, this.width, this.height);

  String toString(){
    return '[${this.index}] {${this.x}, ${this.y}, ${this.width}, ${this.height}},';
  }
}

class OcrVerticesClass{
  int index;
  int fieldIndex;
  double x;
  double y;

  OcrVerticesClass(this.index, this.fieldIndex, this.x, this.y);

  String toString(){
    return '[${this.index} - ${this.fieldIndex}] {${this.x}, ${this.y}},';
  }
}
