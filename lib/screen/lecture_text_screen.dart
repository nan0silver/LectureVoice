import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:second_flutter_app/jsonObject/ocr_base_object.dart';
import 'package:second_flutter_app/server/naver_ocr_connection.dart';

import '../jsonObject/ocr_fields_object.dart';

class LectureTextScreen extends StatefulWidget{
  final List<String> timeline;
  final List<int> millitime;
  final List<String> imageURLList;

  const LectureTextScreen({Key? key, required this.timeline, required this.millitime, required this.imageURLList}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LectureTextScreen();
}

class _LectureTextScreen extends State<LectureTextScreen>{

  NaverOcrConnection _naverOcrConnection = NaverOcrConnection();
  List<String> imageURL = [];
  List<String> inferTextSaveFile = [];

  @override
  Widget build(BuildContext context) {

    int numberOfThumbnailImage = widget.timeline.length;
    imageURL = widget.imageURLList;
    print("number of image url list = ${imageURL.length}");
    print(imageURL);

    return Scaffold(
      appBar: AppBar(
        title: Text("강의 동영상에서 추출한 내용"),
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
                            future: getOCRRequest(imageURL[(i-1)]),
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              var contents = snapshot.data;

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
                                List<OcrFieldsObject> fieldsList = contents.images.fields;
                                List<String> inferTextList = [];
                                inferTextSaveFile.add("${i-1}. [${widget.timeline[i-1]}]");

                                for (var field in fieldsList) {
                                  inferTextList.add(field.inferText);
                                  inferTextList.add("\t");

                                  inferTextSaveFile.add(field.inferText);
                                  inferTextSaveFile.add("\t");
                                }
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      "$inferTextList"
                                  ),
                                );
                              }
                            }
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
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

  Future<dynamic> getOCRRequest(String tempUrl) async {
    print("get OCR Request image url is ${tempUrl}");
    dynamic result_list = await _naverOcrConnection.naverOcrRequest(tempUrl);

    print("get naver ocr result success");

    return result_list;
  }




}