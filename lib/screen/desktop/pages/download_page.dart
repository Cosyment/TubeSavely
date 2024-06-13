import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tubesavely/downloader/downloader.dart';
import 'package:tubesavely/extension/extension.dart';
import 'package:tubesavely/http/http_request.dart';
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
    print('--------------->>>>>url ${url}');
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
    super.build(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
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
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('立即下载'),
            )
          ],
        ),
        Expanded(
            child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 20),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black45),
            borderRadius: BorderRadius.circular(8),
          ),
          width: double.infinity,
          child: videoModelList.isEmpty
              ? const Center(
                  child: Text(
                    '请粘贴视频链接 e.g. https://www.youtube.com/watch?v=dQw4w9WgXcQ',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: videoModelList.length,
                  itemBuilder: (context, index) {
                    return _buildItem(videoModelList[index]);
                  }),
        ))
      ],
    );
  }

  _buildItem(VideoModel model) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          SizedBox(
              width: 100,
              height: 60,
              child: CachedNetworkImage(
                // imageUrl: model.thumbnail ?? '',
                imageUrl: 'http://e.hiphotos.baidu.com/image/pic/item/a1ec08fa513d2697e542494057fbb2fb4316d81e.jpg',
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
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                model.title ?? '',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                model.url ?? '',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              )
            ],
          )),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    Downloader.download(model.url, model.title);
                  },
                  icon: const Icon(Icons.save_alt)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.folder_open)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      videoModelList.remove(model);
                    });
                  },
                  icon: const Icon(Icons.delete)),
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
