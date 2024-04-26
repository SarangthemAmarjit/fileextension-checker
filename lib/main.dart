import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:mime_type/mime_type.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'File Metadata Checker',
      home: FilePickerDemo(),
    );
  }
}

class FilePickerDemo extends StatefulWidget {
  const FilePickerDemo({super.key});

  @override
  _FilePickerDemoState createState() => _FilePickerDemoState();
}

class _FilePickerDemoState extends State<FilePickerDemo> {
  String _fileName = 'No file selected';
  String _filePath = '';
  String _fileSize = '';
  DateTime? _lastModified;
  String _actualExtension = '';
  String _mime = '';

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        _filePath = result.files.single.path!;
        _fileSize =
            '${(result.files.single.size / 1024).toStringAsFixed(2)} KB';

        _actualExtension = result.files.single.extension!;
        _mime = result.files.single.extension!;
      });

      // Get the mime type of the file
      File file = File(result.files.single.path!);
      List<int> bytes = await file.readAsBytes();
      _mime = lookupMimeType(result.files.single.path!, headerBytes: bytes)!;

      // Compare mime type with declared extension
      if (_mime.contains('/')) {
        String declaredExtension = _mime.split('/').last;
        if (declaredExtension != _actualExtension) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Warning'),
                content: const Text(
                    'The file extension does not match its actual type.'),
                actions: <Widget>[
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Metadata Checker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _openFilePicker,
              child: const Text('Select File'),
            ),
            const SizedBox(height: 20),
            Text('File Name: $_fileName'),
            Text('File Path: $_filePath'),
            Text('File Size: $_fileSize'),
            Text('Last Modified: $_lastModified'),
            Text('Actual Extension: $_actualExtension'),
            Text('Mime Type: $_mime'),
          ],
        ),
      ),
    );
  }
}
