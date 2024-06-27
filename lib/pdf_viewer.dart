import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;

  const PdfViewerPage({required this.pdfUrl});

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? localFilePath;

  @override
  void initState() {
    super.initState();
    _downloadPdf(widget.pdfUrl);
  }

  Future<void> _downloadPdf(String url) async {
    try {
      final ref = FirebaseStorage.instance.refFromURL(url);
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/temp.pdf';
      final file = File(filePath);

      await ref.writeToFile(file);

      setState(() {
        localFilePath = filePath;
      });
    } catch (e) {
      print('Error downloading PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: localFilePath != null
          ? PDFView(
              filePath: localFilePath!,
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

