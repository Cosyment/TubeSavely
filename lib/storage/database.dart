import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tubesavely/model/video_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDB();
    return _db;
  }

  initDB() async {
    sqfliteFfiInit();
    var databaseFactory = databaseFactoryFfi;
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();

    //Create path for database
    String dbPath = p.join(appDocumentsDir.path, "databases", "tubesavely.db");
    var db = await databaseFactory.openDatabase(
      dbPath,
    );

    await db.execute("CREATE TABLE IF NOT EXISTS History ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT,"
        "title STRING,"
        "url STRING,"
        "json STRING"
        ")");
    return db;
  }

  //插入数据
  insert(String url, VideoModel video) async {
    Database? db = await _instance.db;
    print("insert function called");
    print("插入的数据:${video.toJson()}");
    /*insert方法会返回最后的行id*/

    db?.insert('history', {"title": video.title, "url": url, "json": video.toJson()});
  }
}
