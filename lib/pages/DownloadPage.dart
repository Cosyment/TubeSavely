import 'package:downloaderx/data/VideoParse.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../data/DbManager.dart';

class DownloadPage extends StatefulWidget {
   DownloadPage({Key? key}) : super(key: key);

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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: primaryColor,
          title:  Text(
            "下载",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Container(
            color: bgColor,
            height: double.infinity,
            child: ListView.builder(
              shrinkWrap: true,
              // physics: const NeverScrollableScrollPhysics(),
              itemCount: dataList.length,
              itemBuilder: (context, index) {
                var info = dataList[index];
                return Container(
                  color: Colors.white,
                  margin:  EdgeInsets.only(top: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(info.cover,
                              width: 120, height: 160, fit: BoxFit.cover),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Container(
                            height: 160,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  info.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  info.author,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      info.totalBytes.toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    Icon(
                                      Icons.download,
                                      color: Colors.grey,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            )));
  }
}
