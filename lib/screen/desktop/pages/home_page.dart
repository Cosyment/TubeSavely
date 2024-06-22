import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tubesavely/generated/l10n.dart';
import 'package:tubesavely/screen/desktop/main.dart';

import 'convert_page.dart';
import 'download_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                  child: Row(
                    children: [
                      Icon(
                        item is DownloadPage ? Icons.save_alt : Icons.cached_outlined,
                        size: 25,
                      ),
                      // Text(
                      //   item is DownloadPage ? S.current.download : S.current.convert,
                      // )
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
                                side: BorderSide(width: 0.5, color: Theme.of(context).primaryColor),
                                selectedBackgroundColor: Theme.of(context).primaryColor,
                                selectedForegroundColor: Colors.white,
                                foregroundColor: Theme.of(context).primaryColor,
                              ),
                              segments: buttonSegments,
                              showSelectedIcon: false,
                              selected: {currentSegment},
                              onSelectionChanged: (Set<SegmentType> newSelection) {
                                setState(() {
                                  currentSegment = newSelection.first;
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
