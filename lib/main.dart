import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:downloaderx/pages/download_page.dart';
import 'package:downloaderx/pages/home_page.dart';
import 'package:downloaderx/pages/mine_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  await ScreenUtil.ensureScreenSize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _controller = NotchBottomBarController(index: 0);
  var currentPageIndex = 0;

  @override
  void dispose() {
    super.dispose();
  }

  final List<Widget> bottomBarPages = [
    const HomePage(),
    const DownloadPage(),
    const MinePage(),
  ];

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(750, 1378));
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: IndexedStack(
          index: currentPageIndex,
          children: List.generate(
              bottomBarPages.length, (index) => bottomBarPages[index]),
        ),
        extendBody: true,
        bottomNavigationBar: AnimatedNotchBottomBar(
          notchBottomBarController: _controller,
          color: Colors.white,
          showLabel: false,
          notchColor: Colors.white,
          removeMargins: false,
          bottomBarWidth: 200.w,
          durationInMilliSeconds: 300,
          bottomBarItems: const [
            BottomBarItem(
              inActiveItem: Icon(
                Icons.home_filled,
                color: Colors.grey,
              ),
              activeItem: Icon(
                Icons.home_filled,
                color: Colors.black,
              ),
              itemLabel: 'Page 1',
            ),
            BottomBarItem(
              inActiveItem: Icon(
                Icons.download,
                color: Colors.grey,
              ),
              activeItem: Icon(
                Icons.download,
                color: Colors.black,
              ),
              itemLabel: 'Page 2',
            ),
            BottomBarItem(
              inActiveItem: Icon(
                Icons.person,
                color: Colors.grey,
              ),
              activeItem: Icon(
                Icons.person,
                color: Colors.black,
              ),
              itemLabel: 'Page 3',
            ),
          ],
          onTap: (index) {
            currentPageIndex = index;
            setState(() {});
          },
        ));
  }
}
