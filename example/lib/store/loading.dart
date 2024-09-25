import 'package:fluent_ui/fluent_ui.dart';

class LoadingEle with ChangeNotifier {
  late bool _isLoading = false;

  bool get value => _isLoading;

  void show() {
    _isLoading = true;
    notifyListeners();
  }
  void hidden() {
    _isLoading = false;
    notifyListeners();
  }
}
