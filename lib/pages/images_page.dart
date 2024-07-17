import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ImagesPage extends StatefulWidget {
  static const routeName = '/images';

  final String folderName;
  final String subfolderName;

  const ImagesPage(
      {Key? key, required this.folderName, required this.subfolderName})
      : super(key: key);

  @override
  _ImagesPageState createState() => _ImagesPageState();
}

class _ImagesPageState extends State<ImagesPage> {
  List<String> _images = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchImages();
  }

  Future<void> _fetchImages() async {
    setState(() {
      _error = '';
      _loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://qjjlqfxl-3000.brs.devtunnels.ms/images'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'folderName': widget.folderName,
          'subfolderName': widget.subfolderName
        }),
      );

      print('Request body: ${jsonEncode({
            'folderName': widget.folderName,
            'subfolderName': widget.subfolderName
          })}');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseJson = jsonDecode(response.body);
        setState(() {
          _images = List<String>.from(responseJson['images']);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Error fetching images: ${response.statusCode}';
          _loading = false;
        });
        print(_error);
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
      print(_error);
    }
  }

  void _showImageFullScreen(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Image.network(imageUrl),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Imágenes de ${widget.subfolderName}"),
      ),
      body: Center(
        child: _loading
            ? CircularProgressIndicator()
            : RefreshIndicator(
                onRefresh: _fetchImages,
                child: _error.isNotEmpty
                    ? Text(_error)
                    : _images.isEmpty
                        ? Text('No images found')
                        : GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 4.0,
                            ),
                            itemCount: _images.length,
                            itemBuilder: (context, index) {
                              final imageUrl =
                                  'https://qjjlqfxl-3000.brs.devtunnels.ms/${widget.folderName}/${widget.subfolderName}/${_images[index]}';
                              print(
                                  'Loading image from URL: $imageUrl'); // Debug print
                              return GestureDetector(
                                onTap: () => _showImageFullScreen(imageUrl),
                                child:
                                    Image.network(imageUrl, fit: BoxFit.cover),
                              );
                            },
                          ),
              ),
      ),
    );
  }
}
