import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'images_page.dart';

class SubfoldersPage extends StatefulWidget {
  static const routeName = '/subfolders';

  final String folderName;

  const SubfoldersPage({Key? key, required this.folderName}) : super(key: key);

  @override
  _SubfoldersPageState createState() => _SubfoldersPageState();
}

class _SubfoldersPageState extends State<SubfoldersPage> {
  List<String> _subfolders = [];
  bool _loading = true;
  String _readmeContent = '';

  @override
  void initState() {
    super.initState();
    _fetchSubfolders();
    _fetchReadme();
  }

  Future<void> _fetchSubfolders() async {
    setState(() {
      _loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://qjjlqfxl-3000.brs.devtunnels.ms/subfolders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'folderName': widget.folderName}),
      );

      print('Request body: ${jsonEncode({
            'folderName': widget.folderName
          })}'); // Debug print
      print('Response status: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseJson = jsonDecode(response.body);
        setState(() {
          _subfolders = List<String>.from(responseJson['subfolders']);
          _loading = false;
        });
      } else {
        print('Error fetching subfolders: ${response.statusCode}');
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _fetchReadme() async {
    try {
      final response = await http.post(
        Uri.parse('https://qjjlqfxl-3000.brs.devtunnels.ms/readme'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'folderName': widget.folderName}),
      );

      print('Request body: ${jsonEncode({
            'folderName': widget.folderName
          })}'); // Debug print
      print('Response status: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseJson = jsonDecode(response.body);
        setState(() {
          _readmeContent = responseJson['readme'];
        });
      } else {
        print('Error fetching readme: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Subcarpetas de ${widget.folderName}"),
      ),
      body: Center(
        child: _loading
            ? CircularProgressIndicator()
            : RefreshIndicator(
                onRefresh: _fetchSubfolders,
                child: ListView(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _readmeContent,
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                      ),
                      itemCount: _subfolders.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImagesPage(
                                  folderName: widget.folderName,
                                  subfolderName: _subfolders[index],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.folder,
                                    size: 50, color: Colors.deepPurple),
                                SizedBox(height: 8),
                                Text(
                                  _subfolders[index],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
