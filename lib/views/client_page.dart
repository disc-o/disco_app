// import 'package:disco_app/util.dart';
import 'package:flutter/material.dart';
import 'package:disco_app/data.dart' as data;
import 'package:disco_app/database_helper.dart' as db;

class _ClientData {
  String id;
  String name;
  String secret;
  bool isTrusted = false;
  String publicKey;

  // _clientData(this.id, this.name, this.secret, this.isTrusted, this.publicKey);

  @override
  String toString() {
    return '$id, $name, $secret, $isTrusted, $publicKey';
  }
}

class ClientPage extends StatefulWidget {
  @override
  _ClientPageState createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage>
    with AutomaticKeepAliveClientMixin<ClientPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  _ClientData _data = _ClientData();

  void submit() {
    if (this._formKey.currentState.validate()) {
      _formKey.currentState.save();
    }
  }

  String _notEmpty(String s) {
    if (s.length != 0) {
      return null;
    } else {
      return 'Blank input is not accepted';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
        color: Colors.white,
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: this._formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Client ID'),
                onSaved: (t) {
                  _data.id = t;
                },
                validator: _notEmpty,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Client Name'),
                onSaved: (t) {
                  _data.name = t;
                },
                validator: _notEmpty,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Client Secret'),
                onSaved: (t) {
                  _data.secret = t;
                },
                validator: _notEmpty,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Client Public Key'),
                onSaved: (t) {
                  _data.publicKey = t;
                },
                validator: _notEmpty,
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Client Trusted? (true or false)'),
                onSaved: (t) {
                  _data.isTrusted = t == 'true' ? true : false;
                },
                validator: (val) {
                  if (val == 'true' || val == 'false') {
                    return null;
                  } else {
                    return 'Please enter either "true" or "false"';
                  }
                },
              ),
              new Container(
                child: new RaisedButton(
                  child: new Text(
                    'Submit',
                    style: new TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    if (this._formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      print(await db.DatabaseHelper.instance.insertClient(
                          _data.id,
                          _data.name,
                          _data.secret,
                          _data.isTrusted,
                          data.sampleCertificate,
                          data.samplePublicKey));
                      // openVerificationDrawer(context, _data.name, _data.secret);
                    }
                  },
                  color: Colors.blue,
                ),
                margin: new EdgeInsets.only(top: 20.0),
              )
            ],
          ),
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
