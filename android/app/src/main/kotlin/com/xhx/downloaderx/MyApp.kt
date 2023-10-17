package com.xhx.downloaderx

import android.app.Application
import com.umeng.commonsdk.UMConfigure

class MyApp : Application() {

    override fun onCreate() {
        super.onCreate()
        UMConfigure.preInit(this, "652e62c3b2f6fa00ba65ae50", AppInfo.getAppChannelId(this))
    }

}