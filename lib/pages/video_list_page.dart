import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tubesavely/network/http_request.dart';
import 'package:tubesavely/pages/video_playback_page.dart';
import 'package:tubesavely/utils/common_util.dart';
import 'package:tubesavely/utils/constants.dart';

import '../models/video_info.dart';
import '../theme/app_theme.dart';

class VideoListPage extends StatefulWidget {
  final String url;

  const VideoListPage({super.key, required this.url});

  @override
  State<VideoListPage> createState() => _VideoListPageState();
}

class _VideoListPageState extends State<VideoListPage> {
  VideoInfo? videoInfo;
  List<FormatInfo>? formatInfoList;

  @override
  void initState() {
    super.initState();
    parse(widget.url);
  }

  void parse(String url) async {
    videoInfo = await HttpRequest.request<VideoInfo>(
        Urls.shortVideoParse,
        params: {'url': url},
        (jsonData) => VideoInfo.fromJson(jsonData),
        exception: (e) => {debugPrint('parse exception ${e}')});

    setState(() {
      formatInfoList = videoInfo?.formats?.where((value) => value.video_ext == 'mp4' && value.protocol != 'm3u8_native').toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('视频列表')),
        body: ListView.builder(
            itemCount: formatInfoList?.length ?? 10,
            itemBuilder: (context, index) {
              return _buildItem(videoInfo, formatInfoList == null ? null : formatInfoList?[index]);
            }));
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      // 基础颜色，通常为较暗的颜色
      highlightColor: Colors.grey.shade500,
      // 高亮颜色，闪烁时显示的颜色
      child: Container(
        decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10)),
        // width: 200.0,
        height: 120.0,
        // color: Colors.grey, // 占位容器的颜色，这里设置为透明以看到Shimmer效果
      ),
      // period: 1000,
      // 动画周期，单位毫秒
      // repeat: true, // 是否重复动画
    );
  }

  Widget _buildItem(VideoInfo? videoInfo, FormatInfo? formatInfo) {
    return Container(
        margin: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: <BoxShadow>[
            BoxShadow(color: Colors.grey.withOpacity(0.3), offset: const Offset(4, 4), blurRadius: 30),
          ],
        ),
        child: videoInfo == null || formatInfo == null
            ? _buildShimmer()
            : InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 300),
                      pageBuilder: (BuildContext context, _, __) =>
                          VideoPlaybackPage(title: videoInfo.title, url: formatInfo.url),
                      transitionsBuilder: (BuildContext context, Animation<double> animation,
                          Animation<double> secondaryAnimation, Widget child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 1.0),
                            end: Offset.zero, // 结束位置在屏幕原点
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => VideoPlaybackPage(title: videoInfo?.title, url: videoInfo?.formats?[index].url)));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRRect(
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10.0)),
                        child:
                            CachedNetworkImage(imageUrl: videoInfo.thumbnail ?? '', fit: BoxFit.cover, width: 130, height: 120)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          videoInfo.title ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(maxLines: 1, overflow: TextOverflow.ellipsis, videoInfo.uploader ?? ''),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          '${formatInfo.resolution?.toUpperCase() ?? formatInfo.format_note?.toUpperCase() ?? ''} ${CommonUtil.formatSize(formatInfo.filesize ?? 0)}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      ],
                    )),
                    const SizedBox(
                      width: 5,
                    )
                    // IconButton(
                    //     onPressed: () {
                    //       Common.download(videoInfo.formats?[index].url, videoInfo.title);
                    //     },
                    //     icon: const Icon(Icons.save_alt_outlined))
                  ],
                ),
              ));
  }
}
