import 'package:cached_network_image/cached_network_image.dart';
import 'package:downloaderx/data/video_parse.dart';
import 'package:downloaderx/pages/voide_parse_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/colors.dart';
import '../data/db_manager.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<VideoParse> dataList = [];
  bool isShowShimmer = true;

  @override
  void initState() {
    super.initState();
    loadList();

    // EventBus.getDefault().register(null, (event) {
    //   if (event is VideoParse) {
    //     dataList.add(event);
    //   } else if (event is String) {
    //     if (event == "clear") {
    //       dataList.clear();
    //       DbManager.db!.clear();
    //     }
    //   }
    //   setState(() {});
    // });
  }

  void loadList() async {
    var list = await DbManager.instance().getAllType<VideoParse>();
    dataList.clear();
    dataList.addAll(list);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            "解析记录",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: RefreshIndicator(
          color: primaryColor,
          displacement: 44.0.h,
          onRefresh: _refreshItems,
          child: dataList.length > 0
              ? CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          var info = dataList[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          VideoParePage(bean: info)));
                            },
                            child: Container(
                              color: Colors.white,
                              margin: EdgeInsets.only(top: 10.w),
                              child: Padding(
                                padding: EdgeInsets.all(20.0.w),
                                child: Row(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: info.cover,
                                      width: 240.w,
                                      height: 320.w,
                                      imageBuilder: (context, imageProvider) {
                                        return Container(
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8.r)),
                                        );
                                      },
                                      placeholder: (context, url) => ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        child: Shimmer.fromColors(
                                          baseColor: Colors.grey.shade300,
                                          highlightColor: Colors.grey.shade100,
                                          child: Container(
                                            child: Image.network(
                                              info.cover,
                                              fit: BoxFit.cover,
                                            ),
                                            width: 240.w,
                                            height: 320.w,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                    SizedBox(
                                      width: 20.w,
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 320.w,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                                                      .format(DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              info.createTime))
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
                            ),
                          );
                        },
                        childCount: dataList.length,
                      ),
                    )
                  ],
                )
              : Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 120.h,
                      ),
                      Lottie.asset(
                        'assets/lottie/emptybox.json',
                        width: 160,
                        height: 160,
                        fit: BoxFit.fill,
                      ),
                      Text(
                        '暂无记录',
                        style: TextStyle(fontSize: 28.sp, color: Colors.grey),
                      )
                    ],
                  ),
                ),
        ));
  }

  Future<void> _refreshItems() async {
    loadList();
    await Future.delayed(Duration(seconds: 2));
    setState(() {});
  }
}
