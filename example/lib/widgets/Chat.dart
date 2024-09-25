import 'dart:async';

import 'package:example/models/chatItem/chatItem.dart';
import 'package:example/store/loading.dart';
import 'package:example/store/webSocket.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

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
    print(inputController.text);
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
        Container(
          height: MediaQuery.of(context).size.height * 0.7,
          constraints: const BoxConstraints(
            minHeight: 500, // 设置最小高度
          ),
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Card(
                child: Wrap(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Container(
                          height: 40,
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.white, width: 2))),
                          child: Align(
                            alignment: Alignment.center, // 垂直居中
                            child: Text(widget.fId.toString()),
                          ),
                        ))
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7 - 70,
                          child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Consumer<ChatMessageStore>(
                                builder: (context, chatNotifier, child) {
                                  List<ChatItem> ci =
                                      chatNotifier.get(widget.fId);
                                  return SingleChildScrollView(
                                      controller: _scrollController,
                                      child: Column(
                                        children:
                                            List.generate(ci.length, (index) {
                                          return Container(
                                            margin:
                                                const EdgeInsets.only(top: 20),
                                            child: Row(
                                              children: [
                                                if (widget.fId ==
                                                    ci[index].receiver)
                                                  Expanded(
                                                      child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
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
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0)),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              child: Text(
                                                                  ci[index]
                                                                      .message),
                                                            ),
                                                          ))
                                                    ],
                                                  ))
                                                else
                                                  Expanded(
                                                      child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
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
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0)),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(10),
                                                              child: Text(
                                                                  ci[index]
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
                                      ));
                                },
                              )),
                        )
                      ],
                    ),
                  ],
                ),
              )),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.3 - 70,
          margin: const EdgeInsets.only(left: 10, right: 10),
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
        )
      ],
    ));
  }
}
