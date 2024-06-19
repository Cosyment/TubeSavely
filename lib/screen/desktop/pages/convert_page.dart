import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tubesavely/core/converter/converter.dart';
import 'package:tubesavely/core/ffmpeg/ffmpeg_executor.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../model/emuns.dart';
import '../../../storage/storage.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/platform_util.dart';

class ConvertPage extends StatefulWidget {
  const ConvertPage({super.key});

  @override
  State<StatefulWidget> createState() => _ConvertPageState();
}

class _ConvertPageState extends State<ConvertPage> with AutomaticKeepAliveClientMixin<ConvertPage> {
  String videoFormat = Storage().getString(StorageKeys.CONVERT_FORMAT_KEY) ?? 'MP4';
  List<PlatformFile> videoList = [];

  _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(dialogTitle: '选择视频', type: FileType.video);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        videoList.add(result.files.first);
      });
    }
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
              onPressed: () {
                _pickVideo();
              },
              child: const Text('添加视频', style: TextStyle(color: AppTheme.accentColor)),
            ),
            Row(
              children: [
                Text(
                  '转换成',
                  style: TextStyle(fontSize: 14, color: isLightMode ? Colors.black54 : Colors.white38),
                ),
                _buildDropButton2(
                    isLightMode, videoFormat, ['MOV', 'AVI', 'MKV', 'MP4', 'FLV', 'WMV', 'RMVB', '3GP', 'MPG', 'MPE', 'M4V'],
                    (value) {
                  setState(() {
                    videoFormat = value;
                  });
                })
              ],
            )
          ],
        ),
        Expanded(
            child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 20),
          decoration: BoxDecoration(
            border: Border.all(color: isLightMode ? Colors.black12 : Colors.white12),
            borderRadius: BorderRadius.circular(8),
          ),
          // height: 500,
          width: double.infinity,
          child: videoList.isEmpty
              ? Expanded(
                  child: Center(
                  child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      onPressed: () async {
                        _pickVideo();
                      },
                      child: const Text('选择视频')),
                ))
              : ListView.builder(
                  itemCount: videoList.length,
                  itemBuilder: (context, index) {
                    return _buildItem(isLightMode, videoList[index]);
                  }),
        ))
      ],
    );
  }

  _buildItem(bool isLightMode, PlatformFile file) {
    var progress = 0.0;
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
              child: FutureBuilder(
                builder: (context, snapshot) {
                  return snapshot.data == null
                      ? Image.asset('assets/ic_logo.png')
                      : Image.file(
                          File(snapshot.data ?? ''),
                          fit: BoxFit.fitWidth,
                        );
                },
                future: FFmpegExecutor.extractThumbnail(file.path ?? ''),
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
                file.name,
                style: TextStyle(fontSize: 16, color: isLightMode ? Colors.black87 : Colors.white),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                file.path ?? '',
                style: TextStyle(fontSize: 12, color: isLightMode ? Colors.black54 : Colors.white54),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                      child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 2,
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(50),
                    backgroundColor: AppTheme.accentColor.withOpacity(0.2),
                  )),
                  const SizedBox(
                    width: 10,
                  ),
                  Text('$progress%')
                ],
              )
            ],
          )),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    Converter.convertToFormat(file.path ?? '', VideoFormat.values.byName(videoFormat), progressCallback: (value) {
                      setState(() {
                        print('---------_value>>>>> ${value}');
                        progress = value;
                      });
                    });
                  },
                  icon: Icon(
                    Icons.cached_outlined,
                    color: AppTheme.accentColor.withOpacity(0.8),
                  )),
              IconButton(
                  onPressed: () async {
                    launchUrlString(Uri.file((await Converter.baseOutputPath ?? ''), windows: PlatformUtil.isWindows).toString());
                  },
                  icon: const Icon(
                    Icons.folder_open,
                    color: Colors.grey,
                  )),
              IconButton(
                  onPressed: () {
                    setState(() {
                      videoList.remove(file);
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

  @override
  bool get wantKeepAlive => true;

  _buildDropButton2(bool isLightMode, String? value, List<String> items, Function callback) {
    return DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
            isExpanded: false,
            // hint: Text(
            //   'Select Item',
            //   style: TextStyle(
            //     fontSize: 14,
            //     color: Theme.of(context).hintColor,
            //   ),
            // ),
            value: value,
            items: items
                .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(fontSize: 14, color: isLightMode ? Colors.black87 : Colors.white60),
                      ),
                    ))
                .toList(),
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.zero,
              height: 30,
              // width: 80,
            ),
            onChanged: (value) {
              callback.call(value);
            },
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isLightMode ? Colors.white : AppTheme.nearlyBlack,
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              // height: 40,
              padding: EdgeInsets.only(left: 14, right: 14),
            )));
  }
}
