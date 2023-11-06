import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_utils/common_utils.dart';
import 'package:downloaderx/constants/colors.dart';
import 'package:downloaderx/constants/constant.dart';
import 'package:downloaderx/pages/video_detail.dart';
import 'package:downloaderx/pages/video_montage_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '../data/video_parse.dart';
import '../generated/l10n.dart';
import '../utils/exit.dart';
import '../utils/parse/other.dart';
import '../utils/parse/youtobe.dart';
import '../utils/pub_method.dart';
import 'scrawl/content_page.dart';
import 'scrawl/scrawl_page.dart';
import 'video_parse_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  TextEditingController textController = TextEditingController(text: '');
  bool isLoading = false;
  bool isNeedVPN = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    PubMethodUtils.getSharedPreferences("InAppReview").then((value) {
      if (value == null) {
        PubMethodUtils.putSharedPreferences("InAppReview", "1");
        Future.delayed(const Duration(milliseconds: 1000 * 10), () {
          PubMethodUtils.getInAppReview();
        });
      }
    });
    PubMethodUtils.getSharedPreferences("userId").then((value) {
      if (value != null) {
        Constant.userId = value.toString();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var list =
          S.of(context).tvListTxt.split(', ').map((e) => e.trim()).toList();
      for (int i = 0; i < Constant.meList.length; i++) {
        var item = Constant.meList[i];
        item['title'] = list[i];
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          S.of(context).videoLinkWatermarkTxt,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.all(30.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  color: Theme.of(context).primaryColor,
                  child: Image.network(
                      "https://img.firefix.cn/downloaderx/banner.png",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 320.w),
                ),
              )
                  .animate()
                  .effect(
                      duration: 3000.ms)
                  .effect(delay: 750.ms, duration: 1500.ms)
                  .shimmer(),
              // child: CachedNetworkImage(
              //     imageUrl: "https://img.firefix.cn/downloaderx/banner.png",
              //     width: double.infinity,
              //     height: 320.w,
              //     imageBuilder: (context, imageProvider) {
              //       return Container(
              //         decoration: BoxDecoration(
              //             image: DecorationImage(
              //               image: imageProvider,
              //               fit: BoxFit.cover,
              //             ),
              //             borderRadius: BorderRadius.circular(24.r)),
              //       );
              //     },
              //     placeholder: (context, url) => ClipRRect(
              //           borderRadius: BorderRadius.circular(24.r),
              //           child: Shimmer.fromColors(
              //             baseColor: Colors.grey.shade300,
              //             highlightColor: Colors.grey.shade100,
              //             child:  Container(
              //               decoration: BoxDecoration(
              //                 color: Colors.transparent,
              //                 borderRadius: BorderRadius.circular(10.0),
              //               ),
              //             ),
              //           ),
              //         ),
              //     errorWidget: (context, url, error) => Container(
              //       decoration: BoxDecoration(
              //         color: Colors.grey,
              //         borderRadius: BorderRadius.circular(10.0),
              //       ),
              //     )),
            ),
          ),

          SliverToBoxAdapter(
            child: inputContainer(),
          ),
          SliverToBoxAdapter(
            child: actionRow(),
          ),
          SliverToBoxAdapter(
            child: Visibility(
              visible: isNeedVPN,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 20.w),
                  child: Text(
                    "该平台需要网络环境支持",
                    style: TextStyle(fontSize: 24.sp),
                  ),
                ),
              ),
            ),
          ),
          // SliverToBoxAdapter(
          //   child: widgetTop(context),
          // ),
          // SliverToBoxAdapter(
          //   child: Padding(
          //     padding: EdgeInsets.all(20.w),
          //     child: Text(
          //       S.of(context).tvClipTxt,
          //       style: TextStyle(
          //         fontSize: 40.sp,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ),
          // ),
          // buildChildLayout(),
        ],
      ),
    );
  }

  actionRow() {
    return Column(
      children: [
        SizedBox(height: 50.h),
        Align(
          alignment: Alignment.center,
          child: FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            shape: const CircleBorder(),
            onPressed: () {
              startParse();
            },
            child: isLoading
                ? LoadingAnimationWidget.hexagonDots(
                    color: Colors.white,
                    size: 40.h,
                  )
                : Image.asset(
                    "assets/next.png",
                    fit: BoxFit.fill,
                    width: 40.w,
                    height: 40.w,
                  ),
          ),
        )
      ],
    );
  }

  inputContainer() {
    return Column(
      children: [
        Container(
          height: 90.h,
          width: double.infinity,
          margin: EdgeInsets.all(30.w),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: TextField(
            maxLines: 1,
            textAlignVertical: TextAlignVertical.center,
            controller: textController,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => startParse(),
            style: TextStyle(color: Colors.white, fontSize: 30.sp),
            decoration: InputDecoration(
              hintText: "请输入视频地址",
              hintStyle: const TextStyle(color: Colors.white),
              border: const OutlineInputBorder(borderSide: BorderSide.none),
              focusedBorder:
                  const OutlineInputBorder(borderSide: BorderSide.none),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 15.w),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> startParse() async {
    var parseUrl = textController.text;
    try {
      Match? match =
          RegExp(r'http[s]?:\/\/[\w.]+[\w/]*[\w.]*\??[\w=&:\-+%]*[/]*')
              .firstMatch(parseUrl);
      var url = match?.group(0) ?? '';
      if (!url.contains('http')) {
        ToastExit.show("无法解析该链接地址");
        return;
      }
      setState(() {
        isLoading = true;
      });
      print(">>>>>>>>${url}");
      if (parseUrl.contains("youtu.be") || parseUrl.contains("youtube.com")) {
        isNeedVPN = true;
        YouToBe.get().parse(url, onResult);
      } else {
        isNeedVPN = false;
        Other.get().parse(url, onResult);
      }
    } catch (e) {
      print(">>>>>>>>>>>>>>>${e}");
      isLoading = false;
    }
  }

  void onResult(VideoParse? result) {
    // if (result != null) {
    //   Navigator.push(context,
    //       MaterialPageRoute(builder: (context) => VideoDetail(bean: result)));
    // }
    isLoading = false;
    if (result != null && result.videoList.isNotEmpty) {
      setState(() {});
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VideoDetailPage(bean: result)));
    } else {
      ToastExit.show("解析失败");
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getPaste();
    }
  }

  getPaste() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!TextUtil.isEmpty(data?.text)) {
      showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("提示"),
            content: Text("提取剪贴板中的链接吗？"),
            actions: [
              CupertinoDialogAction(
                child: const Text("取消"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                child: const Text("提取"),
                onPressed: () {
                  Navigator.of(context).pop();
                  textController.text = data?.text ?? "";
                  startParse();
                  Clipboard.setData(const ClipboardData(text: ''));
                },
              ),
            ],
          );
        },
      );
    }
  }

  widgetTop(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(width: 20.w),
        Expanded(
          child: Card(
            elevation: 1,
            clipBehavior: Clip.hardEdge,
            color: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.r)),
            ),
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              child: Container(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.of(context).videoLinkWatermarkRemovalTxt,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30.sp,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.link,
                        color: Colors.white,
                        size: 80.w,
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => VideoParePage()));
              },
            ),
          ),
        ),
        SizedBox(width: 20.w),
      ],
    );
  }

  buildChildLayout() {
    return SliverPadding(
      padding: EdgeInsets.all(20.w),
      sliver: SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1 / 0.9,
        ),
        itemCount: Constant.meList.length,
        itemBuilder: (BuildContext context, int index) {
          var item = Constant.meList[index];
          return Card(
            elevation: 1,
            clipBehavior: Clip.hardEdge,
            color: primaryColor,
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () async {
                await skipSelectPhoto(context, item);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Image(
                  //   image: AssetImage("assets/images/${item['bg']}"),
                  //   width: 100.w,
                  //   height: 100.w,
                  //   fit: BoxFit.fill,
                  // ),
                  Icon(
                    item['icon'] as IconData?,
                    color: Colors.white,
                    size: 60.w,
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Text(
                      item['title'].toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> skipSelectPhoto(
      BuildContext context, Map<String, Object> item) async {
    List<AssetEntity>? result = await AssetPicker.pickAssets(context,
        pickerConfig: AssetPickerConfig(
          themeColor: primaryColor,
          maxAssets: 1,
          requestType: item['type'] as RequestType,
        ));
    if (result != null) {
      var file2 = await result[0].file;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VideoMontagePage(
                    file: file2!,
                    title: item['title'].toString(),
                  )));
    }
  }
}
