import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:second_flutter_app/screen/result_detail_screen.dart';

class SavedResultsScreen extends StatefulWidget {
  @override
  _SavedResultsScreenState createState() => _SavedResultsScreenState();
}

class _SavedResultsScreenState extends State<SavedResultsScreen> {
  Database? _database;
  List<Map<String, dynamic>> _savedResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedResults();
  }

  Future<void> _loadSavedResults() async {
    try {
      final databasePath = await getDatabasesPath();
      String path = join(databasePath, 'results.db');

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE IF NOT EXISTS results(id INTEGER PRIMARY KEY, fileName TEXT, content TEXT)',
          );
        },
      );

      List<Map<String, dynamic>> results = await _database!.query('results');

      setState(() {
        _savedResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteResult(int id) async {
    if (_database != null) {
      setState(() {
        _isLoading = true;
      });
      await _database!.delete('results', where: 'id = ?', whereArgs: [id]);
      _loadSavedResults();
    }
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Results"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _savedResults.length,
        itemBuilder: (context, index) {
          final result = _savedResults[index];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              child: ListTile(
                title: Text(
                  result['fileName'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  result['content'].substring(0, 50) + '...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _deleteResult(result['id']);
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultDetailScreen(
                        fileName: result['fileName'],
                        content: result['content'],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
