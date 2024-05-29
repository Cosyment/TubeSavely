import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<StatefulWidget> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Task> taskList = [];

  void fetchData() async {
    taskList = await FileDownloader().allTasks();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchData();

    FileDownloader().registerCallbacks(taskStatusCallback: (status) {}, taskProgressCallback: (progress) {});
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    return Container(
        color: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
        child: SafeArea(
            top: false,
            bottom: false,
            child: Scaffold(
                appBar: AppBar(
                  leading: const SizedBox(width: 50),
                  backgroundColor: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
                  title: Text(
                    'Tasks',
                    style: TextStyle(color: isLightMode ? AppTheme.nearlyBlack : AppTheme.white),
                  ),
                ),
                backgroundColor: isLightMode ? AppTheme.white : AppTheme.nearlyBlack,
                body: taskList.isEmpty
                    ? Center(
                        child: Image.asset('assets/images/ic_empty.png'),
                      )
                    : ListView.builder(
                        itemCount: taskList.length,
                        itemBuilder: (context, index) {
                          return _buildItem(taskList[index] as DownloadTask);
                        }))));
  }

  Widget _buildItem(DownloadTask task) {
    // (task as DownloadTask).expectedFileSize();
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Material(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            elevation: 10,
            child: Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          child: FutureBuilder(
                        future: task.expectedFileSize(),
                        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                          return Text(
                            task.filename,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        },
                      )),
                      // IconButton(
                      //   onPressed: () {
                      //     FileDownloader().pause(task);
                      //   },
                      //   icon: const Icon(Icons.pause),
                      // )
                    ]))));
  }
}
