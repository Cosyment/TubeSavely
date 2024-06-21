import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tubesavely/screen/desktop/main.dart';

import '../../../generated/l10n.dart';
import '../../../theme/app_theme.dart';
import 'convert_page.dart';
import 'download_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

enum SegmentType {
  download,
  convert,
}

class _HomePageState extends State<HomePage> {
  SegmentType currentSegment = SegmentType.download;
  List<Widget> pages = [const DownloadPage(), const ConvertPage()];
  PageController controller = PageController();
  List<ButtonSegment<SegmentType>> buttonSegments = [];

  @override
  void initState() {
    super.initState();
    currentSegment = pages.first is DownloadPage ? SegmentType.download : SegmentType.convert;
    buttonSegments = pages
        .map((item) => ButtonSegment<SegmentType>(
              value: item is DownloadPage ? SegmentType.download : SegmentType.convert,
              label: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: Row(
                    children: [
                      Icon(item is DownloadPage ? Icons.save_alt : Icons.cached_outlined),
                      Text(
                        item is DownloadPage ? S.current.download : S.current.convert,
                      )
                    ],
                  )),
            ))
        .toList();
    setState(() {
      // controller.jumpToPage(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    // var brightness = MediaQuery.of(context).platformBrightness;
    // bool isLightMode = brightness == Brightness.light;
    return SafeArea(
        top: true,
        child: Scaffold(
          body: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                Stack(
                  children: [
                    Row(
                      children: [
                        const SizedBox(
                          width: 60,
                          height: 80,
                          child: Image(image: AssetImage('assets/images/ic_logo.png')),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          S.current.appName,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 20),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        FutureBuilder<PackageInfo>(
                            future: PackageInfo.fromPlatform(),
                            builder: (context, snapshot) {
                              return Text(
                                '${snapshot.data?.version}',
                                style: const TextStyle(fontSize: 15, color: Colors.grey),
                              );
                            }),
                      ],
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SegmentedButton(
                              style: SegmentedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50.0),
                                ),
                                side: const BorderSide(width: 0.5, color: AppTheme.accentColor),
                                selectedBackgroundColor: AppTheme.accentColor,
                                selectedForegroundColor: Colors.white,
                                foregroundColor: AppTheme.accentColor,
                              ),
                              segments: buttonSegments,
                              showSelectedIcon: false,
                              selected: {currentSegment},
                              onSelectionChanged: (Set<SegmentType> newSelection) {
                                setState(() {
                                  currentSegment = newSelection.first;
                                  // body = currentSegment == SegmentType.download ? const DownloadPage() : const ConvertPage();
                                  controller.jumpToPage(currentSegment.index);
                                });
                              },
                            )
                          ],
                        )),
                    Positioned(
                        right: 0,
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  showSettingDialog(context);
                                },
                                icon: Icon(
                                  Icons.settings,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                )),
                            IconButton(
                                onPressed: () {
                                  showAppAboutDialog(context);
                                },
                                icon: Icon(
                                  Icons.info_outlined,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                ))
                          ],
                        )),
                  ],
                ),
                Expanded(
                    child: PageView(
                  controller: controller,
                  onPageChanged: (int index) {
                    setState(() {
                      currentSegment = SegmentType.values[index];
                    });
                  },
                  children: pages,
                ))
              ],
            ),
          ),
        ));
  }
}
