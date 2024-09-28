import 'dart:async';

import 'package:example/models/chatItem/chatItem.dart';
import 'package:example/store/loading.dart';
import 'package:example/store/user.dart';
import 'package:example/store/webSocket.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../store/ChatMessage.dart';

class ChatMessage extends StatefulWidget {
  final String fId;

  const ChatMessage({
    Key? key,
    required this.fId,
  }) : super(key: key);

  @override
  Windows createState() => Windows();
}

class Windows extends State<ChatMessage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController inputController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    } else {
      print(_scrollController);
    }
  }

  void sendMessage() {
    MSocket mSocket = MSocket();
    Map<String, dynamic> map = ChatItem.toJson(
        Provider.of<UserStore>(context, listen: false).info.id,
        widget.fId,
        'text',
        inputController.text,
        "");
    mSocket.send(map);
    inputController.text = "";
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final chatMessageStore = Provider.of<ChatMessageStore>(context);
    chatMessageStore.addListener(() {
      scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // 确保在 dispose 时清理
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LoadingEle>(context, listen: false).show();
      scrollToBottom();
      Provider.of<LoadingEle>(context, listen: false).hidden();
    });
    // TODO: implement build
    return Expanded(
        child: Column(
      children: [
        Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
            child: Card(
              child: Wrap(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Container(
                        decoration: BoxDecoration(
                            border: Border(
                                bottom:
                                    BorderSide(color: Colors.grey[30], width: 2))),
                        child: Text(widget.fId.toString()),
                      ))
                    ],
                  ),
                  Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Padding(
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width * 0.01,
                                  right:
                                      MediaQuery.of(context).size.width * 0.01),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.7 -
                                        70,
                                child: Consumer<ChatMessageStore>(
                                  builder: (context, chatNotifier, child) {
                                    List<ChatItem> ci = chatNotifier.get(widget.fId);
                                    return SingleChildScrollView(
                                        controller: _scrollController,
                                        child: Container(
                                          constraints: BoxConstraints(
                                            maxHeight: constraints.maxHeight,
                                          ),
                                          child: Column(
                                            children: List.generate(ci.length,
                                                (index) {
                                              return Container(
                                                margin: EdgeInsets.only(
                                                    top: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.01),
                                                child: Row(
                                                  children: [
                                                    if (widget.fId ==
                                                        ci[index].receiver)
                                                      Expanded(
                                                          child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            width: 50,
                                                            height: 50,
                                                            child: Image.asset(
                                                                "assets/images/qingyu.png"),
                                                          ),
                                                          Container(
                                                              constraints:
                                                                  BoxConstraints(
                                                                maxWidth: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.6,
                                                                // 最大宽度为 60%
                                                                minWidth:
                                                                    50, // 最小宽度为 50
                                                              ),
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0)),
                                                                child: Padding(
                                                                  padding: EdgeInsets.only(
                                                                      left: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.01,
                                                                      right: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.01),
                                                                  child: Text(ci[
                                                                          index]
                                                                      .message),
                                                                ),
                                                              ))
                                                        ],
                                                      ))
                                                    else
                                                      Expanded(
                                                          child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Container(
                                                              constraints:
                                                                  BoxConstraints(
                                                                maxWidth: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.6,
                                                                // 最大宽度为 60%
                                                                minWidth:
                                                                    50, // 最小宽度为 50
                                                              ),
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0)),
                                                                child: Padding(
                                                                  padding: EdgeInsets.only(
                                                                      left: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.01,
                                                                      right: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.01),
                                                                  child: Text(ci[
                                                                          index]
                                                                      .message),
                                                                ),
                                                              )),
                                                          SizedBox(
                                                            width: 50,
                                                            height: 50,
                                                            child: Image.asset(
                                                                "assets/images/qingyu.png"),
                                                          ),
                                                        ],
                                                      ))
                                                  ],
                                                ),
                                              );
                                            }),
                                          ),
                                        ));
                                  },
                                ),
                              ));
                        },
                      )
                    ],
                  ),
                ],
              ),
            )),
        Expanded(
            child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
          child: Card(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommandBar(
                    isCompact: true,
                    overflowBehavior: CommandBarOverflowBehavior.noWrap,
                    primaryItems: [
                      CommandBarButton(
                        icon: const Icon(FluentIcons.microphone),
                        label: const Text('Move'),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                  child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Row(
                  children: [
                    Expanded(
                        child: TextBox(
                      controller: inputController,
                      maxLines: null,
                    )),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      children: [
                        Expanded(
                            child: Button(
                                onPressed: sendMessage,
                                child: const Text("发送")))
                      ],
                    )
                  ],
                ),
              ))
            ],
          )),
        ))
      ],
    ));
  }
}
