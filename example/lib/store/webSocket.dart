import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:example/models/chatItem/chatItem.dart';
import 'package:example/utils/request.dart';
import 'package:fluent_ui/fluent_ui.dart';

import 'ChatMessage.dart';

class MSocket with ChangeNotifier {
  late WebSocket socket;
  late String url;
  final ChatMessageStore chatMessage;

  MSocket(this.chatMessage);

  Future<bool> connect(String id) async {
    url = "wss://${HttpService().value}/conn/ws/$id";
    try {
      socket = await WebSocket.connect(url);
      // 链接成功 事件处理方法
      _connectEvent();
      return true;
    } catch (e) {
      // 处理错误
      print(e);
      return false;
    }
  }

  void _connectEvent() {
    // 监听消息
    socket.listen(
      (message) {
        try {
          Map<String, dynamic> map = jsonDecode(message);
          ChatItem ci = ChatItem.fromJson(map);
          chatMessage.add(ci);
        } catch (err) {
          print(err);
        }
      },
      onError: (error) async {
        print('连接错误重试连接中。。。。');
        socket = await WebSocket.connect(url);
        print('连接错误: $error');
      },
      onDone: () async {
        print('连接错误重试连接中。。。。');
        socket = await WebSocket.connect(url);
      },
      cancelOnError: true,
    );
  }

  void send(ChatItem message) {
    chatMessage.add(message);
    socket.add(jsonEncode(message));
  }
}
