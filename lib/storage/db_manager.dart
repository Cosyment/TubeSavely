import 'package:simple_database/simple_database.dart';
import 'package:tubesavely/models/video_info.dart';

class DbManager {
  static SimpleDatabase? db;

  static SimpleDatabase instance() {
    db ??= SimpleDatabase(name: 'tubesaverx', fromJson: (fromJson) => VideoInfo.fromJson(fromJson));
    return db!;
  }
}
