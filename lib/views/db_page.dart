import 'package:disco_app/util.dart' as prefix0;
import 'package:flutter/material.dart';
import 'package:disco_app/database_helper.dart' as db;
import 'package:disco_app/widgets/drawer.dart' as drawer;

class DbPage extends StatefulWidget {
  @override
  _DbPageState createState() => _DbPageState();
}

class _DbPageState extends State<DbPage>
    with AutomaticKeepAliveClientMixin<DbPage> {
  String _rawQuery = '';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('DB Helper'),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: TextField(
                maxLines: 6,
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
                var database = await db.DatabaseHelper.instance.database;
                try {
                  List<Map<String, dynamic>> res =
                      await database.rawQuery(_rawQuery);
                  drawer.openDrawer(context, [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: new Text(
                        "Some Heading Text",
                        style: new TextStyle(
                            fontSize: 28.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: Text(res.toString()),
                      ),
                    ),
                  ]);
                } catch (e) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text(e.toString()),
                        );
                      });
                }
              },
            ),
            MaterialButton(
              color: Colors.greenAccent,
              child: Text(
                'Add dummy entry',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () async {
                try {
                  var pemCert = '''
                        -----BEGIN CERTIFICATE-----
                        MIIDGTCCAgECFDJp0BJ+af9z/rLYiT7P2f+xFmQKMA0GCSqGSIb3DQEBCwUAMEkx
                        CzAJBgNVBAYTAlNHMRIwEAYDVQQIDAlTaW5nYXBvcmUxEjAQBgNVBAcMCVNpbmdh
                        cG9yZTESMBAGA1UECgwJRHVtbXkgQ28uMB4XDTE5MDUyODEzMzcwMVoXDTIwMDUy
                        NzEzMzcwMVowSTELMAkGA1UEBhMCU0cxEjAQBgNVBAgMCVNpbmdhcG9yZTESMBAG
                        A1UEBwwJU2luZ2Fwb3JlMRIwEAYDVQQKDAlEdW1teSBDby4wggEiMA0GCSqGSIb3
                        DQEBAQUAA4IBDwAwggEKAoIBAQDJDtjJzwW7DjZb9SreSzYE1f8S9dWoWDD9ebom
                        DAeURUjxEp7Ww0Fr44iVqZnizilrzffrh+HxWTZSxkd42wIlzfvPdeXZYnelSBQq
                        C3wcfZeaY7sJEDciDtnsg6gAqInToiKnX7zKL7vJQULyND+0Z3NV8ET3NnTSew40
                        xRqxOqya3NIWaPexPcHA+kXsdgllIDUrXiyxVQT+f4g15QnTk7OVGSu2R0tUYI7B
                        rRJeJ/6gFpr7aY3ebdUQKSAPHh5fHcehO26ti0suYjlwA7wvjZzSuFXVVo8Flt/i
                        4Aqv65DuGqw/PWwn6xeaiZVAhY85RHqegkbdr1lX1wVwCNX5AgMBAAEwDQYJKoZI
                        hvcNAQELBQADggEBAIPTbCUmc818sz16y30akXM+IUF5s/Sc2Fq4ZIiF8qn13XiI
                        5s/M3IQz5RcrhU7+uAvspL4uVQZqH6ztZsnYSf+mQL563hWo0WUpx686D2ySPBnw
                        KPLsjagCmyfwRtaKpm3zn/wXZJDl4HalQMDHv7Uy1Uy0P9BIxpMvFCFVu0eoW/5R
                        pqLy6JtJtOFq/X0jvjRvdz1xYo19dx3FYk36sxzHm+yE4ch82jHU8tVW8+kYEDqF
                        nrSt9KK7vDxAWT1MMD4EuknrxifHrFfxTf9WVfhsXX4WTK/QfFgQwTsSZaw/ITK7
                        DlnX6jLae5qaZAsIOUjCViURMfSgSNVGR50S4ww=
                        -----END CERTIFICATE-----
                        ''';
                  var cert = await prefix0.parseCertificate(pemCert);
                  await db.DatabaseHelper.instance.insertClient(
                      '0', 'client0', 'secret', false, pemCert, cert.publicKey);
                } catch (e) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text(e.toString()),
                        );
                      });
                }
              },
            ),
            MaterialButton(
              color: Colors.redAccent,
              child: Text(
                'Clear tables',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                try {
                  await db.DatabaseHelper.instance.clearTables();
                } catch (e) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text(e.toString()),
                        );
                      });
                }
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
