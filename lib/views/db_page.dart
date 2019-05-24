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
                  await db.DatabaseHelper.instance
                      .insertClient('0', 'client0', 'secret', false);
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
