import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tubesavely/core/downloader/downloader.dart';
import 'package:tubesavely/extension/extension.dart';
import 'package:tubesavely/http/http_request.dart';
import 'package:tubesavely/theme/app_theme.dart';
import 'package:tubesavely/utils/toast_util.dart';

import '../../../model/video_model.dart';
import '../../../utils/constants.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<StatefulWidget> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> with AutomaticKeepAliveClientMixin<DownloadPage> {
  List<VideoModel> videoModelList = [];
  List<FormatModel>? videoList;
  List<FormatModel>? audioList;

  void _extractVideo(String url) async {
    if (!url.isValidUrl()) {
      ToastUtil.error('请输入正确的链接');
      return;
    }
    ToastUtil.loading();
    VideoModel videoModel = await HttpRequest.request<VideoModel>(
        Urls.shortVideoParse,
        params: {'url': url},
        (jsonData) => VideoModel.fromJson(jsonData),
        exception: (e) => {debugPrint('parse exception $e')});

    setState(() {
      videoModelList.add(videoModel);
      //过滤全部全部视频
      videoList = videoModel.formats?.where((value) => value.video_ext == 'mp4').toList();
      //过滤全部m3u8视频（主要处理类似youtube返回相同分辨率的mp4和m3u8场景）
      videoList = (videoList?.every((element) => element.protocol == 'm3u8_native') ?? false)
          ? videoList
          : videoList?.where((element) => element.protocol != 'm3u8_native').toList();
      //根据分辨率去重
      videoList = [
        ...{for (var person in videoList as Iterable) person?.resolution: person}.values
      ];

      audioList = videoModel.formats
          ?.where((value) => (value.audio_ext == 'm4a' || value.audio_ext == 'webm') && value.protocol != 'm3u8_native')
          .toList();

      ToastUtil.dismiss();
    });
  }

  @override
  void initState() {
    super.initState();
    // getClipboardData();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    super.build(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.accentColor.withOpacity(0.2)),
                  overlayColor: AppTheme.accentColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
              onPressed: () async {
                String? result = await getClipboardData();
                if (result?.isNotEmpty == true) {
                  _extractVideo(result!);
                } else {
                  ToastUtil.error('请先复制视频链接');
                }
              },
              child: const Text(
                '粘贴链接',
                style: TextStyle(color: AppTheme.accentColor),
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.accentColor.withOpacity(0.2)),
                  overlayColor: AppTheme.accentColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
              onPressed: () {},
              child: const Text('立即下载', style: TextStyle(color: AppTheme.accentColor)),
            )
          ],
        ),
        Expanded(
            child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 20),
          padding: const EdgeInsets.symmetric(vertical: 0),
          decoration: BoxDecoration(
            // color: Colors.white,
            border: Border.all(color: isLightMode ? Colors.black12 : Colors.white12),
            borderRadius: BorderRadius.circular(8),
          ),
          width: double.infinity,
          child: videoModelList.isEmpty
              ? const Center(
                  child: Text(
                    '请粘贴视频链接 e.g. https://www.example.com/watch?v=dQw4w9WgXcQ',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: videoModelList.length,
                  itemBuilder: (context, index) {
                    return _buildItem(isLightMode, videoModelList[index]);
                  }),
        ))
      ],
    );
  }

  _buildItem(bool isLightMode, VideoModel model) {
    return Container(
      margin: const EdgeInsets.only(top: 15, bottom: 0, left: 10, right: 10),
      width: double.infinity,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        color: isLightMode ? Colors.white : Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: isLightMode ? Colors.grey.withOpacity(0.5) : Colors.grey.shade900.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
              width: 130,
              height: 90,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))),
              child: CachedNetworkImage(
                imageUrl: model.thumbnail ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(
                  width: 20,
                  height: 20,
                  child: Center(
                      child: CircularProgressIndicator(
                    color: Colors.grey,
                  )),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              )),
          const SizedBox(
            width: 10,
          ),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                model.title ?? '',
                style: TextStyle(fontSize: 16, color: isLightMode ? Colors.black87 : Colors.white),
              ),
              const SizedBox(
                height: 5,
              ),
              model.original_url != null
                  ? Text(
                      model.original_url ?? '',
                      style: TextStyle(fontSize: 12, color: isLightMode ? Colors.black54 : Colors.white54),
                      maxLines: 1,
                    )
                  : const SizedBox(),
            ],
          )),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    Downloader.download(model.url, model.title);
                  },
                  icon: Icon(
                    Icons.save_alt,
                    color: AppTheme.accentColor.withOpacity(0.8),
                  )),
              IconButton(
                  onPressed: () {
                    FilePicker.platform.getDirectoryPath(
                      dialogTitle: '打开文件',
                    );
                  },
                  icon: const Icon(
                    Icons.folder_open,
                    color: Colors.grey,
                  )),
              IconButton(
                  onPressed: () {
                    setState(() {
                      videoModelList.remove(model);
                    });
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.grey,
                  )),
            ],
          )
        ],
      ),
    );
  }

  Future<String?> getClipboardData() async {
    try {
      final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      // Clipboard.setData(const ClipboardData(text: ''));
      return data?.text;
    } on PlatformException catch (e) {
      if (e.details.contains('Permission denied')) {
        debugPrint('User denied the permission to access the clipboard.');
      } else {
        debugPrint('Failed to get clipboard data: ${e.toString()}');
      }
    }
    return null;
  }

  @override
  bool get wantKeepAlive => true;
}
