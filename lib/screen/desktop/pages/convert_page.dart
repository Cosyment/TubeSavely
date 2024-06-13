import 'package:flutter/material.dart';

class ConvertPage extends StatefulWidget {
  const ConvertPage({super.key});

  @override
  State<StatefulWidget> createState() => _ConvertPageState();
}

class _ConvertPageState extends State<ConvertPage> with AutomaticKeepAliveClientMixin<ConvertPage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {},
              child: const Text(
                '添加视频',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('转换格式'),
            )
          ],
        ),
        Expanded(
            child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 20),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black45),
            borderRadius: BorderRadius.circular(8),
          ),
          // height: 500,
          width: double.infinity,
          child: Expanded(
              child: Center(
            child: TextButton(onPressed: () {}, child: const Text('选择视频')),
          ))
          // ListView.builder(itemBuilder: (context, index) {
          //   return _buildItem();
          // })
          ,
        ))
      ],
    );
  }

  _buildItem() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const SizedBox(width: 100, height: 60, child: Image(image: AssetImage('assets/ic_logo.png'))),
          const Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text('标题'), Text('https://www.facebook.com/100000124835838/videos/329176782997696/')],
          )),
          Row(
            children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.save_alt)),
              IconButton(onPressed: () {}, icon: Icon(Icons.folder_open)),
              IconButton(onPressed: () {}, icon: Icon(Icons.delete)),
            ],
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
