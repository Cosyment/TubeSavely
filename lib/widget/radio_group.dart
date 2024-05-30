import 'package:flutter/material.dart';
import 'package:tubesavely/models/Pair.dart';

class RadioGroup extends StatefulWidget {
  final List<Pair>? items;
  final Function(int) onItemSelected;

  const RadioGroup({super.key, required this.items, required this.onItemSelected});

  @override
  State<StatefulWidget> createState() => _RadioGroupState();
}

class _RadioGroupState extends State<RadioGroup> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _buildRadioGroup(widget.items, widget.onItemSelected),
            )));
  }

  List<Widget> _buildRadioGroup(List<Pair>? items, Function(int) onItemSelected) {
    // int selectedIndex = 0; // 初始化选中项索引，默认为0
    if (items == null) return [];
    List<Widget> widgets = items
        .asMap()
        .entries
        .map((entry) => Row(children: [
              MaterialButton(
                  onPressed: () {
                    setState(() {
                      // 确保在StatefulWidget中调用setState以更新UI
                      _selectedIndex = entry.key;
                    });
                    onItemSelected(entry.key); // 触发外部回调
                  },
                  color: _selectedIndex == entry.key ? Color(0xFF3E2723) : Colors.grey.withOpacity(0.2),
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50), side: const BorderSide(color: Colors.transparent, width: 0)),
                  child: Container(
                    // margin: const EdgeInsets.symmetric(horizontal: 0),
                    // padding: const EdgeInsets.all(0),
                    child: Row(children: [
                      Text(entry.value.first,
                          style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold)),
                      if (entry.value.second != null && entry.value.second != '')
                        Text(' (${entry.value.second})', style: const TextStyle(color: Colors.white60, fontSize: 12))
                    ]),
                  )),
              const SizedBox(
                width: 10,
              )
            ]))
        .toList();
    return widgets;
  }
}
