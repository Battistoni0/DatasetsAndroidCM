import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ViewPhotoPage extends StatefulWidget {
  static const routeName = '/view-photo';

  final File? imageFile;

  const ViewPhotoPage({Key? key, required this.imageFile}) : super(key: key);

  @override
  _ViewPhotoPageState createState() => _ViewPhotoPageState();
}

class _ViewPhotoPageState extends State<ViewPhotoPage> {
  final TextEditingController _datasetController = TextEditingController();
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _loading = false;
  bool _datasetExists = true;

  Future<void> _checkDatasetExists(String dataset) async {
    final response = await http
        .get(Uri.parse('https://qjjlqfxl-3000.brs.devtunnels.ms/folders'));
    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      setState(() {
        _datasetExists =
            List<String>.from(responseJson['folders']).contains(dataset);
      });
    }
  }

  Future<void> _uploadImage(File image, String dataset, String label) async {
    setState(() {
      _loading = true;
    });

    if (!_datasetExists) {
      // Show description dialog if dataset does not exist
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Nuevo Dataset'),
            content: TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción del Dataset',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    final uri = Uri.parse('https://qjjlqfxl-3000.brs.devtunnels.ms/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['dataset'] = dataset
      ..fields['label'] = label
      ..fields['description'] =
          _datasetExists ? '' : _descriptionController.text
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    try {
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      print('Response status: ${response.statusCode}');
      print('Response body: ${responseBody.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseJson = jsonDecode(responseBody.body);
        if (responseJson['message'] == 'File uploaded successfully') {
          _showSuccessDialog();
        } else {
          _showErrorDialog();
        }
      } else {
        _showErrorDialog();
      }
    } catch (e) {
      print('Error: $e');
      _showErrorDialog();
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Éxito'),
          content: const Text('Imagen subida con éxito.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context); // Regresar a la página principal
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Hubo un error al subir la imagen.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final File imageFile = ModalRoute.of(context)!.settings.arguments as File;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ver Foto"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Card(
                        elevation: 20,
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          height: 280,
                          width: 280,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.file(
                              imageFile,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _datasetController,
                        onChanged: _checkDatasetExists,
                        decoration: const InputDecoration(
                          labelText: 'Dataset',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _labelController,
                        decoration: const InputDecoration(
                          labelText: 'Etiqueta',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red, // Color del botón
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white), // Icono de cancelar
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _uploadImage(
                                imageFile,
                                _datasetController.text,
                                _labelController.text,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green, // Color del botón
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                              ),
                            ),
                            child: const Icon(Icons.check,
                                color: Colors.white), // Icono de confirmar
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
