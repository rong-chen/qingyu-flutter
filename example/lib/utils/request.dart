import 'dart:convert';
import 'package:example/store/user.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';


class HttpService {
  final String _baseUrl = "127.0.0.1:8082";

  // 发送GET请求
  Future<Map<String, dynamic>> getRequest(String path,
      {Map<String, dynamic>? params, required BuildContext context}) async {
    final userStore = Provider.of<UserStore>(context, listen: false);
    final String token = userStore.token;
    final response = await http.get(
        Uri.parse("https://$_baseUrl$path").replace(queryParameters: params),
        headers: {
          "Authorization": token,
        });
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  // 发送POST请求
  Future<Map<String, dynamic>> postRequest(String path,
      {Map<String, dynamic>? body, required BuildContext context}) async {
    final userStore = Provider.of<UserStore>(context, listen: false);
    final String token = userStore.token;
    final response = await http
        .post(Uri.parse("https://$_baseUrl$path"), body: jsonEncode(body), headers: {
      "Content-Type": "application/json",
      "Authorization": token,
    });
    if (response.statusCode == 200) {
      var res = jsonDecode(response.body);
      if (res["token"] is String && res["token"] != "") {
        Provider.of<UserStore>(context, listen: false).setToken(res["token"]);
      }
      return res;
    } else {
      throw Exception('Failed to load data');
    }
  }
  String get value => _baseUrl;
}
