import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class Constant {
  static const String agreementUrl =
      "https://img.firefix.cn/fish/agreement.html";
  static const String privacyUrl = "https://img.firefix.cn/fish/privacy.html";
  static const String termsUseUrl =
      "https://www.apple.com/legal/internet-services/itunes/dev/stdeula";
  static const String isAgree = "is_agree";
  static const String isInAppReviewKey = "isInAppReviewKey";
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

  static List<dynamic> tutorialList = [
    {
      "content": "打开短视频软件，播放您需要的短视频，点击分享，并滑动找到“复制链接”。",
      "title": "如何获取视频解析地址？",
      "type": 1,
      "isExpanded": false
    },
    {
      "content": "抖音、快手、微博、哔哩哔哩、YouTobe、",
      "title": "支持哪些视频平台？",
      "isExpanded": false
    },
    {
      "content": "哔哩哔哩直播 电脑网页端打开哔哩哔哩并登录,找到如下页面点击开播",
      "title": "如何获取直播服务器地址、串流秘钥？",
      "type": 2,
      "isExpanded": true
    },
    {
      "content":
          "本软件能解析99%以上的视频，但若原作者上传的视频本来就有水印暂无法去除。原视频是否有水印请查看对应APP播放时是否有水印",
      "title": "提取的视频还有水印?",
      "isExpanded": false
    },
    {
      "content": "请尝试在浏览器中打开视频链接，若浏览器无法打开则说明视频已经失效，无法解析。",
      "title": "提示视频解析失败?",
      "isExpanded": false
    },
    {
      "content": "请确认是否为图集，图集可以直接浏览器打开链接，长按保存。",
      "title": "提取视频下载失败?",
      "isExpanded": false
    },
    {
      "content": "开启相册权限后，默认我们会将视频保存在相册里。",
      "title": "解析后的视频保存在什么位置?",
      "isExpanded": false
    },
  ];

  static const meList = [
    {
      'title': '视频裁剪',
      'content': '多种比列裁剪',
      'type': RequestType.video,
      'icon': Icons.content_cut,
    },
    {
      'title': '视频剪辑',
      'content': '分段视频剪辑',
      'type': RequestType.video,
      'icon': Icons.content_cut,
    },
    {
      'title': '视频倒放',
      'content': '一键倒放功能',
      'type': RequestType.video,
      'icon': Icons.turn_left,
    },
    {
      'title': '视频旋转',
      'content': '各种角度旋转',
      'type': RequestType.video,
      'icon': Icons.crop_rotate,
    },
    {
      'title': '视频变速',
      'content': '支持视频加速减速',
      'type': RequestType.video,
      'icon': Icons.speed,
    },
    {
      'title': '视频压缩',
      'content': '支持质量压缩',
      'type': RequestType.video,
      'icon': Icons.compress,
    },
    {
      'title': '视频截图',
      'content': '生成视频视图',
      'type': RequestType.video,
      'icon': Icons.screenshot,
    },
    {
      'title': '视频合并',
      'content': '多个视频合并',
      'type': RequestType.video,
      'icon': Icons.merge,
    },
    {
      'title': '视频转GIF',
      'content': '支持各种格式',
      'type': RequestType.video,
      'icon': Icons.gif,
    },
    {
      'title': '视频镜像',
      'content': '支持多种样式',
      'type': RequestType.video,
      'icon': Icons.unfold_less,
    },
    {
      'title': '视频去声音',
      'content': '去除视频声音',
      'type': RequestType.video,
      'icon': Icons.music_off,
    },
  ];
}
