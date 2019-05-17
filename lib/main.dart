import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:disco_app/database_helper.dart';
import 'package:http_server/http_server.dart';
import 'package:path_provider/path_provider.dart';
import 'package:angel_framework/angel_framework.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() {
    _startWebServer();
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQFlite Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // reference to our single class that manages the database
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('sqflite'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text(
                'insert',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _insert();
              },
            ),
            RaisedButton(
              child: Text(
                'query',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _query();
              },
            ),
            RaisedButton(
              child: Text(
                'update',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _update();
              },
            ),
            RaisedButton(
              child: Text(
                'delete',
                style: TextStyle(fontSize: 20),
              ),
              onPressed: () {
                _delete();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _insert() async {
    // row to insert
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: 'Bob',
      DatabaseHelper.columnAge: 23
    };
    final id = await dbHelper.insert(row);
    print('inserted row id: $id');
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');
    allRows.forEach((row) => print(row));
  }

  void _update() async {
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnId: 1,
      DatabaseHelper.columnName: 'Mary',
      DatabaseHelper.columnAge: 32
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');
  }

  void _delete() async {
    // Assuming that the number of rows is the id for the last row.
    final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(id);
    print('deleted $rowsDeleted row(s): row $id');
  }
}

Future _startWebServer() async {
  print('started');
  bool foundFile = false;
  runZoned(() {
    HttpServer.bind('0.0.0.0', 8000).then((server) {
      print('Server running at: ${server.address.address}');
      server.transform(HttpBodyHandler()).listen((HttpRequestBody body) async {
        print('Request URI');
        switch (body.request.uri.toString()) {
          case '/upload':
            {
              if (body.type != "form") {
                body.request.response.statusCode = 400;
                body.request.response.close();
                return;
              }
              for (var key in body.body.keys.toSet()) {
                if (key == "file") {
                  foundFile = true;
                }
              }
              if (!foundFile) {
                body.request.response.statusCode = 400;
                body.request.response.close();
                return;
              }
              HttpBodyFileUpload data = body.body['file'];
              // Save file
              final directory = await getApplicationDocumentsDirectory();
              File fFile = File('${directory.path}/file');
              fFile.writeAsBytesSync(data.content);
              body.request.response.statusCode = 201;
              body.request.response.close();
              break;
            }
          case '/':
            {
              String _content = 'Hello world';
              body.request.response.statusCode = 200;
              body.request.response.headers
                  .set("Content-Type", "text/html; charset=utf-8");
              body.request.response.write(_content);
              body.request.response.close();
              break;
            }
          default:
            {
              body.request.response.statusCode = 404;
              body.request.response.write('Not found');
              body.request.response.close();
            }
        }
      });
    });
  }, onError: (e, stackTrace) => print('Oh noes! $e $stackTrace'));
}
