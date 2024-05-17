package com.xhx.video.saver

import android.app.Application
import com.umeng.commonsdk.UMConfigure

class App : Application() {

    override fun onCreate() {
        super.onCreate()
        UMConfigure.preInit(this, "652e62c3b2f6fa00ba65ae50", AppInfo.getAppChannelId(this))
    }

}