import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_editor/video_editor.dart';
import 'package:fraction/fraction.dart';
import '../utils/export_service.dart';

class VideoMontagePage extends StatefulWidget {
  const VideoMontagePage({super.key});

  @override
  State<VideoMontagePage> createState() => _VideoMontagePageState();
}

class _VideoMontagePageState extends State<VideoMontagePage> {
  late VideoEditorController controller;
  late File file = File("");
  var title = "";

  Widget viewer = Container();
  Widget child = Container();

  var variableSpeedValue = 1.0;

  var exportingProgress = ValueNotifier<double>(0.0);
  var isExporting = ValueNotifier<bool>(false);
  late VideoFFmpegVideoEditorConfig config;
  double height = 60;

  @override
  void initState() {
    super.initState();

    controller = VideoEditorController.file(
      file,
      minDuration: const Duration(seconds: 1),
      maxDuration: const Duration(seconds: 10),
    );
    controller.initialize(aspectRatio: 9 / 16).then((_) {
      setState(() {});
    }).catchError((error) {}, test: (e) => e is VideoMinDurationError);

    switch (title) {
      case "视频裁剪":
        viewer = widgetViewer();
        config = VideoFFmpegVideoEditorConfig(
          controller,
        );
        break;
      case "视频剪辑":
        break;
      case "视频倒放":
        viewer = widgetViewer1();
        config = VideoFFmpegVideoEditorConfig(
          controller,
          format: VideoExportFormat.mp4,
          commandBuilder: (config, videoPath, outputPath) {
            return '-i $videoPath -vf reverse -q:v 0 -b:v 2M -y $outputPath';
          },
        );
        break;
      case "视频旋转":
        viewer = widgetViewer();
        break;
      case "视频变速":
        viewer = widgetViewer1();
        config = VideoFFmpegVideoEditorConfig(
          controller,
          format: VideoExportFormat.mp4,
          commandBuilder: (config, videoPath, outputPath) {
            return '-i $videoPath -filter:v setpts=${variableSpeedValue}*PTS -q:v 0 -b:v 2M -y $outputPath';
          },
        );
        break;
      case "视频压缩":
        viewer = widgetViewer1();
        break;
      case "视频截图":
        break;
      case "视频合并":
        break;
      case "视频转GIF":
        viewer = widgetViewer();
        config = VideoFFmpegVideoEditorConfig(
          controller,
          format: const GifExportFormat(),
        );
        break;
      case "视频镜像":
        viewer = widgetViewer1();
        config = VideoFFmpegVideoEditorConfig(
          controller,
          format: VideoExportFormat.mp4,
          commandBuilder: (config, videoPath, outputPath) {
            return '-i $videoPath -vf hflip -q:v 0 -b:v 2M  -y $outputPath';
          },
        );
        break;
      case "视频去声音":
        config = VideoFFmpegVideoEditorConfig(
          controller,
          commandBuilder: (config, videoPath, outputPath) {
            return '-i $videoPath -q:v 0 -b:v 2M -an -c copy -y $outputPath';
          },
        );
        break;
      case "提取音频":
        config = VideoFFmpegVideoEditorConfig(
          controller,
          commandBuilder: (config, videoPath, outputPath) {
            return '-i $videoPath -vn -c:a copy -y $outputPath';
          },
        );
        break;
      case "修改md5":
        config = VideoFFmpegVideoEditorConfig(
          controller,
          commandBuilder: (config, videoPath, outputPath) {
            return '-i $videoPath -metadata md5=123456 -y $outputPath';
          },
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .apply(displayColor: Theme.of(context).colorScheme.onSurface)
              .titleMedium,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.w),
          child: Column(
            children: [
              Expanded(
                child: viewer,
              ),
              SizedBox(height: 15.w),
              widgetType(),
              widgetBottom()
            ],
          ),
        ),
      ),
    );
  }

  widgetType() {
    switch (title) {
      case "视频裁剪":
        return widgetProportionalCrop(context);
      case "视频剪辑":
      case "视频倒放":
      case "视频旋转":
        return widgetRotate();
      case "视频变速":
        return widgetVariableSpeed();
      case "视频压缩":
        return widgetQuality();
      case "视频截图":
      case "视频合并":
      case "视频转GIF":
      case "视频镜像":
        return widgetMirror();
      case "视频去声音":
      case "提取音频":
      case "修改md5":
        return Container();
      default:
        break;
    }
  }

  widgetProportionalCrop(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => controller.preferredCropAspectRatio =
                    controller.preferredCropAspectRatio
                        ?.toFraction()
                        .inverse()
                        .toDouble(),
                icon: controller.preferredCropAspectRatio != null &&
                        controller.preferredCropAspectRatio! < 1
                    ? const Icon(Icons.panorama_vertical_select_rounded)
                    : const Icon(Icons.panorama_vertical_rounded),
              ),
              IconButton(
                onPressed: () => controller.preferredCropAspectRatio =
                    controller.preferredCropAspectRatio
                        ?.toFraction()
                        .inverse()
                        .toDouble(),
                icon: controller.preferredCropAspectRatio != null &&
                        controller.preferredCropAspectRatio! > 1
                    ? const Icon(Icons.panorama_horizontal_select_rounded)
                    : const Icon(Icons.panorama_horizontal_rounded),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCropButton(context, null),
              _buildCropButton(context, 1.toFraction()),
              _buildCropButton(context, Fraction.fromString("9/16")),
              _buildCropButton(context, Fraction.fromString("3/4")),
              // IconButton(
              //   onPressed: () {
              //     controller.applyCacheCrop();
              //     Navigator.pop(context);
              //   },
              //   icon: Center(
              //     child: Text(
              //       "保存",
              //       style: TextStyle(
              //         color: const CropGridStyle().selectedBoundariesColor,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          )
        ],
      ),
    );
  }

  widgetRotate() {
    return Row(children: [
      Expanded(
        child: IconButton(
          onPressed: () => controller.rotate90Degrees(RotateDirection.left),
          icon: Icon(Icons.rotate_left),
        ),
      ),
      Expanded(
        child: IconButton(
          onPressed: () => controller.rotate90Degrees(RotateDirection.right),
          icon: Icon(Icons.rotate_right),
        ),
      )
    ]);
  }

  _buildCropButton(BuildContext context, Fraction? f) {
    if (controller.preferredCropAspectRatio != null &&
        controller.preferredCropAspectRatio! > 1) f = f?.inverse();
    return Flexible(
      child: TextButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: controller.preferredCropAspectRatio == f?.toDouble()
              ? Colors.grey.shade800
              : null,
          foregroundColor: controller.preferredCropAspectRatio == f?.toDouble()
              ? Colors.white
              : null,
          textStyle: Theme.of(context).textTheme.bodySmall,
        ),
        onPressed: () => controller.preferredCropAspectRatio = f?.toDouble(),
        child: Text(f == null ? '自由' : '${f.numerator}:${f.denominator}'),
      ),
    );
  }

  widgetBottom() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ActionChip(
          label: Text('播放'),
          onPressed: () {
            controller.video.play();
          },
        ),
        ActionChip(
          label: Text('保存'),
          onPressed: () {
            exportVideo();
          },
        ),
      ],
    );
  }

  widgetViewer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CropGridViewer.edit(
          controller: controller,
          rotateCropArea: false,
          margin: EdgeInsets.symmetric(horizontal: 20.w),
        ),
        AnimatedBuilder(
          animation: controller.video,
          builder: (_, __) => AnimatedOpacity(
            opacity: controller.isPlaying ? 0 : 1,
            duration: kThemeAnimationDuration,
            child: GestureDetector(
              onTap: controller.video.play,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  widgetViewer1() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CropGridViewer.preview(controller: controller),
        AnimatedBuilder(
          animation: controller.video,
          builder: (_, __) => AnimatedOpacity(
            opacity: controller.isPlaying ? 0 : 1,
            duration: kThemeAnimationDuration,
            child: GestureDetector(
              onTap: controller.video.play,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  widgetVariableSpeed() {
    return Column(
      children: [
        Text(
          "视频播放速度${variableSpeedValue}倍",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Slider(
          max: 4.0,
          value: variableSpeedValue,
          onChanged: (value) {
            variableSpeedValue = double.parse(value.toStringAsFixed(1));
            setState(() {});
          },
        ),
      ],
    );
  }

  exportVideo() async {
    exportingProgress.value = 0;
    isExporting.value = true;
    await ExportService.runFFmpegCommand(
      await config.getExecuteConfig(),
      onProgress: (stats) {
        exportingProgress.value = config.getFFmpegProgress(stats.getTime());
      },
      onError: (e, s) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      onCompleted: (file) {
        isExporting.value = false;
        // showDialog(
        //   context: context,
        //   builder: (_) => VideoResultPopup(video: file),
        // );
      },
    );
  }

  widgetQuality() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: TextButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: true ? Colors.grey.shade800 : null,
              foregroundColor: true ? Colors.white : null,
              textStyle: Theme.of(context).textTheme.bodySmall,
            ),
            onPressed: () => {},
            child: Text("标清"),
          ),
        ),
        Flexible(
          child: TextButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: true ? Colors.grey.shade800 : null,
              foregroundColor: true ? Colors.white : null,
              textStyle: Theme.of(context).textTheme.bodySmall,
            ),
            onPressed: () => {},
            child: Text("高清"),
          ),
        ),
        Flexible(
          child: TextButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: true ? Colors.grey.shade800 : null,
              foregroundColor: true ? Colors.white : null,
              textStyle: Theme.of(context).textTheme.bodySmall,
            ),
            onPressed: () => {},
            child: Text("超清"),
          ),
        ),
      ],
    );
  }

  widgetMirror() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: TextButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: true ? Colors.grey.shade800 : null,
              foregroundColor: true ? Colors.white : null,
              textStyle: Theme.of(context).textTheme.bodySmall,
            ),
            onPressed: () => {},
            child: Text("水平镜像"),
          ),
        ),
        Flexible(
          child: TextButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: true ? Colors.grey.shade800 : null,
              foregroundColor: true ? Colors.white : null,
              textStyle: Theme.of(context).textTheme.bodySmall,
            ),
            onPressed: () => {},
            child: Text("垂直镜像"),
          ),
        ),
      ],
    );
  }
}
