import 'package:flutter/material.dart';

class Constant {
  static const String agreementUrl =
      "https://img.firefix.cn/fish/agreement.html";
  static const String privacyUrl = "https://img.firefix.cn/fish/privacy.html";
  static const String termsUseUrl =
      "https://www.apple.com/legal/internet-services/itunes/dev/stdeula";
  static const String isAgree = "is_agree";
  static const pingtaiList = [
    {
      "bg": "iconspxkx.png",
      "isLock": false,
      "title": "皮皮虾",
    },
    {
      "bg": "iconspyoutube.png",
      "isLock": false,
      "title": "YouTube",
    },
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

  static const tutorialList = [
    {
      "content": "打开短视频软件，播放您需要的短视频，点击分享，并滑动找到“复制链接”。",
      "title": "如何获取视频链接?",
    },
    {
      "content":
          "本软件能解析99%以上的视频，但若原作者上传的视频本来就有水印暂无法去除。原视频是否有水印请查看对应APP播放时是否有水印",
      "title": "提取的视频还有水印?",
    },
    {
      "content": "请尝试在浏览器中打开视频链接，若浏览器无法打开则说明视频已经失效，无法解析。",
      "title": "提示视频解析失败?",
    },
    {
      "content": "请确认是否为图集，图集可以直接浏览器打开链接，长按保存。",
      "title": "提取视频下载失败?",
    },
    {
      "content": "开启相册权限后，默认我们会将视频保存在相册里。",
      "title": "解析后的视频保存在什么地方?",
    },
  ];



  static const meList = [
    {
      'title': '视频裁剪',
      'content': '多种比列裁剪',
      'type': '视频裁剪',
      'icon': Icons.content_cut,
    },
    {
      'title': '视频倒放',
      'content': '一键倒放功能',
      'type': '视频倒放',
      'icon': Icons.turn_left,
    },
    {
      'title': '视频旋转',
      'content': '各种角度旋转',
      'type': '视频旋转',
      'icon': Icons.crop_rotate,
    },
    {
      'title': '视频变速',
      'content': '支持视频加速减速',
      'type': '视频变速',
      'icon': Icons.speed,
    },
    {
      'title': '视频压缩',
      'content': '支持质量压缩',
      'type': '视频压缩',
      'icon': Icons.compress,
    },
    {
      'title': '视频截图',
      'content': '生成视频视图',
      'type': '视频截图',
      'icon': Icons.screenshot,
    },
    {
      'title': '视频合并',
      'content': '多个视频合并',
      'type': '视频合并',
      'icon': Icons.merge,
    },
    {
      'title': '视频转GIF',
      'content': '支持各种格式',
      'type': '视频转GIF',
      'icon': Icons.gif,
    },
    {
      'title': '视频镜像',
      'content': '支持多种样式',
      'type': '视频镜像',
      'icon': Icons.gif,
    },
    {
      'title': '视频去声音',
      'content': '去除视频声音',
      'type': '视频去声音',
      'icon': Icons.gif,
    },
  ];
}
