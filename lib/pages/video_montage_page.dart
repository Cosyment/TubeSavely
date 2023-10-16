import 'dart:io';

import 'package:downloaderx/pages/cover_result_page.dart';
import 'package:downloaderx/pages/video_result_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:video_editor/video_editor.dart';
import 'package:fraction/fraction.dart';
import '../constants/colors.dart';
import '../utils/export_service.dart';

class VideoMontagePage extends StatefulWidget {
  final File file;
  final String title;

  const VideoMontagePage({super.key, required this.file, required this.title});

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
  late FFmpegVideoEditorConfig config;
  double height = 60;

  var list = [
    {
      'title': '标清',
      'value': '640',
    },
    {
      'title': '高清',
      'value': '720',
    },
    {
      'title': '超清',
      'value': '1080',
    },
  ];

  var listMirror = [
    {
      'title': '水平镜像',
      'value': 'hflip',
    },
    {
      'title': '垂直镜像',
      'value': 'vflip',
    },
  ];

  var selectIndex = 0;

  @override
  void initState() {
    super.initState();
    file = widget.file;
    title = widget.title;

    controller = VideoEditorController.file(
      file,
      minDuration: Duration(seconds: 1),
      maxDuration: Duration(seconds: 10),
      coverStyle: CoverSelectionStyle(selectedBorderColor: primaryColor),
      cropStyle: CropGridStyle(
        selectedBoundariesColor: primaryColor,
      ),
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
        viewer = widgetViewer1();
        config = VideoFFmpegVideoEditorConfig(
          controller,
        );
        break;
      case "视频倒放":
        viewer = widgetViewer1();
        config = VideoFFmpegVideoEditorConfig(
          controller,
          format: VideoExportFormat.mp4,
          commandBuilder: (config, videoPath, outputPath) {
            return '-i $videoPath -vf reverse -q:v 0 -b:v 2M  -y $outputPath';
          },
        );
        break;
      case "视频旋转":
        viewer = widgetViewer1();
        config = VideoFFmpegVideoEditorConfig(
          controller,
        );
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
        config = VideoFFmpegVideoEditorConfig(
          controller,
          format: VideoExportFormat.mp4,
          commandBuilder: (config, videoPath, outputPath) {
            return '-i $videoPath -c:a aac -vf scale=${list[selectIndex]['value']}:-2 -threads 4 -q:v 0 -b:v 2M -y $outputPath';
          },
        );
        break;
      case "视频截图":
        viewer = widgetViewer1();
        config = CoverFFmpegVideoEditorConfig(controller);
        break;
      case "视频合并":
        viewer = widgetViewer();
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
            return '-i $videoPath -vf ${listMirror[selectIndex]['value']} -q:v 0 -b:v 2M -y $outputPath';
          },
        );
        break;
      case "视频去声音":
        viewer = widgetViewer1();
        config = VideoFFmpegVideoEditorConfig(
          controller,
          commandBuilder: (config, videoPath, outputPath) {
            return '-i $videoPath -q:v 0 -b:v 2M -an -c copy -y $outputPath';
          },
        );
        break;
      case "提取音频":
        viewer = widgetViewer1();
        config = VideoFFmpegVideoEditorConfig(
          controller,
          commandBuilder: (config, videoPath, outputPath) {
            return '-i $videoPath -vn -c:a copy -y $outputPath';
          },
        );
        break;
      case "修改md5":
        viewer = widgetViewer1();
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
    ScreenUtil.init(context, designSize: const Size(750, 1378));
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.w),
          child: Container(
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
      ),
    );
  }

  @override
  void dispose() {
    exportingProgress.dispose();
    isExporting.dispose();
    controller.dispose();
    ExportService.dispose();
    super.dispose();
  }

  widgetType() {
    switch (title) {
      case "视频裁剪":
        return widgetProportionalCrop(context);
      case "视频剪辑":
        return trimSlider();
      case "视频倒放":
        return Container();
      case "视频旋转":
        return widgetRotate();
      case "视频变速":
        return widgetVariableSpeed();
      case "视频压缩":
        return widgetQuality();
      case "视频截图":
        return coverSelection();
      case "视频合并":
      case "视频转GIF":
        return Container();
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

  var isVideoStatus = true;

  widgetViewer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CropGridViewer.edit(
          controller: controller,
          rotateCropArea: true,
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
              onTap: () {
                controller.video.play();
                setState(() {});
              },
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
    showProgress();
    exportingProgress.value = 0;
    isExporting.value = true;
    var execute = await config.getExecuteConfig();
    await ExportService.runFFmpegCommand(
      execute!,
      onProgress: (stats) {
        exportingProgress.value =
            config.getFFmpegProgress(stats.getTime().toInt());
        print(exportingProgress.value);
        if (progresState != null) {
          progresState!(() {});
        }
      },
      onError: (e, s) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      onCompleted: (file) {
        Navigator.pop(context);
        isExporting.value = false;
        if (title == "视频截图") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CoverResultPage(cover: file),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoResultPage(video: file),
            ),
          );
        }
      },
    );
  }

  StateSetter? progresState;

  showProgress() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, state) {
            progresState = state;
            return Center(
              child: Container(
                width: double.infinity,
                height: 300.w,
                margin: EdgeInsets.symmetric(horizontal: 50.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 140.w,
                      height: 140.w,
                      child: CircularPercentIndicator(
                        radius: 70.0.r,
                        lineWidth: 4.0,
                        percent: exportingProgress.value,
                        backgroundColor: primaryColor,
                        center: Text(
                          "${(exportingProgress.value * 100).ceil()}%",
                          style: TextStyle(
                            color: primaryColor,
                          ),
                        ),
                        progressColor: progressColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  widgetQuality() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: list.asMap().keys.map((int index) {
        return InkWell(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 20.w),
            margin: EdgeInsets.symmetric(vertical: 10.w, horizontal: 10.w),
            decoration: BoxDecoration(
                gradient: selectIndex == index
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFC6AEC),
                          Color(0xFF7776FF),
                        ],
                      )
                    : null,
                border: Border.all(color: primaryColor, width: 1.0),
                borderRadius: const BorderRadius.all(Radius.circular(4))),
            child: Text(
              list[index]['title'].toString(),
              style: TextStyle(
                  color: selectIndex == index ? Colors.white : Colors.black),
            ),
          ),
          onTap: () {
            setState(() {
              selectIndex = index;
            });
          },
        );
      }).toList(),
    );
  }

  widgetMirror() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: listMirror.asMap().keys.map((int index) {
        return Padding(
          padding: EdgeInsets.all(10.w),
          child: InkWell(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 20.w),
              decoration: BoxDecoration(
                  gradient: selectIndex == index
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFC6AEC),
                            Color(0xFF7776FF),
                          ],
                        )
                      : null,
                  border: Border.all(color: primaryColor, width: 1.0),
                  borderRadius: const BorderRadius.all(Radius.circular(4))),
              child: Text(
                listMirror[index]['title'].toString(),
                style: TextStyle(
                    color: selectIndex == index ? Colors.white : Colors.black),
              ),
            ),
            onTap: () {
              setState(() {
                selectIndex = index;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  trimSlider() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([
            controller,
            controller.video,
          ]),
          builder: (_, __) {
            final int duration = controller.videoDuration.inSeconds;
            final double pos = controller.trimPosition * duration;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: height / 4),
              child: Row(children: [
                Text(formatter(Duration(seconds: pos.toInt()))),
                const Expanded(child: SizedBox()),
                AnimatedOpacity(
                  opacity: controller.isTrimming ? 1 : 0,
                  duration: kThemeAnimationDuration,
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(formatter(controller.startTrim)),
                    const SizedBox(width: 10),
                    Text(formatter(controller.endTrim)),
                  ]),
                ),
              ]),
            );
          },
        ),
        controller != null
            ? Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: height / 4),
                child: TrimSlider(
                  controller: controller,
                  height: height,
                  horizontalMargin: height / 4,
                  child: TrimTimeline(
                    controller: controller,
                    padding: const EdgeInsets.only(top: 10),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  coverSelection() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          margin: EdgeInsets.all(15.w),
          child: CoverSelection(
            controller: controller,
            size: height + 10,
            quantity: 8,
            selectedCoverBuilder: (cover, size) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  cover,
                  Icon(
                    Icons.check_circle,
                    color:
                        CoverSelectionStyle(selectedBorderColor: primaryColor)
                            .selectedBorderColor,
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  widgetBottom() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            if (!controller.isPlaying) {
              controller.video.play();
            } else {
              controller.video.pause();
            }
            setState(() {});
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 20.w,
              horizontal: 20.w,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFC6AEC),
                  Color(0xFF7776FF),
                ],
              ),
            ),
            child: Text(
              !controller.isPlaying ? '播放' : "暂停",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26.sp,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            controller.applyCacheCrop();
            exportVideo();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 20.w,
              horizontal: 20.w,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.r),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFC6AEC),
                  Color(0xFF7776FF),
                ],
              ),
            ),
            child: Text(
              '下一步',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
