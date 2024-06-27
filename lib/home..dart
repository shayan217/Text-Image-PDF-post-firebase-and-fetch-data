import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'view_data.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _textController = TextEditingController();
  File? _selectedImage;
  File? _selectedPdf;
  bool _isSubmitting = false; // Track submission state

  Future<void> _requestPermissions() async {
    // Request storage permission if not granted
  }

  Future<void> _pickImage() async {
    await _requestPermissions();
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _pickPdf() async {
    await _requestPermissions();
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedPdf = File(result.files.single.path!);
      });
    }
  }

  Future<void> _handleSubmit() async {
    String text = _textController.text;
    String? imageUrl;
    String? pdfUrl;

    setState(() {
      _isSubmitting = true; // Start submitting
    });

    try {
      // Upload Image to Firebase Storage
      if (_selectedImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('images/${DateTime.now().millisecondsSinceEpoch}.png');
        await storageRef.putFile(_selectedImage!);
        imageUrl = await storageRef.getDownloadURL();
      }

      // Upload PDF to Firebase Storage
      if (_selectedPdf != null) {
        final storageRef = FirebaseStorage.instance.ref().child('pdfs/${DateTime.now().millisecondsSinceEpoch}.pdf');
        await storageRef.putFile(_selectedPdf!);
        pdfUrl = await storageRef.getDownloadURL();
      }

      // Save data to Firestore
      await FirebaseFirestore.instance.collection('submissions').add({
        'text': text,
        'image_url': imageUrl,
        'pdf_url': pdfUrl,
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data submitted successfully')),
      );
    } catch (e) {
      print('Error uploading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting data')),
      );
    } finally {
      setState(() {
        _isSubmitting = false; // End submitting
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text, Image, PDF Picker'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Enter some text',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                ),
              ),
              SizedBox(height: 20),
              Text('Pick an Image:', style: TextStyle(fontSize: 16)),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Select Image'),
              ),
              _selectedImage != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Image.file(
                        _selectedImage!,
                        height: 150,
                      ),
                    )
                  : Container(),
              SizedBox(height: 20),
              Text('Pick a PDF:', style: TextStyle(fontSize: 16)),
              ElevatedButton(
                onPressed: _pickPdf,
                child: Text('Select PDF'),
              ),
              _selectedPdf != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Selected PDF: ${_selectedPdf!.path}'),
                    )
                  : Container(),
              SizedBox(height: 20),
              Center(
                child: _isSubmitting
                    ? CircularProgressIndicator() // Show progress indicator while submitting
                    : ElevatedButton(
                        onPressed: _handleSubmit,
                        child: Text('Submit'),
                      ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ViewData()),
                    );
                  },
                  child: Text('View Data'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
