import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; //XFile형태로 동영상 받음
import 'package:second_flutter_app/component/custom_video_player.dart';
import 'package:second_flutter_app/screen/video_select_screen.dart';
import 'package:second_flutter_app/screen/home_screen.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

//=========2 페이지========================
//하단에 3-2 페이지도 이어짐
//장면 전환 time stamp request 기능까지는 여기서

class FunctionSelectScreen extends StatefulWidget {
  const FunctionSelectScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FunctionSelectScreen();
}

class _FunctionSelectScreen extends State<FunctionSelectScreen> {
  XFile? video;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: video == null ? renderEmpty() : renderVideo(),
    );
  }

  Widget renderEmpty() { //동영상 선택 전
    return Container(
      width: MediaQuery.of(context).size.width, //넓이 최대로
      decoration: getBoxDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AppName(),
          //SizedBox(height: 300.0,),
          SizedBox(
            width: 250.0,
            height: 70.0,
            child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const VideoSelectScreen()),
                    );
                  },
                  child: Text(
                      'CONVERTED\n Lecture List',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(128, 151, 213, 50),
                    side: BorderSide(width: 2, color: Colors.white)
                  )
              ),
          ),
          //SizedBox(height: 50.0,),
          _Logo(
            onTap: onNewVideoPressed,
          ),
          SizedBox(height: 20.0,)
        ],
      ),
    );
  }

  void onNewVideoPressed() async {
    final video = await ImagePicker().pickVideo(source: ImageSource.gallery,);
    //final video = await ImagePicker().pickVideo(source: 'asset/img/logo_button.png',);

    if (video != null) {
      setState(() {
        this.video = video;
      });
    }
  }

  BoxDecoration getBoxDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2A3A7C),
          Color(0xFF6699FF),
        ],
      ),
    );
  }


  Widget renderVideo() { //동영상 선택 후
    return Center(
      child: CustomVideoPlayer(
        video: video!,
        onNewVideoPressed: onNewVideoPressed,
      ),
    );
  }
}


class _Logo extends StatelessWidget{ //로고 출력 위젯
  final GestureTapCallback onTap;

  const _Logo({
    required this.onTap,
    Key? key,
  }) :super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        width: 250,
        decoration: BoxDecoration(
          color: Color.fromRGBO(128, 151, 213, 50),
          border: Border.all(
            color: Colors.white,
            width: 2
          ),
          boxShadow: [ BoxShadow(
            color: Colors.black26,
            blurRadius: 10, //흐림 정도
            spreadRadius: 0.7, //두께
            offset: Offset(3,3)
          )],
          borderRadius: BorderRadius.all(Radius.circular(3.5))
        ),
        child: Text(
          'CONVERT\n Lecture List',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
          ),
        ),
      ),
    );
  }
}