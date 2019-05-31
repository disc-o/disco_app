import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class DatabaseHelper {
  static final _databaseName = "MyDatabase.db";
  static final _databaseVersion = 1;

  static final clientTable = 'clients_table';
  static final tokenTable = 'tokens_table';

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory =
        await path_provider.getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    print('Creating db...');
    await db.execute('''
      PRAGMA foreign_keys = 1
      ''');
    await db.execute('''
            CREATE TABLE $clientTable (
              client_id     TEXT                              PRIMARY KEY,
              client_name   TEXT DEFAULT client_default_name  NOT NULL,
              client_secret TEXT                              NOT NULL,
              is_trusted    BOOLEAN                           NOT NULL,
              certificate   TEXT                              NOT NULL,
              public_key    TEXT                              NOT NULL
            )
          ''');
    await db.execute('''
      CREATE TABLE $tokenTable (
          token       TEXT,
          sign_secret TEXT                                            NOT NULL,
          client_id   TEXT,
          scopes      TEXT                                            NOT NULL,
          expires_in  INTEGER,
          is_valid    BOOLEAN   DEFAULT TRUE                          NOT NULL,
          entry_time  DATETIME  DEFAULT (datetime('now','localtime')) NOT NULL,
          last_used   DATETIME,
          last_used_by  TEXT,
          used_count  INTEGER   DEFAULT 0                             NOT NULL,
          PRIMARY KEY (token),
          FOREIGN KEY (client_id) REFERENCES $clientTable(client_id)
      )
    ''');
    // await insertClient('001', 'client001', 'secret', false);
  }

  Future<int> insert(String table, Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<int> insertClient(String clientId, String clientName,
      String clientSecret, bool isTrusted, String cert, String pk) async {
    Database db = await instance.database;
    return await db.insert(clientTable, {
      'client_id': clientId,
      'client_name': clientName,
      'client_secret': clientSecret,
      'is_trusted': isTrusted,
      'certificate': cert,
      'public_key': pk
    });
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<int> queryClientRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $clientTable'));
  }

  Future clearTables() async {
    Database db = await instance.database;
    await db.execute('DELETE FROM $clientTable');
    await db.execute('DELETE FROM $tokenTable');
    await db.execute('VACUUM');
  }

  Future<List<Map<String, dynamic>>> selectClientByClientId(String id) async {
    Database db = await instance.database;
    return await db.query(clientTable, where: 'client_id = ?', whereArgs: [id]);
  }

  Future<int> insertToTokenTable(String token, String signSecret,
      String clientId, String scopes, int expiresIn) async {
    Database db = await instance.database;
    return await db.insert(tokenTable, {
      'token': token,
      'sign_secret': signSecret,
      'client_id': clientId,
      'scopes': scopes,
      'expires_in': expiresIn
    });
  }

  Future<List<Map<String, dynamic>>> selectTokenByJwt(String jwtString) async {
    Database db = await instance.database;
    return await db
        .query(tokenTable, where: 'token = ?', whereArgs: [jwtString]);
  }

  // Future<void> updateTokenAudienceCertByJwt(
  //     String jwtString, String audienceCertificate) async {
  //   Database db = await instance.database;
  //   return await db.update(tokenTable, {'audience_certificate': audienceCertificate},
  //       where: 'token = ?', whereArgs: [jwtString]);
  // }
}
