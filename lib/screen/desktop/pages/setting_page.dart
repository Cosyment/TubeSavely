import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tubesavely/theme/app_theme.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../utils/constants.dart';
import '../main.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

enum ThemeMode { Light, Dark, System }

class _SettingPageState extends State<SettingPage> {
  ThemeMode currentThemeMode = ThemeMode.System;
  String cacheDir = '';
  String language = '中文';
  String retryCount = '2';
  String downloadQuality = '720P';
  bool mergeAudio = true;
  String videoFormat = 'MP4';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (currentThemeMode == ThemeMode.System) {
      // currentThemeMode = Theme.of(context).brightness == Brightness.dark ? ThemeMode.Dark : ThemeMode.Light;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle('通用设置'),
        _buildItem(
            '主题',
            CupertinoSegmentedControl(
                borderColor: AppTheme.accentColor.withOpacity(0.2),
                unselectedColor: AppTheme.white,
                selectedColor: AppTheme.accentColor,
                groupValue: currentThemeMode,
                pressedColor: AppTheme.accentColor.withOpacity(0.2),
                children: {
                  ThemeMode.Light: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(ThemeMode.Light.name),
                  ),
                  ThemeMode.Dark: Text(ThemeMode.Dark.name),
                  ThemeMode.System:
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(ThemeMode.System.name))
                },
                onValueChanged: (value) {
                  setState(() {
                    currentThemeMode = value;
                  });
                })),
        _buildItem(
            '缓存目录',
            Row(
              children: [
                SizedBox(
                    width: 300.0,
                    child: Text(
                      cacheDir,
                      maxLines: 1,
                      textAlign: TextAlign.end,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, overflow: TextOverflow.ellipsis),
                    )),
                IconButton(
                    onPressed: () async {
                      String? path =
                          await FilePicker.platform.getDirectoryPath(initialDirectory: cacheDir, lockParentWindow: true);
                      if (path == null) {
                        return;
                      }
                      setState(() {
                        cacheDir = path ?? '';
                      });
                    },
                    icon: const Icon(Icons.folder_open))
              ],
            )),
        _buildItem(
            '语言',
            _buildDropButton2(language, ['中文', 'English', '日本語'], (value) {
              setState(() {
                language = value;
              });
            })),
        _buildDivider(),
        _buildTitle('下载设置'),
        _buildItem(
            '失败重试次数',
            _buildDropButton2(retryCount, ['1', '2', '3', '4', '5'], (value) {
              setState(() {
                retryCount = value;
              });
            })),
        _buildItem(
            '默认下载分辨率',
            _buildDropButton2(downloadQuality, ['360P', '720P', '1080P', '1920P', '2K', '4K'], (value) {
              setState(() {
                downloadQuality = value;
              });
            })),
        _buildItem(
            'Youtube视频自动合并音频',
            Switch.adaptive(
                activeColor: AppTheme.white,
                inactiveThumbColor: Colors.white,
                activeTrackColor: AppTheme.accentColor,
                inactiveTrackColor: AppTheme.grey.withOpacity(0.2),
                value: mergeAudio,
                onChanged: (value) {
                  setState(() {
                    mergeAudio = value;
                  });
                })),
        _buildDivider(),
        _buildTitle('视频转换设置'),
        _buildItem(
            '默认转换格式',
            _buildDropButton2(videoFormat, ['MOV', 'AVI', 'MKV', 'MP4', 'FLV', 'WMV', 'RMVB', '3GP', 'MPG', 'MPE', 'M4V'],
                (value) {
              setState(() {
                videoFormat = value;
              });
            })),
        _buildDivider(),
        _buildTitle('其他'),
        _buildInkItem('访问网页版', () {
          launchUrlString(Constants.website);
        }),
        _buildInkItem('隐私政策', () {
          launchUrlString(Constants.privacyUrl);
        }),
        _buildInkItem('关于', () {
          showAppAboutDialog(context);
        })
      ],
    );
  }

  _buildTitle(String title) {
    return Title(
        color: Colors.amber,
        child: Text(
          title,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ));
  }

  _buildDivider() {
    return Divider(
      color: AppTheme.grey.withOpacity(0.1),
      height: 20,
    );
  }

  _buildItem(String title, Widget child) {
    return SizedBox(
        height: 38,
        child: Row(children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
          const Spacer(),
          child
        ]));
  }

  _buildInkItem(String title, Function callback) {
    return SizedBox(
        height: 30,
        child: InkWell(
            onTap: () {
              callback.call();
            },
            child: Row(
              children: [
                Text(title),
                const Spacer(),
                const Icon(
                  Icons.navigate_next,
                  color: Colors.grey,
                )
              ],
            )));
  }

  _buildDropButton2(String? value, List<String> items, Function callback) {
    return DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
            isExpanded: false,
            isDense: true,
            autofocus: true,
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
                        style: const TextStyle(
                          fontSize: 14,
                        ),
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
                color: AppTheme.white,
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              // height: 40,
              padding: EdgeInsets.only(left: 14, right: 14),
            )));
  }
}
