import 'package:flutter/material.dart';
import 'package:second_flutter_app/screen/function_select_screen.dart';

//맨 처음 페이지
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
            width: MediaQuery.of(context).size.width, //넓이 최대로
            decoration: getBoxDecoration(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppName(),
                IconButton(
                  icon: Image.asset('asset/img/logo_button.png'),
                  iconSize: 200,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FunctionSelectScreen()),
                    );
                  },
                ),
                SizedBox(height: 30.0,),
                Text(
                    '강의 듣기 시작 버튼',
                    style: TextStyle(
                      color: Color(0xFFB9E2FA),
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Aggro',
                    )
                )
              ],
            )
        ),
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


class AppName extends StatelessWidget{ //앱 제목 출력 위젯
  const AppName({Key? key,}) :super(key: key);

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 35.0,
      fontWeight: FontWeight.w300,
    );

    return Container(
        margin: EdgeInsets.fromLTRB(50, 0, 50, 30),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            width: 5,
            color: Colors.white
          ),
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