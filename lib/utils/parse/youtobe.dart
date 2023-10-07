import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../data/db_manager.dart';
import '../../data/video_parse.dart';
import '../../models/cover_info.dart';
import '../../models/video_info.dart';
import '../event_bus.dart';

class YouToBe {
  static YouToBe? _instance;
  late YoutubeExplode yt;

  factory YouToBe.get() {
    return _instance ??= YouToBe._init();
  }

  YouToBe._init() {
    yt = YoutubeExplode();
  }

  void close() {
    yt.close();
  }

  Future<void> parse(String parseUrl, Function onResult) async {
    List<VideoInfo> videoList = [];
    if (parseUrl.contains("https://www.youtube.com/live")) {
      onResult(videoList);
    } else {
      var video = await yt.videos.get(parseUrl);
      var thumbnails = video?.watchPage?.playerResponse?.root['videoDetails']
          ['thumbnail']['thumbnails'];
      List<dynamic> itemList = thumbnails;
      List<CoverInfo> coverInfoList = [];
      for (var element in itemList) {
        var coverInfo = CoverInfo.fromJson(element);
        coverInfoList.add(coverInfo);
      }
      var manifest = await yt.videos.streamsClient.getManifest(parseUrl);
      var list = manifest.streams
          .where((element) => element.container == StreamContainer.mp4)
          .sortByBitrate();
      var item1080p =
          list.firstWhere((element) => element.qualityLabel.contains('1080p'));
      if (item1080p != null) {
        videoList.add(VideoInfo(
            label: '1080p(mp4,不带音频)',
            totalBytes: item1080p.size.totalBytes,
            size: item1080p.size.toString(),
            url: item1080p.url.toString()));
      }
      var item720p =
          list.firstWhere((element) => element.qualityLabel.contains('720p'));
      if (item720p != null) {
        videoList.add(VideoInfo(
            label: '720p(mp4,带音频)',
            totalBytes: item720p.size.totalBytes,
            size: item720p.size.toString(),
            url: item720p.url.toString()));
      }
      var item480p =
          list.firstWhere((element) => element.qualityLabel.contains('480p'));
      if (item480p != null) {
        videoList.add(VideoInfo(
            label: '480p(mp4,不带音频)',
            totalBytes: item480p.size.totalBytes,
            size: item480p.size.toString(),
            url: item480p.url.toString()));
      }
      var item360p =
          list.firstWhere((element) => element.qualityLabel.contains('360p'));
      if (item360p != null) {
        videoList.add(VideoInfo(
            label: '360p(mp4,带音频)',
            totalBytes: item360p.size.totalBytes,
            size: item360p.size.toString(),
            url: item360p.url.toString()));
      }

      var item240p =
          list.firstWhere((element) => element.qualityLabel.contains('240p'));
      if (item240p != null) {
        videoList.add(VideoInfo(
          label: '240p(mp4,不带音频)',
          totalBytes: item240p.size.totalBytes,
          size: item240p.size.toString(),
          url: item240p.url.toString(),
        ));
      }
      // var item144p =
      //     list.firstWhere((element) => element.qualityLabel.contains('144p'));
      // if (item144p != null) {
      //   videoList.add(VideoInfo(
      //       label: '144p(mp4,带音频)',
      //       totalBytes: item144p.size.totalBytes,
      //       size: item144p.size.toString(),
      //       url: item144p.url.toString()));
      // }
      var coverInfo = coverInfoList.last;
      if (coverInfo != null) {
        videoList.add(VideoInfo(
            label: '封面',
            totalBytes: 0,
            size: "${coverInfo.width}x${coverInfo.height}",
            url: coverInfo.url.toString()));
      }

      VideoStreamInfo info = manifest.muxed.bestQuality;
      var videoParse = VideoParse(
          videoUrl: info.url.toString(),
          parseUrl: parseUrl,
          title: video.title,
          author: video.author,
          createTime: DateTime.now().millisecondsSinceEpoch,
          size: info.size.toString(),
          totalBytes: info.size.totalBytes,
          cover: coverInfoList.last.url,
          videoList: videoList);
      onResult(videoList);
      EventBus.getDefault().post(videoParse);
      DbManager.instance().add(videoParse);
    }
  }
}
