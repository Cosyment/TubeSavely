import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class ConvertPage extends StatefulWidget {
  const ConvertPage({super.key});

  @override
  State<StatefulWidget> createState() => _ConvertPageState();
}

class _ConvertPageState extends State<ConvertPage> with AutomaticKeepAliveClientMixin<ConvertPage> {
  String videoFormat = 'MP4';
  List<PlatformFile> videoList = [];

  _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(dialogTitle: '选择视频', type: FileType.video);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        videoList.add(result.files.first);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.accentColor.withOpacity(0.2)),
                  overlayColor: AppTheme.accentColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
              onPressed: () {
                _pickVideo();
              },
              child: const Text('添加视频', style: TextStyle(color: AppTheme.accentColor)),
            ),
            Row(
              children: [
                const Text(
                  '转换成',
                  style: TextStyle(fontSize: 14, color: AppTheme.grey),
                ),
                _buildDropButton2(videoFormat, ['MOV', 'AVI', 'MKV', 'MP4', 'FLV', 'WMV', 'RMVB', '3GP', 'MPG', 'MPE', 'M4V'],
                    (value) {
                  setState(() {
                    videoFormat = value;
                  });
                })
              ],
            )
          ],
        ),
        Expanded(
            child: Container(
          margin: const EdgeInsets.only(top: 10, bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(8),
          ),
          // height: 500,
          width: double.infinity,
          child: videoList.isEmpty
              ? Expanded(
                  child: Center(
                  child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      onPressed: () async {
                        _pickVideo();
                      },
                      child: const Text('选择视频')),
                ))
              : ListView.builder(
                  itemCount: videoList.length,
                  itemBuilder: (context, index) {
                    return _buildItem(videoList[index]);
                  }),
        ))
      ],
    );
  }

  _buildItem(PlatformFile file) {
    return Container(
      margin: const EdgeInsets.only(top: 15, bottom: 0, left: 10, right: 10),
      width: double.infinity,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
              width: 130,
              height: 90,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))),
              child: CachedNetworkImage(
                imageUrl: file.path ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(
                  width: 20,
                  height: 20,
                  child: Center(
                      child: CircularProgressIndicator(
                    color: Colors.grey,
                  )),
                ),
                errorWidget: (context, url, error) => const Image(image: AssetImage('assets/ic_logo.png')),
              )),
          const SizedBox(
            width: 10,
          ),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(file.name), Text(file.path ?? '')],
          )),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    setState(() {});
                  },
                  icon: const Icon(Icons.start)),
              IconButton(
                  onPressed: () async {
                    await FilePicker.platform.getDirectoryPath(initialDirectory: file.path, lockParentWindow: true);
                  },
                  icon: const Icon(Icons.folder_open)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      videoList.remove(file);
                    });
                  },
                  icon: const Icon(Icons.delete)),
            ],
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  _buildDropButton2(String? value, List<String> items, Function callback) {
    return DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
            isExpanded: false,
            isDense: true,
            autofocus: true,
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
                        style: const TextStyle(
                          fontSize: 14,
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
                color: AppTheme.white,
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              // height: 40,
              padding: EdgeInsets.only(left: 14, right: 14),
            )));
  }
}
