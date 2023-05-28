import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; //XFile형태로 동영상 받음
import 'package:second_flutter_app/component/custom_video_player.dart';

//맨 처음 페이지

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _AppName(),
          _Logo(
            onTap: onNewVideoPressed,
          ),
          SizedBox(height: 30.0),
          Text(
              '강의 듣기 시작 버튼',
              style: TextStyle(
                color: Color(0xFFB9E2FA),
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Aggro',
              )
          ),
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
      child: Image.asset(
        'asset/img/logo_button.png',
        width: 200,
        height: 200,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}

class _AppName extends StatelessWidget{ //앱 제목 출력 위젯
  const _AppName({Key? key,}) :super(key: key);

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 30.0,
      fontWeight: FontWeight.w300,
    );

    return Container(
        margin: EdgeInsets.fromLTRB(70, 0, 70, 30),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            width: 5,
            color: Colors.white
          )
        ),
        child:
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'LECTURE',
              style: textStyle,
            ),
            Text(
              'PLAYER',
              style: textStyle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            )
          ],
        )
    );
  }
}