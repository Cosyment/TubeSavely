import 'package:flutter/material.dart';
import 'package:tubesaverx/models/Pair.dart';

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
        .map((entry) => InkWell(
            onTap: () {
              setState(() {
                // 确保在StatefulWidget中调用setState以更新UI
                _selectedIndex = entry.key;
              });
              onItemSelected(entry.key); // 触发外部回调
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.all(5),
              child: Material(
                  color: _selectedIndex == entry.key ? Colors.blue : Colors.grey,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      height: 40,
                      child: Row(
                        children: [
                          Text(entry.value.first,
                              style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold)),
                          if (entry.value.second != null && entry.value.second != '')
                            Text(' (${entry.value.second})', style: const TextStyle(color: Colors.white60, fontSize: 12))
                        ],
                      ))),
              // Text(entry.value, style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold)),
            )))
        .toList();
    return widgets;
  }
}
