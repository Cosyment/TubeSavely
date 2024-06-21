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
import '../../../theme/theme_provider.dart';
import '../../../utils/platform_util.dart';

class ConvertPage extends StatefulWidget {
  const ConvertPage({super.key});

  @override
  State<StatefulWidget> createState() => _ConvertPageState();
}

class _ConvertPageState extends State<ConvertPage> with AutomaticKeepAliveClientMixin<ConvertPage> {
  String videoFormat = Storage().getString(StorageKeys.CONVERT_FORMAT_KEY) ?? 'MP4';
  List<PlatformFile> videoList = [];
  Map<String, double> progressMap = {};
  Map<String, ExecuteStatus> statusMap = {};

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
    super.build(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: ThemeProvider.accentColor.withOpacity(0.2)),
                  overlayColor: ThemeProvider.accentColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
              onPressed: () {
                _pickVideo();
              },
              child: Text('添加视频', style: TextStyle(color: Theme.of(context).primaryColor)),
            ),
            Row(
              children: [
                Text(
                  '转换成',
                  style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                ),
                _buildDropButton2(videoFormat, ['MOV', 'AVI', 'MKV', 'MP4', 'FLV', 'WMV', 'RMVB', '3GP', 'MPG', 'MPE', 'M4V'],
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
            border: Border.all(color: Theme.of(context).dividerColor),
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
                      child: const Text('选择视频', style: TextStyle(color: Colors.white, fontSize: 16))),
                ))
              : ListView.builder(
                  itemCount: videoList.length,
                  itemBuilder: (context, index) {
                    return _buildItem(videoList[index]);
                  }),
        ))
      ],
    );
  }

  _buildItem(PlatformFile file) {
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
              child: FutureBuilder(
                builder: (context, snapshot) {
                  return snapshot.data == null
                      ? Image.asset('assets/ic_logo.png')
                      : Image.file(
                          File(snapshot.data ?? ''),
                          fit: BoxFit.cover,
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
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                file.path ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                      child: LinearProgressIndicator(
                    value: (progressMap[file.path ?? ''] ?? 0) / 100,
                    minHeight: 2,
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(50),
                    backgroundColor: AppTheme.accentColor.withOpacity(0.2),
                  )),
                  const SizedBox(
                    width: 10,
                  ),
                  Text('${(progressMap[file.path ?? '']?.toStringAsFixed(2) ?? 0)}%',
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)))
                ],
              )
            ],
          )),
          Row(
            children: [
              statusMap[file.path ?? ''] == ExecuteStatus.Executing
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
                        setState(() {
                          progressMap[file.path ?? ''] = 0;
                          statusMap[file.path ?? ''] = ExecuteStatus.Executing;
                        });
                        Converter.convertToFormat(
                            file.path ?? '', VideoFormat.values.byName(videoFormat == '3GP' ? '_3gp' : videoFormat),
                            progressCallback: (value) {
                          setState(() {
                            progressMap[file.path ?? ''] = value;
                            if (value == 100) {
                              statusMap[file.path ?? ''] = ExecuteStatus.Success;
                            }
                          });
                        });
                      },
                      icon: Icon(
                        Icons.cached_outlined,
                        color: Theme.of(context).primaryColor.withOpacity(0.8),
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
                      statusMap.remove(file.path ?? '');
                      progressMap.remove(file.path ?? '');
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

  _buildDropButton2(String? value, List<String> items, Function callback) {
    return DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
            isExpanded: false,
            value: value,
            items: items
                .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8)),
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
                color: Theme.of(context).dialogBackgroundColor,
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              // height: 40,
              padding: EdgeInsets.only(left: 14, right: 14),
            )));
  }
}
