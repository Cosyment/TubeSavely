import 'emuns.dart';

class ExecuteModel {
  final String? key;
  double? progress;
  String? progressText;
  ExecuteStatus? status;
  String? path;

  ExecuteModel({required this.key, required this.progress, required this.progressText, this.status, this.path});
}
