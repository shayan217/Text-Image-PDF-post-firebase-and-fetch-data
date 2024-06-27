import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:text_image_pdf_picker/pdf_viewer.dart';

class ViewData extends StatelessWidget {
  const ViewData({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Data'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('submissions').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data available'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String text = data['text'] ?? 'No text available';
              String? imageUrl = data['image_url'];
              String? pdfUrl = data['pdf_url'];

              return Card(
                margin: EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text, style: TextStyle(fontSize: 16)),
                      SizedBox(height: 10),
                      if (imageUrl != null)
                        Image.network(imageUrl),
                      SizedBox(height: 10),
                      if (pdfUrl != null)
                        TextButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PdfViewerPage(pdfUrl: pdfUrl),
                              ),
                            );
                          },
                          child: Text('View PDF'),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

