import 'dart:convert';

import 'package:example/models/classfity/classfity.dart';
import 'package:example/store/loading.dart';
import 'package:example/utils/request.dart';
import 'package:fluent_ui/fluent_ui.dart';
import '../component/Chat.dart';
import '../../widgets/page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with PageMixin {
  bool selected = true;
  String? comboboxValue;
  String selectedContact = "";
  late List<Classify> fArray = [];

  final HttpService hp = HttpService();
  final LoadingEle loadingEle = LoadingEle();

  @override
  void initState() {
    setState(() {
      loadingEle.show();
    });
    super.initState();
    fetchData();
  }

  void fetchData() async {
    var response = await hp.getRequest("/classify/list", context: context);
    if (response["code"] == 0) {
      fArray = response["data"]
          .map((item) => Classify.fromJson(item))
          .toList()
          .cast<Classify>();
    }
    fArray.insert(
        0, Classify(id: 0, createdAt: "", updatedAt: "", cId: "", label: "全部"));
    var res = await hp.getRequest("/friendRelationship/list", context: context);
    if (res["code"] == 0) {
      for (var value in res["data"]) {
        for (var e in fArray) {
          if (value["classifyId"] == e.id) {
            setState(() {
              e.children.add(value); // 添加 value 到 children
            });
          }
        }
      }
    }
    setState(() {
      loadingEle.hidden();
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasFluentTheme(context));
    final theme = FluentTheme.of(context);

    return Padding(
        padding: const EdgeInsets.all(0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 200,
              height: double.infinity,
              decoration: const BoxDecoration(),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: fArray.length,
                  itemBuilder: (context, index) {
                    var contact = fArray[index];
                    return Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: Expander(
                          header: Text(contact.label),
                          content: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (contact.children.isNotEmpty)
                                ...contact.children.map((item) {
                                  return ListTile.selectable(
                                    leading: SizedBox(
                                      height: 20,
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: ColoredBox(
                                          color:
                                              Colors.accentColors[index ~/ 20],
                                          child: const Placeholder(),
                                        ),
                                      ),
                                    ),
                                    title: Text(item["friendInfo"]["nickname"]
                                        .substring(0, 8)),
                                    selectionMode: ListTileSelectionMode.single,
                                    selected:
                                        selectedContact == item['friendId'],
                                    onSelectionChange: (v) => setState(() {
                                      selectedContact =
                                          item['friendId'].toString();
                                    }),
                                  );
                                })
                            ],
                          ),
                        ));
                  }),
            ),
            if (selectedContact.isNotEmpty)
              ChatMessage(
                fId: selectedContact,
              )
          ],
        ));
  }
}

class SponsorButton extends StatelessWidget {
  const SponsorButton({
    super.key,
    required this.imageUrl,
    required this.username,
  });

  final String imageUrl;
  final String username;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imageUrl),
          ),
          shape: BoxShape.circle,
        ),
      ),
      Text(username),
    ]);
  }
}
