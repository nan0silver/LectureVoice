import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:second_flutter_app/screen/home_screen.dart';

class ResultScreen extends StatefulWidget {
  final List<String> timeline;
  final List<int> millitime;
  final List<String> imageURLList;

  const ResultScreen({
    Key? key,
    required this.timeline,
    required this.millitime,
    required this.imageURLList,
  }) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = true;
  TextEditingController _fileNameController = TextEditingController();
  late Database database;
  late FlutterTts flutterTts;
  bool isPlaying = false;
  bool isReadingAll = false;
  String _currentText = '';

  @override
  void initState() {
    super.initState();
    _initDatabase();
    _fetchResults();
    _initTts();
  }

  // TTS 초기화 함수
  void _initTts() {
    flutterTts = FlutterTts();
    flutterTts.setLanguage("ko-KR"); // 한국어로 설정
    flutterTts.setSpeechRate(0.5); // 속도 설정
    flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
        isReadingAll = false;
      });
    });
  }

  // 데이터베이스 초기화
  Future<void> _initDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'results.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE results(id INTEGER PRIMARY KEY AUTOINCREMENT, fileName TEXT, content TEXT)",
        );
      },
      version: 1,
    );
  }

  // 결과 저장 함수
  Future<void> _saveTextToDatabase(String fileName, BuildContext context) async {
    try {
      StringBuffer textContent = StringBuffer();
      for (var result in _results) {
        textContent.write("Timestamp: ${result['timeStamp']}\n");
        textContent.write("OCR Result:\n${result['ocrResult']}\n");
        textContent.write("다이어그램 분석 결과:\n${result['diagramResult']}\n\n");
      }

      await database.insert(
        'results',
        {
          'fileName': fileName,
          'content': textContent.toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data saved to database as $fileName'),
          ),
        );
      }
    } catch (e) {
      print("Error saving data to database: $e");
    }
  }

  // 모든 이미지 URL에 대한 결과 가져오기
  Future<void> _fetchResults() async {
    if (widget.imageURLList.isEmpty || widget.timeline.isEmpty) {
      print("Error: The imageURLList or timeline is empty.");
      return;
    }

    List<Map<String, dynamic>> results = [];
    int length = widget.imageURLList.length < widget.timeline.length
        ? widget.imageURLList.length
        : widget.timeline.length;

    for (int i = 0; i < length; i++) {
      String imageUrl = widget.imageURLList[i];
      String timeStamp = widget.timeline[i];

      final ocrResponse = await _sendRequest('http://127.0.0.1:5000/ocr_request', imageUrl);
      String inferTexts = "";
      if (ocrResponse != null) {
        for (var inferText in ocrResponse) {
          List<String> punctuations = ['.', '?', '!', '·'];
          if (punctuations.any((p) => inferText.endsWith(p))) {
            inferTexts += inferText + "\n";
          } else {
            inferTexts += inferText + " ";
          }
        }
      }

      final diagramResponse = await _sendRequest('http://127.0.0.1:5000/diagram_analysis', imageUrl);
      String diagramTexts = "";
      if (diagramResponse != null) {
        diagramTexts = diagramResponse.join("\n");
      }

      results.add({
        "timeStamp": timeStamp,
        "ocrResult": inferTexts,
        "diagramResult": diagramTexts,
      });
    }

    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  // Flask 서버로 요청
  Future<List<dynamic>?> _sendRequest(String url, String imageUrl) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"image_urls": [imageUrl]}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Request to $url failed with status code ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error sending request to $url: $e");
      return null;
    }
  }

  // 개별 텍스트 재생
  Future<void> _toggleSpeech(String text) async {
    if (isPlaying && _currentText == text) {
      await flutterTts.stop();
      setState(() {
        isPlaying = false;
      });
    } else {
      await flutterTts.speak(text);
      setState(() {
        isPlaying = true;
        _currentText = text;
      });
    }
  }

  // 전체 텍스트 재생
  Future<void> _readAllText() async {
    if (isReadingAll) {
      await flutterTts.stop();
      setState(() {
        isReadingAll = false;
      });
    } else {
      final allText = _results
          .map((result) => "Timestamp: ${result['timeStamp']}\n${result['ocrResult']}\n${result['diagramResult']}")
          .join('\n\n');
      await flutterTts.speak(allText);
      setState(() {
        isReadingAll = true;
      });
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Results"),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            tooltip: 'Go to Home',
          ),
          IconButton(
            icon: Icon(isReadingAll ? Icons.stop : Icons.play_circle_fill),
            onPressed: _readAllText,
            tooltip: 'Read All Text',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _fileNameController,
              decoration: InputDecoration(
                labelText: "Enter file name",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_fileNameController.text.isNotEmpty) {
                _saveTextToDatabase(_fileNameController.text, context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Please enter a valid file name'),
                ));
              }
            },
            child: Text("Save Results to Database"),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final result = _results[index];
                final timestamp = result['timeStamp'] ?? '';
                final ocrText = result['ocrResult'] ?? '';
                final diagramText = result['diagramResult'] ?? '';
                final displayText = "$ocrText\n$diagramText";

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text('시간 : $timestamp'),
                    subtitle: Text(displayText),
                    trailing: IconButton(
                      icon: Icon(
                        isPlaying && _currentText == displayText ? Icons.stop : Icons.play_arrow,
                        color: Colors.blue,
                      ),
                      onPressed: () => _toggleSpeech(displayText),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
