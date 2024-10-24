import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SavedResultsScreen extends StatefulWidget {
  @override
  _SavedResultsScreenState createState() => _SavedResultsScreenState();
}

class _SavedResultsScreenState extends State<SavedResultsScreen> {
  late Database _database;
  List<Map<String, dynamic>> _savedResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedResults();
  }

  // Function to load the saved results from the database
  Future<void> _loadSavedResults() async {
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

    // Query the database to get all the saved results
    List<Map<String, dynamic>> results = await _database.query('results');

    print('Query Result: $results'); // Add this line to check the query result

    // If there are results, update the state
    if (results.isNotEmpty) {
      setState(() {
        _savedResults = results;
        _isLoading = false;
      });
    } else {
      print("No data found in the database."); // Debug print to check if there's no data
      setState(() {
        _isLoading = false;
      });
    }
  }


  // Function to delete a result from the database
  Future<void> _deleteResult(int id) async {
    await _database.delete('results', where: 'id = ?', whereArgs: [id]);
    _loadSavedResults(); // Reload the list after deletion
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
                  // Navigate to a detailed view screen to see the full content
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

// This screen shows the full content of a saved result
class ResultDetailScreen extends StatelessWidget {
  final String fileName;
  final String content;

  const ResultDetailScreen({
    Key? key,
    required this.fileName,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(fileName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            content,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
