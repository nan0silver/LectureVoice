import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ResultDetailScreen extends StatefulWidget {
  final String fileName;
  final String content;

  const ResultDetailScreen({
    Key? key,
    required this.fileName,
    required this.content,
  }) : super(key: key);

  @override
  _ResultDetailScreenState createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends State<ResultDetailScreen> {
  late FlutterTts _flutterTts;
  bool _isPlaying = false;
  String _currentText = '';
  bool _isReadingAll = false;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("ko-KR"); // 한국어로 설정
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
        _isReadingAll = false;
      });
    });
    _flutterTts.setCancelHandler(() {
      setState(() {
        _isPlaying = false;
        _isReadingAll = false;
      });
    });
  }

  // Parse the content to separate each timestamp and its text
  List<Map<String, String>> _parseContent(String content) {
    final regex = RegExp(r'Timestamp:\s*(\d+:\d+:\d+)\nOCR Result:\n(.+?)(?=\nTimestamp|$)', dotAll: true);
    final matches = regex.allMatches(content);

    return matches.map((match) {
      return {
        'timestamp': match.group(1) ?? '',
        'text': match.group(2) ?? '',
      };
    }).toList();
  }

  // Function to start or stop TTS for specific text
  Future<void> _toggleSpeech(String text) async {
    if (_isPlaying && _currentText == text) {
      await _flutterTts.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _flutterTts.speak(text);
      setState(() {
        _isPlaying = true;
        _currentText = text;
      });
    }
  }

  // Function to read all text at once
  Future<void> _readAllText() async {
    if (_isReadingAll) {
      await _flutterTts.stop();
      setState(() {
        _isReadingAll = false;
      });
    } else {
      final allText = _parseContent(widget.content)
          .map((item) => '${item['timestamp']}\n${item['text']}')
          .join('\n\n');
      await _flutterTts.speak(allText);
      setState(() {
        _isReadingAll = true;
      });
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parsedContent = _parseContent(widget.content);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        actions: [
          IconButton(
            icon: Icon(_isReadingAll ? Icons.stop : Icons.play_circle_fill),
            onPressed: _readAllText,
            tooltip: 'Read All Text',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: parsedContent.length,
        itemBuilder: (context, index) {
          final item = parsedContent[index];
          final timestamp = item['timestamp'] ?? '';
          final text = item['text'] ?? '';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text('시간 : $timestamp'),
              subtitle: Text(text),
              trailing: IconButton(
                icon: Icon(
                  _isPlaying && _currentText == text ? Icons.stop : Icons.play_arrow,
                  color: Colors.blue,
                ),
                onPressed: () => _toggleSpeech(text),
              ),
            ),
          );
        },
      ),
    );
  }
}
