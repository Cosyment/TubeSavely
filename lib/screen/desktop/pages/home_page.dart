import 'package:flutter/material.dart';
import 'package:tubesavely/screen/desktop/pages/about_page.dart';
import 'package:tubesavely/screen/desktop/pages/setting_page.dart';

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
  Widget body = const DownloadPage();
  PageController controller = PageController();

  showSettingDialog() {
    return showAdaptiveDialog(
        context: context,
        builder: (context) {
          return AlertDialog.adaptive(
            title: Text('设置'),
            content: SettingPage(),
            actions: [
              MaterialButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop(); // 关闭对话框
                },
              ),
              MaterialButton(
                child: Text('Confirm'),
                onPressed: () {
                  Navigator.of(context).pop(); // 关闭对话框
                },
              ),
            ],
          );
        });
  }

  showAboutDialog() {
    return showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: const Text('关于'),
          content: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 300),
            child: const AboutPage(),
          ),
          actions: [
            MaterialButton(
              child: Container(
                height: 50,
                alignment: Alignment.center,
                child: Text('Close'),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        top: true,
        child: Scaffold(
          body: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            color: Colors.white,
            child: Column(
              children: [
                Stack(
                  children: [
                    const Row(
                      children: [
                        SizedBox(
                          width: 60,
                          height: 80,
                          child: Image(image: AssetImage('assets/images/ic_logo.png')),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          'TubeSavely',
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                        Text(
                          '1.0',
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        )
                      ],
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SegmentedButton(
                              segments: [
                                ButtonSegment<SegmentType>(
                                  value: SegmentType.download,
                                  label: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                                      child: const Row(
                                        children: [Icon(Icons.save_alt), Text("下载")],
                                      )),
                                  //icon: Icon(Icons.add),
                                  enabled: true,
                                ),
                                ButtonSegment<SegmentType>(
                                  value: SegmentType.convert,
                                  label: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                                      child: const Row(
                                        children: [Icon(Icons.refresh_sharp), Text("转换")],
                                      )),
                                  // icon: Icon(Icons.safety_check),
                                ),
                              ],
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
                                  showSettingDialog();
                                },
                                icon: const Icon(Icons.settings)),
                            IconButton(
                                onPressed: () {
                                  showAboutDialog();
                                  // Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(builder: (context) => const AboutPage()),
                                  // );
                                },
                                icon: const Icon(Icons.info_outlined))
                          ],
                        )),
                  ],
                ),
                Flexible(
                    child: PageView(
                  controller: controller,
                  onPageChanged: (int index) {
                    setState(() {
                      currentSegment = SegmentType.values[index];
                    });
                  },
                  children: const [DownloadPage(), ConvertPage()],
                ))
              ],
            ),
          ),
        ));
  }
}
