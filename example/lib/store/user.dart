import 'package:fluent_ui/fluent_ui.dart';

import '../models/Info/info.dart';

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
