import '../../data/update_model.dart';

class EntityFactory {
  static T? generateOBJ<T>(json) {
    if (json == null) {
      return null;
    } else if (T.toString() == 'UpdataModel') {
      return UpdataModel.fromJson(json) as T;
    } else {
      return json;
    }
  }
}
