import 'dart:io';

import 'package:example/models/chatItem/chatItem.dart';
import 'package:example/store/ChatMessage.dart';
import 'package:example/store/loading.dart';
import 'package:example/store/user.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../main.dart';
import '../store/webSocket.dart';
import '../utils/request.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginStatePage createState() => LoginStatePage();
}

class LoginStatePage extends State<LoginPage>
    with WindowListener, TrayListener {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final loading = LoadingEle();

  void loginHandler() async {
    Provider.of<LoadingEle>(context, listen: false).show();
    HttpService hs = HttpService();
    try {
      var res = await hs.postRequest("/user/login",
          body: {
            "password": passwordController.text,
            "username": usernameController.text
          },
          context: context);
      if (res['code'] == 0) {
        // 获取用户信息
        var resp = await hs.getRequest("/user/info", context: context);
        if (resp["code"] == 0) {
          try {
            Provider.of<UserStore>(context, listen: false)
                .setUser(resp["data"]);
          } catch (err) {
            print(err);
          }
        } else {
          getUserError(context);
        }
        // 获取聊天记录
        var re = await hs.getRequest("/chat/list", context: context);
        if (re["code"] == 0) {
          List<dynamic> list = re["data"];
          try {
            List<ChatItem> cList = list.map((el) {
              return ChatItem.fromJson(el);
            }).toList();
            Provider.of<ChatMessageStore>(context, listen: false).set(cList);
            MSocket mSocket = MSocket();
            bool b = await mSocket.connect(resp["data"]['ID']);
            if (b) {
              context.go("/home");
            } else {
              getUserError(context);
            }
          } catch (err) {
            print(err);
          }
        }
      } else {
        loginFailed(context);
      }
      Provider.of<LoadingEle>(context, listen: false).hidden();
    } catch (err) {
      Provider.of<LoadingEle>(context, listen: false).hidden();
    }
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this); // 添加窗口监听器
    trayManager.addListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            Expanded(
                child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: const Color(0xFF2196F3), // 蓝色
                    child: Center(
                      child: DragToMoveArea(
                        child: Image.asset("assets/images/login.png"),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Expanded(child: WindowButtons())],
                        ),
                      ),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.2),
                            child: Image.asset(
                              "assets/images/qingyu.png",
                            ),
                          ),
                          SizedBox(
                              width: 300,
                              child: Column(
                                children: [
                                  Form(
                                      key: _formKey,
                                      child: Center(
                                        child: Column(
                                          children: [
                                            PasswordFormBox(
                                              validator: (text) {
                                                if (text == null) return null;
                                                if (text.isEmpty) {
                                                  return '请输入帐号';
                                                }
                                                return null;
                                              },
                                              placeholder: "帐号",
                                              revealMode:
                                                  PasswordRevealMode.visible,
                                              autovalidateMode:
                                                  AutovalidateMode.onUnfocus,
                                              controller: usernameController,
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 20),
                                              child: PasswordFormBox(
                                                validator: (text) {
                                                  if (text == null) return null;
                                                  if (text.isEmpty) {
                                                    return '请输入密码';
                                                  }
                                                  return null;
                                                },
                                                placeholder: "密码",
                                                revealMode: PasswordRevealMode
                                                    .peekAlways,
                                                autovalidateMode:
                                                    AutovalidateMode.onUnfocus,
                                                controller: passwordController,
                                              ),
                                            ),
                                            Container(
                                              width: 300,
                                              margin: const EdgeInsets.only(
                                                  top: 20),
                                              child: FilledButton(
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text("登录"),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10),
                                                        child: Icon(FluentIcons
                                                            .double_chevron_right8),
                                                      ),
                                                    ],
                                                  ),
                                                  onPressed: () =>
                                                      loginHandler()),
                                            )
                                          ],
                                        ),
                                      )),
                                ],
                              ))
                        ],
                      ))
                    ],
                  ))
                ],
              ),
            ))
          ],
        ),
      ],
    );
  }

  @override
  void onTrayIconMouseDown() {
    windowManager.show();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
    print("onTrayIconRightMouseDown");
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == '退出') {
      windowManager.hide();
      windowManager.close();
      windowManager.destroy();
    }
  }

  @override
  void dispose() {
    super.dispose();
    trayManager.removeListener(this);
    windowManager.removeListener(this);
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted) {
      showDialog(
        context: context,
        builder: (_) {
          return ContentDialog(
            title: const Text('操作'),
            content: const Text('是否要最小化到托盘栏'),
            actions: [
              FilledButton(
                child: const Text('确定'),
                onPressed: () {
                  Navigator.pop(context);
                  windowManager.hide();
                },
              ),
              Button(
                child: const Text('退出'),
                onPressed: () {
                  Navigator.pop(context);
                  windowManager.close();
                  windowManager.destroy();
                },
              ),
            ],
          );
        },
      );
    }
  }
}

void loginFailed(BuildContext context) async {
  await showDialog<String>(
    context: context,
    builder: (context) => ContentDialog(
      title: const Text('登录失败'),
      content: const Text(
        '帐号密码不匹配',
      ),
      actions: [
        FilledButton(
          child: const Text('关闭'),
          onPressed: () => Navigator.pop(context, '关闭'),
        ),
      ],
    ),
  );
}

void getUserError(BuildContext context) async {
  await showDialog<String>(
    context: context,
    builder: (context) => ContentDialog(
      title: const Text('网络错误'),
      content: const Text(
        '网络错误，请稍后再试',
      ),
      actions: [
        FilledButton(
          child: const Text('关闭'),
          onPressed: () => Navigator.pop(context, '关闭'),
        ),
      ],
    ),
  );
}
