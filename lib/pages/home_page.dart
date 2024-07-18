import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'subfolders_page.dart';
import 'upload_image_page.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _imageFile;
  List<String> _folders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchFolders();
  }

  Future<void> _fetchFolders() async {
    setState(() {
      _loading = true;
    });

    try {
      final response = await http
          .get(Uri.parse('https://qjjlqfxl-3000.brs.devtunnels.ms/folders'));
      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        setState(() {
          _folders = List<String>.from(responseJson['folders']);
          _loading = false;
        });
      } else {
        print('Error fetching folders');
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

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);
    setState(() {
      _imageFile = imageFile;
    });

    Navigator.pushNamed(
      context,
      UploadImagePage.routeName,
      arguments: imageFile,
    ).then((_) {
      setState(() {
        _imageFile = null;
      });
    });
  }

  Future<void> _downloadDataset(String dataset) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        print('Downloading dataset: $dataset');
        final response = await http.post(
          Uri.parse('https://qjjlqfxl-3000.brs.devtunnels.ms/download'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'dataset': dataset}),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final downloadDir = Directory('/storage/emulated/0/Download');
          final file = File('${downloadDir.path}/$dataset.zip');
          await file.writeAsBytes(response.bodyBytes);

          print('Dataset descargado en: ${file.path}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dataset descargado en: ${file.path}')),
          );
        } else {
          print('Error downloading dataset: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error downloading dataset')),
          );
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading dataset')),
        );
      }
    } else {
      print('Storage permission denied');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission denied')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Datasets"),
      ),
      body: Center(
        child: _loading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_imageFile != null)
                    Container(
                      height: 280,
                      width: 280,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _fetchFolders,
                      child: ListView.builder(
                        itemCount: _folders.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ListTile(
                              title: Text(_folders[index]),
                              trailing: IconButton(
                                icon: Icon(Icons.download),
                                onPressed: () {
                                  _downloadDataset(_folders[index]);
                                },
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  SubfoldersPage.routeName,
                                  arguments: _folders[index],
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Cámara'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Galería'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
