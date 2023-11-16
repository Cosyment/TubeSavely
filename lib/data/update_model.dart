class UpdataModel {
  bool? force;
  String? url;
  String? description;
  String? note;
  String? appVersion;
  int? appCode;
  int? status;

  UpdataModel(
      {this.force,
      this.url,
      this.description,
      this.note,
      this.appVersion,
      this.status});

  UpdataModel.fromJson(Map<String, dynamic> json) {
    force = json['is_force'] == 1;
    url = json['url'];
    description = json['description'];
    appVersion = json['title'];
    appCode = json['versionCode'];
    note = "";
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_force'] = force;
    data['url'] = url;
    data['description'] = description;
    data['title'] = appVersion;
    data['note'] = note;
    data['versionCode'] = appCode;
    data['status'] = status;
    return data;
  }

  static UpdataModel toBean(Map<String, dynamic> json) =>
      UpdataModel.fromJson(json);
}
