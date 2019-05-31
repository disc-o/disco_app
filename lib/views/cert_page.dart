import 'package:disco_app/util.dart' as prefix0;
import 'package:disco_app/views/certificate_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:disco_app/database_helper.dart' as db;
import 'package:disco_app/widgets/drawer.dart' as drawer;

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
                  'Query',
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
            ],
          )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
