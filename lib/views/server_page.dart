// import 'dart:convert';
// import 'dart:io';

import 'package:disco_app/util.dart' as util;
import 'package:flutter/material.dart';
import 'package:disco_app/web_server.dart';
import 'package:disco_app/data.dart' as data;
import 'package:dio/dio.dart';

TextStyle get whiteTextStyle => TextStyle(color: Colors.white);

// var _discoServer = '127.0.0.1';
// var _discoServerPort = 3001;

class ServerPage extends StatefulWidget {
  @override
  _ServerPageState createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage>
    with AutomaticKeepAliveClientMixin<ServerPage> {
  Future<AngelHttp> http;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static var dio = Dio();

  bool _displayCloseServerButton = false;
  var _serverStatusText = 'Server status here';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      initialValue: 'https://disco-app.localtunnel.me',
                      decoration: InputDecoration(labelText: 'Proxy URL'),
                      onSaved: (t) {
                        data.proxyUrl = t;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Referral Code'),
                      onSaved: (t) {
                        data.referralCode = t;
                      },
                    ),
                    MaterialButton(
                      child: Text(
                        'Update',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () async {
                        _formKey.currentState.save();
                      },
                      color: Colors.greenAccent,
                    ),
                  ],
                ),
              ),
              MaterialButton(
                color: Colors.green,
                child: Text('Connect remote'),
                onPressed: () async {
                  await util.connectRemote();
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
              ),
              MaterialButton(
                color: Theme.of(context).accentColor,
                child: Text(
                  'Start server',
                  style: whiteTextStyle,
                ),
                onPressed: () async {
                  _displayCloseServerButton = true;
                  if (http == null) {
                    setState(() {
                      // http = startWebServer(context);
                      http = startWebServer(context);
                    });
                    var t = await http;
                    _serverStatusText =
                        'Started HTTP server at ${t.server.address}:${t.server.port}';
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Alert!'),
                            content: Text(
                                'Do not open multiple instances of server'),
                            actions: <Widget>[
                              new FlatButton(
                                child: Text('Dismiss'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          );
                        });
                  }
                },
              ),
              Expanded(
                flex: 1,
                child: _displayCloseServerButton
                    ? FutureBuilder<AngelHttp>(
                        future: http,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasData) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                MaterialButton(
                                  color: Colors.red,
                                  child: Text(
                                    'Close server',
                                    style: whiteTextStyle,
                                  ),
                                  onPressed: () async {
                                    try {
                                      await closeWebServer(http);
                                      setState(() {
                                        _displayCloseServerButton = false;
                                      });
                                      http = null;
                                    } catch (e) {
                                      print(e);
                                    }
                                  },
                                ),
                                Text(_serverStatusText),
                              ],
                            );
                          } else {
                            return Container();
                          }
                        },
                      )
                    : Container(),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
