import 'package:flutter/material.dart';

class CertificatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Сертификат")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Таны сертификат", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Container(
              height: 300,
              color: Colors.grey[300],
              child: Center(child: Text("PDF Preview")),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: Text("Сертификат татах")),
          ],
        ),
      ),
    );
  }
}