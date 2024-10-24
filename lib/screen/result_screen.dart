import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
  TextEditingController _fileNameController = TextEditingController(); // 파일 이름 입력 컨트롤러 추가
  late Database database;

  @override
  void initState() {
    super.initState();
    _initDatabase(); // 데이터베이스 초기화
    _fetchResults();
  }

  // 데이터베이스 초기화 함수
  Future<void> _initDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'results.db'), // 데이터베이스 파일 경로
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE results(id INTEGER PRIMARY KEY AUTOINCREMENT, fileName TEXT, content TEXT)",
        );
      },
      version: 1,
    );
  }

  // 모든 이미지 URL에 대한 결과를 가져오는 함수
  Future<void> _fetchResults() async {
    if (widget.imageURLList.isEmpty || widget.timeline.isEmpty) {
      print("Error: The imageURLList or timeline is empty.");
      return; // 리스트가 비어 있으면 더 이상 진행하지 않음
    }

    List<Map<String, dynamic>> results = [];

    // 두 리스트의 길이가 다른 경우, 작은 쪽에 맞춰 루프를 돌림
    int length = widget.imageURLList.length < widget.timeline.length
        ? widget.imageURLList.length
        : widget.timeline.length;

    for (int i = 0; i < length; i++) {
      String imageUrl = widget.imageURLList[i];
      String timeStamp = widget.timeline[i];

      // OCR 요청
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

      // Diagram Analysis 요청
      final diagramResponse = await _sendRequest('http://127.0.0.1:5000/diagram_analysis', imageUrl);
      String diagramTexts = "";
      if (diagramResponse != null) {
        diagramTexts = diagramResponse.join("\n");
      }

      // 결과 저장
      results.add({
        "timeStamp": timeStamp,
        "ocrResult": inferTexts,
        "diagramResult": diagramTexts,
      });
    }

    // 상태 업데이트
    setState(() {
      _results = results;
      _isLoading = false;
    });
  }

  // Flask 서버로 요청을 보내는 함수
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

  // 텍스트를 데이터베이스에 저장하는 함수
  Future<void> _saveTextToDatabase(String fileName, BuildContext context) async {
    try {
      // Save text content to a StringBuffer
      StringBuffer textContent = StringBuffer();
      for (var result in _results) {
        textContent.write("Timestamp: ${result['timeStamp']}\n");
        textContent.write("OCR Result:\n${result['ocrResult']}\n");
        textContent.write("Diagram Analysis Result:\n${result['diagramResult']}\n\n");
      }

      // Insert data into the database
      await database.insert(
        'results',
        {
          'fileName': fileName,
          'content': textContent.toString(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      print("Data saved successfully: $fileName"); // Add a print statement here

      // Check if the widget is still mounted before accessing the context
      if (mounted) {
        // Show a SnackBar to confirm successful save
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





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Result Screen"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // 파일 이름 입력받는 텍스트 필드
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
                _saveTextToDatabase(_fileNameController.text, context); // Pass the correct BuildContext
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
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final result = _results[index];

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Timestamp: ${result['timeStamp']}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "OCR Result:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                          Text(result['ocrResult'] ?? ""),
                          SizedBox(height: 10),
                          Text(
                            "Diagram Analysis Result:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          Text(result['diagramResult'] ?? ""),
                        ],
                      ),
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
