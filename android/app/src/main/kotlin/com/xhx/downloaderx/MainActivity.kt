package com.xhx.downloaderx

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(MethodPlugin())
    }

}
