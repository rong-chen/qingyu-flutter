import 'package:fluent_ui/fluent_ui.dart';

import '../models/chatItem/chatItem.dart';

class ChatMessageStore with ChangeNotifier {
  late List<ChatItem> _chatList = [];

  List<ChatItem> get list => _chatList;

  void set(List<ChatItem> val) {
    _chatList = val;
    notifyListeners();
  }

  void add(ChatItem ci) {
    _chatList.add(ci);
  notifyListeners();
  }

  List<ChatItem> get(id) {
    List<ChatItem> list = [];
    try {
      for (var value in _chatList) {
        if(value.sender == id || value.receiver == id){
          list.add(value);
        }
      }
    } catch (err) {
      print(err);
    }
    return list;
  }
}
