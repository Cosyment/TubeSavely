import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tubesavely/core/downloader/downloader.dart';
import 'package:tubesavely/extension/extension.dart';
import 'package:tubesavely/generated/l10n.dart';
import 'package:tubesavely/http/http_request.dart';
import 'package:tubesavely/model/emuns.dart';
import 'package:tubesavely/model/pair.dart';
import 'package:tubesavely/model/video_model.dart';
import 'package:tubesavely/storage/storage.dart';
import 'package:tubesavely/utils/constants.dart';
import 'package:tubesavely/utils/platform_util.dart';
import 'package:tubesavely/utils/resolution_util.dart';
import 'package:tubesavely/utils/toast_util.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({super.key});

  @override
  State<StatefulWidget> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> with AutomaticKeepAliveClientMixin<DownloadPage> {
  List<VideoModel> videoModelList = [];
  List<String> taskList = [];

  Map<String, double> progressMap = {};
  Map<String, String> progressTextMap = {};
  Map<String, ExecuteStatus> statusMap = {};

  void _extractVideo(String url) async {
    if (!url.isValidUrl()) {
      ToastUtil.error(S.current.toastLinkInvalid);
      return;
    }
    ToastUtil.loading();
    VideoModel videoModel = await HttpRequest.request<VideoModel>(
        Urls.shortVideoParse,
        params: {'url': url},
        (jsonData) => VideoModel.fromJson(jsonData),
        exception: (e) => {debugPrint('parse exception $e'), ToastUtil.error(S.current.toastVideoExecuteError)});

    setState(() {
      videoModelList.add(videoModel);

      taskList.add(url);
      ToastUtil.dismiss();
    });
  }

  Pair<List<FormatModel>, List<FormatModel>> _duplicateFormat(VideoModel model) {
    //过滤全部全部视频
    List<FormatModel>? videoList = model.formats?.where((value) => value.video_ext == 'mp4').toList();
    //过滤全部m3u8视频（主要处理类似youtube返回相同分辨率的mp4和m3u8场景）
    videoList = (videoList?.every((element) => element.protocol == 'm3u8_native') ?? false)
        ? videoList
        : videoList?.where((element) => element.protocol != 'm3u8_native').toList();
    //根据分辨率去重
    videoList = [
      ...{for (var person in videoList as Iterable) person?.resolution: person}.values
    ];

    List<FormatModel>? audioList = model.formats
        ?.where((value) => (value.audio_ext == 'm4a' || value.audio_ext == 'webm') && value.protocol != 'm3u8_native')
        .toList();
    return Pair(videoList, audioList);
  }

  void _download(VideoModel model) async {
    setState(() {
      progressMap[model.original_url ?? ''] = 0;
      statusMap[model.original_url ?? ''] = ExecuteStatus.Executing;
      progressTextMap[model.original_url ?? ''] = S.current.statusDownloadProgress;
    });

    final quality = Storage().getString(StorageKeys.DOWNLOAD_QUALITY_KEY);
    List<FormatModel>? videoList = _duplicateFormat(model).first;
    List<FormatModel>? audioList = _duplicateFormat(model).second;
    FormatModel? target = videoList?.firstWhere((item) => VideoResolutionUtil.format(item.resolution ?? '') == quality,
        orElse: () => videoList.first);

    Downloader.start(target?.url ?? '', model.title ?? '',
        audioUrl: audioList?.isEmpty == true ? null : audioList?[1].url,
        resolution: VideoResolutionUtil.format(target?.resolution ?? ''), onProgress: (type, value) {
      setState(() {
        progressMap[model.original_url ?? ''] = value;
        if (type == ProgressType.download) {
          progressTextMap[model.original_url ?? ''] = S.current.statusDownloadProgress;
        } else if (type == ProgressType.recode) {
          progressTextMap[model.original_url ?? ''] = S.current.statusRecodeProgress;
        } else if (type == ProgressType.merge) {
          progressTextMap[model.original_url ?? ''] = S.current.statusMergeProgress;
        }
        if (value >= 100) {
          statusMap[model.original_url ?? ''] = ExecuteStatus.Success;
          progressTextMap[model.original_url ?? ''] = S.current.statusComplete;
        }
      });
    }, onFailure: (error) {
      setState(() {
        statusMap[model.original_url ?? ''] = ExecuteStatus.Idle;
        progressMap[model.original_url ?? ''] = 0;
        progressTextMap[model.original_url ?? ''] = S.current.statusFailed;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                  overlayColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
              onPressed: () async {
                String? result = await getClipboardData();
                if (result?.isNotEmpty == true) {
                  if (taskList.contains(result)) {
                    ToastUtil.error(S.current.toastLinkExists);
                  } else {
                    _extractVideo(result!);
                  }
                } else {
                  ToastUtil.error(S.current.toastLinkEmpty);
                }
              },
              child: Text(
                S.current.parseLink,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                  overlayColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
              onPressed: () async {
                videoModelList.forEach((model) async {
                  if (statusMap[model.original_url ?? ''] == null) {
                    _download(model);
                  }
                });
              },
              child: Text(S.current.downloadNow, style: TextStyle(color: Theme.of(context).primaryColor)),
            )
          ],
        ),
        Expanded(
            child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 20),
          padding: const EdgeInsets.symmetric(vertical: 0),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          width: double.infinity,
          child: videoModelList.isEmpty
              ? Center(
                  child: Text(
                    S.current.downloadTips,
                    style: const TextStyle(color: Colors.grey),
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
      margin: const EdgeInsets.only(top: 15, bottom: 0, left: 10, right: 10),
      width: double.infinity,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
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
                errorWidget: (context, url, error) => Image.asset('assets/ic_logo.png'),
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
                maxLines: 1,
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(
                height: 5,
              ),
              model.original_url != null
                  ? Text(
                      model.original_url ?? '',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                      maxLines: 1,
                    )
                  : const SizedBox(),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                      child: LinearProgressIndicator(
                    value: (progressMap[model.original_url] ?? 0) / 100,
                    minHeight: 2,
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(50),
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  )),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                      '${progressTextMap[model.original_url] ?? ''} ${(progressMap[model.original_url]?.toStringAsFixed(2) ?? 0)}%',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)))
                ],
              )
            ],
          )),
          Row(
            children: [
              statusMap[model.original_url ?? ''] == ExecuteStatus.Executing
                  ? Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).primaryColor,
                      ))
                  : IconButton(
                      onPressed: () {
                        if (model.formats == null) {
                          return;
                        }
                        _download(model);
                      },
                      icon: Icon(
                        Icons.save_alt,
                        color: Theme.of(context).primaryColor.withOpacity(0.8),
                      )),
              IconButton(
                  onPressed: () {
                    launchUrlString(
                        Uri.file(Storage().getString(StorageKeys.CACHE_DIR_KEY) ?? '', windows: PlatformUtil.isWindows)
                            .toString());
                  },
                  icon: const Icon(
                    Icons.folder_open,
                    color: Colors.grey,
                  )),
              IconButton(
                  onPressed: () {
                    setState(() {
                      videoModelList.remove(model);
                      statusMap.remove(model.original_url ?? '');
                      progressMap.remove(model.original_url ?? '');
                      progressTextMap.remove(model.original_url ?? '');
                      taskList.remove(model.original_url);
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
