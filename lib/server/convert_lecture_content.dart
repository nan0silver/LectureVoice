import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; //XFile형태로 동영상 받음
import 'package:second_flutter_app/server/scenedetector_connection.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

// 여기서 강의 내용을 바꿔서 custom video player에 넘겨줘 동영상 + 강의 내용 재생

class ConvertLectureContent extends StatefulWidget {

  final XFile video;
  final GestureTapCallback onNewVideoPressed;
  final String timestampResult;

  const ConvertLectureContent({
    Key? key,
    required this.video, //갤러리에서 선택된 동영상
    required this.onNewVideoPressed, //갤러리에서 동영상 선택
    required this.timestampResult,
    //required this.images,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConvertLectureContent();
}

class _ConvertLectureContent extends State<ConvertLectureContent> {

  SceneDetectorConnection _sceneDetectorConnection = SceneDetectorConnection();

  @override
  Widget build(BuildContext context) {

    throw UnimplementedError();
  }



}
