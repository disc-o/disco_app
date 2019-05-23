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
                List<Map<String, dynamic>> res = await database.rawQuery(_rawQuery);
                print(res);
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
