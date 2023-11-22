import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class Constant {
  static const String agreementUrl =
      "https://img.firefix.cn/downloaderx/agreement.html";
  static const String privacyUrl =
      "https://img.firefix.cn/downloaderx/privacy.html";
  static const String termsUseUrl =
      "https://www.apple.com/legal/internet-services/itunes/dev/stdeula";
  static const String isAgree = "is_agree";
  static const String isInAppReviewKey = "isInAppReviewKey";
  static String userId = "";
  static String appChannelId = "";
  static const pingtaiList = [
    {
      "bg": "iconspxkx.png",
      "isLock": false,
      "title": "皮皮虾",
    },
    // {
    //   "bg": "iconspyoutube.png",
    //   "isLock": false,
    //   "title": "YouTube",
    // },
    {
      "bg": "iconspzy.png",
      "isLock": false,
      "title": "最右",
    },
    {
      "bg": "iconspbilibili.png",
      "isLock": false,
      "title": "哔哩哔哩",
    },
    {
      "bg": "iconspchangku.png",
      "isLock": true,
      "title": "场库",
    },
    {
      "bg": "iconspdoupai.png",
      "isLock": true,
      "title": "都拍",
    },
    {
      "bg": "iconspdy.png",
      "isLock": true,
      "title": "抖音",
    },
    {
      "bg": "iconsphk.png",
      "isLock": true,
      "title": "sphk",
    },
    {
      "bg": "iconsphs.png",
      "isLock": true,
      "title": "火山",
    },
    {
      "bg": "iconspippzone.png",
      "isLock": true,
      "title": "是",
    },
    {
      "bg": "iconspjianying.png",
      "isLock": true,
      "title": "剪映",
    },
    {
      "bg": "iconspkandian.png",
      "isLock": true,
      "title": "腾讯看点",
    }
  ];

  static List<dynamic> tutorialList = [
    {
      "content": "打开短视频软件，播放您需要的短视频，点击分享，并滑动找到“复制链接”。",
      "title": "如何获取视频解析地址？",
      "type": 1,
      "isExpanded": true
    },
    {
      "content": "抖音、快手、西瓜视频、TikTok、YouTobe、bilibili、小红书、微博、等180个平台",
      "title": "支持哪些视频平台？",
      "isExpanded": false
    },
    {
      "content": "每个平台大致差不多举例说明:\nbilibili：无粉丝数量限制只需要实名认证后即可直播,登录网页版本然后再打开https://link.bilibili.com/p/center/index#/my-room/start-live\n 知乎：无粉丝数量限制，实名认证后即可直播,登录网页版本然后再打开https://www.zhihu.com/creator/streaming/push\n微博：粉丝大于50人，实名认证后即可直播,登录网页版本然后再打开https://weibo.com/manage/frame?furl=https%3A%2F%2Fweibo.com%2Fl%2Fwblive%2Fadmin%2Fhome%2Fauthentication\n",
      "title": "如何获取直播服务器地址、串流秘钥？",
      "type": 2,
      "isExpanded": true
    },
    {
      "content":
          "本软件去水印的成功率在99%以上,解析失败或者点击解析无反应主要原因:1.原视频被屏蔽无法解析2.原视频为私密视频他人不可看3.某些作者在上传时候自己加了水印，属于视频内置水印，无法解析",
      "title": "提取的视频还有水印?",
      "isExpanded": false
    },
    {
      "content": "请尝试再次解析，或检查网络环境，有些海外平台需要网络环境支持",
      "title": "提示视频解析失败?",
      "isExpanded": false
    },
    {
      "content": "间隔时间过长下载失败原因是视频链接已失效，需要复制原始链接重新解析",
      "title": "提取视频下载失败?",
      "isExpanded": false
    },
    {
      "content": "开启相册权限后，默认我们会将视频保存在相册里。",
      "title": "解析后的视频保存在什么位置?",
      "isExpanded": false
    },
  ];

  static var meList = [
    {
      'title': '',
      'content': '多种比列裁剪',
      'type': RequestType.video,
      'icon': Icons.crop,
    },
    {
      'title': '',
      'content': '分段视频剪辑',
      'type': RequestType.video,
      'icon': Icons.content_cut,
    },
    {
      'title': '',
      'content': '一键倒放功能',
      'type': RequestType.video,
      'icon': Icons.turn_left,
    },
    {
      'title': '',
      'content': '各种角度旋转',
      'type': RequestType.video,
      'icon': Icons.crop_rotate,
    },
    {
      'title': '',
      'content': '支持视频加速减速',
      'type': RequestType.video,
      'icon': Icons.speed,
    },
    {
      'title': '',
      'content': '支持质量压缩',
      'type': RequestType.video,
      'icon': Icons.compress,
    },
    {
      'title': '',
      'content': '生成视频视图',
      'type': RequestType.video,
      'icon': Icons.screenshot,
    },
    // {
    //   'title': '',
    //   'content': '多个视频合并',
    //   'type': RequestType.video,
    //   'icon': Icons.merge,
    // },
    {
      'title': '',
      'content': '支持各种格式',
      'type': RequestType.video,
      'icon': Icons.gif,
    },
    {
      'title': '',
      'content': '支持多种样式',
      'type': RequestType.video,
      'icon': Icons.unfold_less,
    },
    {
      'title': '',
      'content': '去除视频声音',
      'type': RequestType.video,
      'icon': Icons.music_off,
    },
  ];
}

class Urls {

  static const openaiKeysUrl = 'https://platform.openai.com/account/api-keys';
  static const privacyUrl = 'https://chat.cosyment.com/privacy.html';
  static const termsUrl = 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula';
  static const appStoreUrl = 'https://apps.apple.com/us/app/id6455787500?l=en-us&platform=iphone';
  static const googlePlayUrl = 'https://play.google.com/store/apps/details?id=com.waiting.ai.chatbot';
  static const muyuGooglePlayUrl = 'https://play.google.com/store/apps/details?id=com.xhx.woodenfishs';
  static const qrCodeGooglePlayUrl = 'https://play.google.com/store/apps/details?id=com.zy.ksymscan';
}
