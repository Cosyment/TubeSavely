import 'package:flutter/material.dart';

class AboutWePage extends StatefulWidget {
  const AboutWePage({super.key});

  @override
  State<AboutWePage> createState() => _AboutWePageState();
}

class _AboutWePageState extends State<AboutWePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("关于我们"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
