import 'package:flutter/material.dart';
import 'package:tubesavely/app_theme.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key, this.screenIndex, this.iconAnimationController, this.callBackIndex});

  final AnimationController? iconAnimationController;
  final DrawerIndex? screenIndex;
  final Function(DrawerIndex)? callBackIndex;

  @override
  State<StatefulWidget> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  List<DrawerList>? drawerList;

  @override
  void initState() {
    setDrawerListArray();
    super.initState();
  }

  void setDrawerListArray() {
    drawerList = <DrawerList>[
      DrawerList(
        index: DrawerIndex.Home,
        labelName: 'Parse',
        icon: const Icon(Icons.analytics_outlined),
      ),
      DrawerList(
        index: DrawerIndex.Task,
        labelName: 'Tasks',
        icon: const Icon(Icons.add_task_outlined),
      ),
      DrawerList(
        index: DrawerIndex.History,
        labelName: 'History',
        icon: const Icon(Icons.manage_history_rounded),
      ),
      // DrawerList(
      //   index: DrawerIndex.Help,
      //   labelName: 'Help',
      //   isAssetsImage: true,
      //   imageName: 'assets/images/ic_support.png',
      // ),
      DrawerList(
        index: DrawerIndex.FeedBack,
        labelName: 'Feedback',
        icon: const Icon(Icons.feedback_outlined),
      ),
      // DrawerList(
      //   index: DrawerIndex.Invite,
      //   labelName: '邀请好友',
      //   icon: const Icon(Icons.group),
      // ),
      // DrawerList(
      //   index: DrawerIndex.Share,
      //   labelName: '给个好评',
      //   icon: const Icon(Icons.recommend_outlined),
      // ),
      // DrawerList(
      //   index: DrawerIndex.Settings,
      //   labelName: 'Settings',
      //   icon: const Icon(Icons.settings_outlined),
      // ),
      DrawerList(
        index: DrawerIndex.More,
        labelName: 'More',
        icon: const Icon(Icons.more_horiz),
      ),
      // DrawerList(
      //   index: DrawerIndex.About,
      //   labelName: '关于',
      //   icon: const Icon(Icons.info_outline),
      // ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    return Scaffold(
      backgroundColor: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: widget.iconAnimationController!,
                    builder: (BuildContext context, Widget? child) {
                      return ScaleTransition(
                        scale: AlwaysStoppedAnimation<double>(1.0 - (widget.iconAnimationController!.value) * 0.2),
                        child: RotationTransition(
                          turns: AlwaysStoppedAnimation<double>(Tween<double>(begin: 0.0, end: 360.0)
                                  .animate(CurvedAnimation(parent: widget.iconAnimationController!, curve: Curves.fastOutSlowIn))
                                  .value /
                              360),
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(color: AppTheme.grey.withOpacity(0.3), offset: const Offset(2.0, 4.0), blurRadius: 8),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(60.0)),
                              child: Image.asset('assets/images/ic_logo_white.png'),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      'TubeSavely',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isLightMode ? AppTheme.grey : AppTheme.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          Divider(
            height: 1,
            color: AppTheme.grey.withOpacity(0.1),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(0.0),
              itemCount: drawerList?.length,
              itemBuilder: (BuildContext context, int index) {
                return inkwell(drawerList![index]);
              },
            ),
          ),
          Divider(
            height: 1,
            color: AppTheme.grey.withOpacity(0.6),
          ),
        ],
      ),
    );
  }

  void onTapped() {
    debugPrint('Doing Something...'); // Print to console.
  }

  Widget inkwell(DrawerList listData) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.grey.withOpacity(0.1),
        highlightColor: Colors.transparent,
        onTap: () {
          navigationToScreen(listData.index!);
        },
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Row(
                children: <Widget>[
                  const SizedBox(
                    width: 6.0,
                    height: 46.0,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  listData.isAssetsImage
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: Image.asset(listData.imageName,
                              color: widget.screenIndex == listData.index ? AppTheme.accentColor : AppTheme.deactivatedText),
                        )
                      : Icon(listData.icon?.icon,
                          color: widget.screenIndex == listData.index ? AppTheme.accentColor : AppTheme.deactivatedText),
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  Text(
                    listData.labelName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: widget.screenIndex == listData.index ? AppTheme.accentColor : AppTheme.deactivatedText,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            widget.screenIndex == listData.index
                ? AnimatedBuilder(
                    animation: widget.iconAnimationController!,
                    builder: (BuildContext context, Widget? child) {
                      return Transform(
                        transform: Matrix4.translationValues(
                            (MediaQuery.of(context).size.width * 0.75 - 64) * (1.0 - widget.iconAnimationController!.value - 1.0),
                            0.0,
                            0.0),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.75 - 64,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor.withOpacity(0.2),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(28),
                                bottomLeft: Radius.circular(0),
                                bottomRight: Radius.circular(28),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }

  Future<void> navigationToScreen(DrawerIndex indexScreen) async {
    widget.callBackIndex!(indexScreen);
  }
}

enum DrawerIndex {
  Home,
  History,
  Task,
  FeedBack,
  Help,
  Share,
  Invite,
  Settings,
  More,
  About,
}

class DrawerList {
  DrawerList({
    this.isAssetsImage = false,
    this.labelName = '',
    this.icon,
    this.index,
    this.imageName = '',
  });

  String labelName;
  Icon? icon;
  bool isAssetsImage;
  String imageName;
  DrawerIndex? index;
}
