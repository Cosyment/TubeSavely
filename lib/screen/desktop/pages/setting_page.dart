import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
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
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    if (currentThemeMode == ThemeMode.System) {
      // currentThemeMode = Theme.of(context).brightness == Brightness.dark ? ThemeMode.Dark : ThemeMode.Light;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle('通用设置'),
        _buildItem(
            isLightMode,
            '主题',
            SegmentedButton(
              style: SegmentedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  side: const BorderSide(width: 0.5, color: AppTheme.accentColor),
                  selectedBackgroundColor: AppTheme.accentColor,
                  selectedForegroundColor: Colors.white,
                  backgroundColor: isLightMode ? Colors.white : Colors.black12,
                  foregroundColor: AppTheme.accentColor),
              segments: [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.Light,
                  label: Text(
                    ThemeMode.Light.name,
                  ),
                  enabled: true,
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.Dark,
                  label: Text(
                    ThemeMode.Dark.name,
                  ),
                  // icon: Icon(Icons.safety_check),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.System,
                  label: Text(
                    ThemeMode.System.name,
                  ),
                  // icon: Icon(Icons.safety_check),
                )
              ],
              showSelectedIcon: false,
              selected: {currentThemeMode},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                setState(() {
                  currentThemeMode = newSelection.first;
                });
              },
            )),
        _buildItem(
            isLightMode,
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
                      style: TextStyle(
                          fontSize: 12, color: isLightMode ? Colors.grey : Colors.white60, overflow: TextOverflow.ellipsis),
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
            isLightMode,
            '语言',
            _buildDropButton2(isLightMode, language, ['中文', 'English', '日本語'], (value) {
              setState(() {
                language = value;
              });
            })),
        _buildDivider(),
        _buildTitle('下载设置'),
        _buildItem(
            isLightMode,
            '失败重试次数',
            _buildDropButton2(isLightMode, retryCount, ['1', '2', '3', '4', '5'], (value) {
              setState(() {
                retryCount = value;
              });
            })),
        _buildItem(
            isLightMode,
            '默认下载分辨率',
            _buildDropButton2(isLightMode, downloadQuality, ['360P', '720P', '1080P', '1920P', '2K', '4K'], (value) {
              setState(() {
                downloadQuality = value;
              });
            })),
        _buildItem(
            isLightMode,
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
            isLightMode,
            '默认转换格式',
            _buildDropButton2(
                isLightMode, videoFormat, ['MOV', 'AVI', 'MKV', 'MP4', 'FLV', 'WMV', 'RMVB', '3GP', 'MPG', 'MPE', 'M4V'],
                (value) {
              setState(() {
                videoFormat = value;
              });
            })),
        _buildDivider(),
        _buildTitle('其他'),
        _buildInkItem(isLightMode, '访问网页版', () {
          launchUrlString(Constants.website);
        }),
        _buildInkItem(isLightMode, '隐私政策', () {
          launchUrlString(Constants.privacyUrl);
        }),
        _buildInkItem(isLightMode, '关于', () {
          showAppAboutDialog(context);
        })
      ],
    );
  }

  _buildTitle(String title) {
    return Title(
        color: Colors.grey,
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

  _buildItem(bool isLightMode, String title, Widget child) {
    return SizedBox(
        height: 38,
        child: Row(children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, color: isLightMode ? Colors.black.withOpacity(0.7) : Colors.white70),
          ),
          const Spacer(),
          child
        ]));
  }

  _buildInkItem(bool isLightMode, String title, Function callback) {
    return SizedBox(
        height: 30,
        child: InkWell(
            onTap: () {
              callback.call();
            },
            child: Row(
              children: [
                Text(title, style: TextStyle(fontSize: 14, color: isLightMode ? Colors.black.withOpacity(0.7) : Colors.white70)),
                const Spacer(),
                const Icon(
                  Icons.navigate_next,
                  color: Colors.grey,
                )
              ],
            )));
  }

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
                        style: TextStyle(
                          fontSize: 14,
                          color: isLightMode ? Colors.black87 : Colors.white60,
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
                color: isLightMode ? Colors.white : AppTheme.nearlyBlack,
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              // height: 40,
              padding: EdgeInsets.only(left: 14, right: 14),
            )));
  }
}
