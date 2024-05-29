import 'package:sqlite3/sqlite3.dart';
import 'package:tubesavely/models/video_info.dart';

class DbManager {
  static final db = sqlite3.openInMemory();

  createTable() {
    db.execute('''
      CREATE TABLE IF NOT EXISTS history (
        id INTEGER NOT NULL PRIMARY KEY,
        url TEXT NOT NULL,
        json TEXT NOT NULL,
        created_at INTEGER NOT NULL
      );
    ''');
  }

  static insert(String key, VideoInfo video) {
    final stmt = db.prepare('INSERT INTO history (url,json) VALUES (?,?)');
    stmt.execute([key, video.toJson()]);
  }
}
