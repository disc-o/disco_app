import 'package:disco_app/x509_certificate.dart';
import 'package:flutter/material.dart';

class CertificateDetailPage extends StatelessWidget {
  final ParsedX509Certificate cert;
  CertificateDetailPage(this.cert);

  Widget _getTile(String title, String subtitle) {
    return ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Certificate Detail')),
      backgroundColor: Colors.white,
      body: Container(
          // color: Colors.white,
          child: ListView(
        padding: const EdgeInsets.only(top: 10.0, left: 5.0, right: 5.0),
        children: <Widget>[
          _getTile('Issuer', cert.issuer.toJson().toString()),
          _getTile('Serial Number', cert.serialNumber),
        ],
      )),
    );
  }
}
