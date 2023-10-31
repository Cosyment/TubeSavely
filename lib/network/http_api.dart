class HttpApi {
  static String baseUrl = 'https://openai.api.firefix.cn';

  // static String baseUrl = 'http://192.168.70.85:8083';
  static const String login = "/tUser/login";
  static const String updateApp = "";
  static const String sendVerCode = "/tVerCode/sendCode";
  static const String getUser = "/tUser/getUser";
  static const String submitFeedback = "/tFeedback/submit";
  static const String submitLiveStream = "/tPushStream/submitLiveStream";
  static const String getStreamInfo = "/tPushStream/getStreamInfo";
  static const String videoParse = "/videoParse/parse";
  static const String aliPay = "/aliPay/buildOrder";

}
