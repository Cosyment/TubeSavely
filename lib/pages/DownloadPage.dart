import 'package:cached_network_image/cached_network_image.dart';
import 'package:downloaderx/data/VideoParse.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/colors.dart';
import '../data/DbManager.dart';
import '../widget/shimmer_image_widget.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  List<VideoParse> dataList = [];
  bool isShowShimmer = true;

  @override
  void initState() {
    super.initState();
    loadList();
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
          backgroundColor: primaryColor,
          title: const Text(
            "下载",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: RefreshIndicator(
            color: primaryColor,
            //下拉停止的距离
            displacement: 44.0.h,
            onRefresh: _refreshItems,
            child: Container(
              color: bgColor,
              child: ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (BuildContext context, int index) {
                  var info = dataList[index];
                  return Container(
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
                                    borderRadius: BorderRadius.circular(8.r)),
                              );
                            },
                            placeholder: (context, url) => ClipRRect(
                              borderRadius: BorderRadius.circular(16.r),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                  );
                },
              ),
            )));
  }

  Future<void> _refreshItems() async {
    loadList();
    await Future.delayed(Duration(seconds: 2));
    setState(() {});
  }
}
