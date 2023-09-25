import 'package:simple_database/simple_database.dart';

import 'VideoParse.dart';

class DbManager {
  static SimpleDatabase? db = null;

  static SimpleDatabase instance() {
    db ??= SimpleDatabase(
        name: 'video', fromJson: (fromJson) => VideoParse.fromJson(fromJson));
    return db!!;
  }
}
