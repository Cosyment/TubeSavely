import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tubesavely/extension/extension.dart';
import 'package:tubesavely/generated/l10n.dart';
import 'package:tubesavely/locale/locale_manager.dart';
import 'package:tubesavely/model/emuns.dart';
import 'package:tubesavely/screen/desktop/main.dart';
import 'package:tubesavely/storage/storage.dart';
import 'package:tubesavely/theme/app_theme.dart';
import 'package:tubesavely/theme/theme_manager.dart';
import 'package:tubesavely/theme/theme_provider.dart';
import 'package:tubesavely/utils/constants.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  ThemeMode currentThemeMode = ThemeMode.values.byName(Storage().getString(StorageKeys.THEME_MODE_KEY) ?? ThemeMode.system.name);
  String cacheDir = Storage().getString(StorageKeys.CACHE_DIR_KEY) ?? '';
  String language = Storage().getString(StorageKeys.LANGUAGE_KEY) ?? 'English';
  bool reCode = Storage().getBool(StorageKeys.AUTO_RECODE_KEY);
  int retryCount = Storage().getInt(StorageKeys.RETRY_COUNT_KEY) ?? 2;
  String downloadQuality = Storage().getString(StorageKeys.DOWNLOAD_QUALITY_KEY) ?? '720P';
  bool mergeAudio = Storage().getBool(StorageKeys.AUTO_MERGE_AUDIO_KEY);
  String videoFormat = Storage().getString(StorageKeys.CONVERT_FORMAT_KEY) ?? 'MP4';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(S.current.generalSettings),
        _buildItem(
            S.current.settingTheme,
            SegmentedButton(
              style: SegmentedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  side: const BorderSide(width: 0.5, color: ThemeProvider.accentColor),
                  selectedBackgroundColor: ThemeProvider.accentColor,
                  selectedForegroundColor: Colors.white,
                  foregroundColor: ThemeProvider.accentColor),
              segments: [
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.light,
                  label: Text(_convertThemeText(ThemeMode.light)),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.dark,
                  label: Text(_convertThemeText(ThemeMode.dark)),
                  // icon: Icon(Icons.safety_check),
                ),
                ButtonSegment<ThemeMode>(
                  value: ThemeMode.system,
                  label: Text(_convertThemeText(ThemeMode.system)),
                  // icon: Icon(Icons.safety_check),
                )
              ],
              showSelectedIcon: false,
              selected: {currentThemeMode},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                setState(() {
                  currentThemeMode = newSelection.first;
                  Storage().set(StorageKeys.THEME_MODE_KEY, currentThemeMode.name);
                  Provider.of<ThemeManager>(context, listen: false).currentTheme = currentThemeMode;
                });
              },
            )),
        _buildItem(
            S.current.settingLanguage,
            _buildDropButton2(language, ['English', '简体中文', '日本語', '한국어'], (value) {
              setState(() {
                language = value;
                Storage().set(StorageKeys.LANGUAGE_KEY, value);
                Provider.of<LocaleManager>(context, listen: false).changeLocale(value);
                S.delegate.load(Locale(value.toString().toLanguageCode()));
              });
            })),
        _buildDivider(),
        _buildTitle(S.current.videoSettings),
        _buildItem(
            S.current.settingCacheDir,
            Row(
              children: [
                SizedBox(
                    width: 250.0,
                    child: Text(
                      cacheDir,
                      maxLines: 1,
                      textAlign: TextAlign.end,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                          overflow: TextOverflow.ellipsis),
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
                        Storage().set(StorageKeys.CACHE_DIR_KEY, path);
                      });
                    },
                    icon: Icon(Icons.folder_open, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)))
              ],
            )),
        _buildItem(
            S.current.settingRecode,
            Switch.adaptive(
                activeColor: AppTheme.white,
                inactiveThumbColor: Colors.white,
                activeTrackColor: AppTheme.accentColor,
                inactiveTrackColor: AppTheme.grey.withOpacity(0.2),
                value: reCode,
                onChanged: (value) {
                  setState(() {
                    reCode = value;
                    Storage().set(StorageKeys.AUTO_RECODE_KEY, value);
                  });
                })),
        // _buildItem(
        //     S.current.settingRetryCount,
        //     _buildDropButton2(retryCount.toString(), ['1', '2', '3', '4', '5'], (value) {
        //       setState(() {
        //         retryCount = int.parse(value);
        //         Storage().set(StorageKeys.RETRY_COUNT_KEY, retryCount);
        //       });
        //     })),
        _buildItem(
            S.current.settingDownloadQuality,
            _buildDropButton2(
                downloadQuality, VideoQuality.values.map((toElement) => toElement.name.replaceAll('_', '')).toList(), (value) {
              setState(() {
                downloadQuality = value;
                Storage().set(StorageKeys.DOWNLOAD_QUALITY_KEY, value);
              });
            })),
        _buildItem(
            S.current.settingYoutubeMerge,
            Switch.adaptive(
                activeColor: AppTheme.white,
                inactiveThumbColor: Colors.white,
                activeTrackColor: AppTheme.accentColor,
                inactiveTrackColor: AppTheme.grey.withOpacity(0.2),
                value: mergeAudio,
                onChanged: (value) {
                  setState(() {
                    mergeAudio = value;
                    Storage().set(StorageKeys.AUTO_MERGE_AUDIO_KEY, value);
                  });
                })),
        _buildItem(
            S.current.settingConvertFormat,
            _buildDropButton2(
                videoFormat, VideoFormat.values.map((toElement) => toElement.name.toUpperCase().replaceAll('_', '')).toList(),
                (value) {
              setState(() {
                videoFormat = value;
                Storage().set(StorageKeys.CONVERT_FORMAT_KEY, value);
              });
            })),
        _buildDivider(),
        _buildTitle(S.current.otherSettings),
        _buildInkItem(S.current.visitWebsite, () {
          launchUrlString(Constants.website);
        }),
        _buildInkItem(S.current.privacyPolicy, () {
          launchUrlString(Constants.privacyUrl);
        }),
        _buildInkItem(S.current.aboutUs, () {
          showAppAboutDialog(context);
        })
      ],
    );
  }

  _convertThemeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return S.current.settingThemeLight;
      case ThemeMode.dark:
        return S.current.settingThemeDark;
      case ThemeMode.system:
        return S.current.settingThemeSystem;
    }
  }

  _buildTitle(String title) {
    return Title(
        color: Colors.grey,
        child: Text(
          title,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), fontSize: 12),
        ));
  }

  _buildDivider() {
    return Divider(
      color: Theme.of(context).dividerColor,
      height: 20,
    );
  }

  _buildItem(String title, Widget child) {
    return SizedBox(
        height: 38,
        child: Row(children: [
          Text(
            title,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 14),
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
                Text(title, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
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
            // hint: Text(
            //   '',
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
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
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
                color: Theme.of(context).dialogBackgroundColor,
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              // height: 40,
              padding: EdgeInsets.only(left: 14, right: 14),
            )));
  }
}
