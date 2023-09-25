import 'package:downloaderx/data/VideoParse.dart';
import 'package:flutter/material.dart';

import '../data/DbManager.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  List<VideoParse> dataList = [];

  @override
  void initState() {
    super.initState();
    loadList();
  }

  void loadList() async {
    var list = await DbManager.instance().getAllType<VideoParse>();
    dataList.addAll(list);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListView.builder(
          controller: ScrollController(),
          itemCount: dataList.length,
          itemBuilder: (context, index) {
            var parse = dataList[index];
            return Row(
              children: [Text(parse.title), Text(parse.totalBytes.toString())],
            );
          },
        ));
  }
// final TextEditingController textController = TextEditingController();
}
