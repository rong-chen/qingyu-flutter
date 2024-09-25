import 'package:fluent_ui/fluent_ui.dart';

class Info {
  final String username;
  final String nickname;
  final String? phone;
  final String? email;
  final String? birthDay;
  final String gender;
  final String id; // 使用小写 id 以符合 Dart 命名习惯
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Info({
    required this.username,
    required this.nickname,
    required this.gender,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.phone,
    this.email,
    this.birthDay,
  });

  // 从 JSON 创建 User 实例
  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(
      username: json['username'],
      nickname: json['nickname'],
      phone: json['phone'],
      email: json['email'],
      birthDay: json['birthDay'],
      gender: json['gender'],
      id: json['ID'],
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt: DateTime.parse(json['UpdatedAt']),
      deletedAt:
          json['DeletedAt'] != null ? DateTime.parse(json['DeletedAt']) : null,
    );
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'nickname': nickname,
      'phone': phone,
      'email': email,
      'birthDay': birthDay,
      'gender': gender,
      'ID': id,
      'CreatedAt': createdAt.toIso8601String(),
      'UpdatedAt': updatedAt.toIso8601String(),
      'DeletedAt': deletedAt?.toIso8601String(),
    };
  }
}

class UserStore with ChangeNotifier {
  late String _token = "";
  late Info _info;

  String get token => _token;

  Info get info => _info;

  void setToken(String str) {
    _token = str;
    notifyListeners();
  }

  void setUser(Map<String, dynamic> info) {
    _info = Info.fromJson(info);
    notifyListeners();
  }
}
