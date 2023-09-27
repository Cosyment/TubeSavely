import 'package:downloaderx/data/VideoParse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../constants/colors.dart';
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: const Text(
            "下载",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            color:bgColor,
            child: Column(
                children: List.generate(
                  dataList.length,
                      (index) {
                    var info = dataList[index];
                    return Container(
                      color: Colors.white,
                      margin: EdgeInsets.only(top: 10.w),
                      child: Padding(
                        padding: EdgeInsets.all(20.0.w),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16.r),
                              child: Container(child: Image.network(info.cover,
                                  fit: BoxFit.cover),
                                width: 240.w,
                                height: 160.w,),
                            ),
                            SizedBox(
                              width: 20.w,
                            ),
                            Expanded(
                              child: Container(
                                height: 320.w,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      info.title,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: 32.sp,
                                      ),
                                    ),
                                    Text(
                                      info.author,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: 28.sp,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          DateFormat("yyyy-MM-dd HH:mm")
                                              .format(DateTime.now())
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 24.sp,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 40.w,
                                        ),
                                        Text(
                                          info.size ?? "",
                                          style: TextStyle(
                                            fontSize: 20.sp,
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
                )),
          ),
        ));
  }
}
