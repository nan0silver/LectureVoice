import 'package:flutter/material.dart';
import 'package:second_flutter_app/screen/home_screen.dart';

//====== 3-1 페이지 ================

class VideoSelectScreen extends StatefulWidget {
  const VideoSelectScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VideoSelectScreen();
}

class _VideoSelectScreen extends State<VideoSelectScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width, //넓이 최대로
        decoration: getBoxDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppName(),
            Text(
              'CONVERTED\n Lecture List',
              style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
            ),
            SizedBox(height: 50.0,),
            Row(
              children: [],

            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Back'
                )
            )
          ],
        )
      )
    );
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
}