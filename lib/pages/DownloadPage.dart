import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  State<DownloadPage> createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  @override
  void initState() {
    super.initState();
    getDownloadList();
  }

  void getDownloadList() async {
    List<DownloadTask>? tasks = await FlutterDownloader.loadTasks();
    print("tasks>>>>>${tasks}");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.green, child: const Center(child: Text('Page 2')));
  }
// final TextEditingController textController = TextEditingController();
}
