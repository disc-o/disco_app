import 'dart:convert';

import 'package:disco_app/util.dart' as prefix0;
import 'package:disco_app/views/certificate_detail_page.dart';
import 'package:disco_app/web_server.dart';
import 'package:flutter/material.dart';
// import 'package:disco_app/database_helper.dart' as db;
// import 'package:disco_app/widgets/drawer.dart' as drawer;
import 'package:disco_app/util.dart' as util;
import 'package:disco_app/data.dart' as data;

class CertPage extends StatefulWidget {
  @override
  _CertPageState createState() => _CertPageState();
}

class _CertPageState extends State<CertPage>
    with AutomaticKeepAliveClientMixin<CertPage> {
  String _rawQuery = '';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Colors.white,
      child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: TextField(
                  maxLines: 9,
                  onChanged: (text) {
                    setState(() {
                      _rawQuery = text;
                    });
                  },
                ),
              ),
              MaterialButton(
                color: Colors.blueAccent,
                child: Text(
                  'Parse Certificate Information',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  var cert = await prefix0.parseCertificate(_rawQuery);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CertificateDetailPage(cert)));
                },
              ),
              MaterialButton(
                color: Colors.green,
                child: Text(
                  'Encrypt Key B Request',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  var keyBRequestInfo = jsonEncode({
                    "access_token": _rawQuery,
                    "client_id": "IKEA's ID",
                    "client_secret": "secret",
                    "response_type": "token",
                    "redirect_uri": "https://ikea.com/redirect",
                    "scope": "address",
                    "audience": "Singpost",
                  });
                  var t1 = util.SymmetricEncrypted.asymEncrypted(
                      util.encryptSymmetric(keyBRequestInfo),
                      rsaHelper,
                      data.keyPair.publicKey);
                  print(t1);
                  print(util.decryptAsymmetricallyEncryptedSE(
                      t1, rsaHelper, data.keyPair.privateKey));
                },
              ),
            ],
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
