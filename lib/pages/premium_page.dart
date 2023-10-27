import 'dart:async';
import 'dart:io';

import 'package:downloaderx/data/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:lottie/lottie.dart';
import 'package:shake_animation_widget/shake_animation_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/constant.dart';
import '../generated/l10n.dart';
import '../utils/platform_utils.dart';

class PremiumScreenPage extends StatefulWidget {
  const PremiumScreenPage({super.key});

  @override
  State<StatefulWidget> createState() => _PremiumScreen();
}

class _PremiumScreen extends State<StatefulWidget> {
  final LinearGradient gradientColor = const LinearGradient(
      colors: [Color(0xFF2EC0FF), Color(0xFF5394FF), Color(0xFF7769FF), Color(0xFFB360EC), Color(0xFFEE56D9)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight);

  final List<String> _premiumFeatures = ['特性1', '特性2', '特性3', '特性4', '特性5'];
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late bool isAvailable = false;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  final List<String> _identifiers = [ 'com.tube.video.saver.monthly', 'com.tube.video.saver.quarterly', 'com.tube.video.saver.yearly'];
  List<ProductDetails> _products = <ProductDetails>[];
  var _checkedIndex = 0;
  var _manualRestore = false;
  final ShakeAnimationController _shakeAnimationController = ShakeAnimationController();

  void initStoreInfo() async {
    isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      return;
    }
    _inAppPurchase.restorePurchases();

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(PaymentQueueDelegate());
    }

    getProducts();

    finishTransaction();
  }

  void getProducts() async {
    ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_identifiers.toSet());
    setState(() {
      _products = response.productDetails;
      _products.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
      int index = _identifiers.indexOf(LocalStorageService().getCurrentMembershipProductId(), 0);
      _checkedIndex = index < 0 ? 0 : index;
    });
    subscription();
  }

  void subscription() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      debugPrint('purchase done');
      _subscription.cancel();
    }, onError: (Object error) {
      // handle error here.
      debugPrint('purchase error $error');
    });
  }

  void finishTransaction() async {
    if (Platform.isIOS) {
      var paymentWrapper = SKPaymentQueueWrapper();
      var transactions = await paymentWrapper.transactions();
      transactions.forEach((transaction) async {
        await paymentWrapper.finishTransaction(transaction);
      });
    }
  }

  Future<void> listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    debugPrint('listenToPurchaseUpdated purchaseDetailsList.length ${purchaseDetailsList.length}');

    //未订阅过
    if (purchaseDetailsList.isEmpty) {
      if (context.mounted && Navigator.canPop(context) && _manualRestore) {
        showToast(S.current.nothing_to_restore);
        Navigator.pop(context);
        _manualRestore = false;
        setState(() {
          LocalStorageService().remove(LocalStorageService.prefMembershipProductId);
        });
        return;
      }
    }

    //交易日期从远到近排序
    purchaseDetailsList
        .sort((a, b) => (int.tryParse(a.transactionDate ?? '') ?? 0).compareTo(int.tryParse(b.transactionDate ?? '') ?? 0));

    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('purchase pending... productId: ${purchaseDetails.productID}, purchaseId: ${purchaseDetails.purchaseID}');
        showLottieDialog(context, 'assets/lottie/loading.json');
      } else {
        if (context.mounted && Navigator.canPop(context)) {
          // if (Platform.isMacOS || PlatformUtil.isLandscape(context)) {
          //   Navigator.pop(context);
          // }
        }

        if (purchaseDetails.status == PurchaseStatus.error) {
          debugPrint('purchase error ${purchaseDetails.status}');
          showToast(S.current.purchase_failure);
          finishTransaction();
        } else if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored) {
          debugPrint(
              'purchase status ${purchaseDetails.status}, productId: ${purchaseDetails.productID}, purchaseId: ${purchaseDetails.purchaseID} , transactionDate: ${purchaseDetails.transactionDate}');

          if (context.mounted) {
            if (purchaseDetails.status == PurchaseStatus.purchased) {
              showLottieDialog(context, 'assets/lottie/animation_ll82qc8x.json');
              Future.delayed(const Duration(milliseconds: 2500), () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                showToast(S.current.purchase_success);
              });
              setState(() {
                LocalStorageService().currentMembershipProductId = purchaseDetails.productID;
              });
            } else {
              // todo handle restored
            }
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          debugPrint('purchase pendingCompletePurchase ${purchaseDetails.status}');
          purchaseDetails.pendingCompletePurchase = true;
          await _inAppPurchase.completePurchase(purchaseDetails);
          finishTransaction();
          if (purchaseDetails.status == PurchaseStatus.canceled) {
            showToast(S.current.purchase_cancel);
          }
        }
      }
    }
  }

  //获取老订单
  Future<GooglePlayPurchaseDetails?> _getOldSubscription() async {
    GooglePlayPurchaseDetails? oldSubscription;
    if (Platform.isAndroid) {
      final InAppPurchaseAndroidPlatformAddition androidAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      QueryPurchaseDetailsResponse oldPurchaseDetailsQuery = await androidAddition.queryPastPurchases();

      oldPurchaseDetailsQuery.pastPurchases.forEach((element) {
        if (element.status == PurchaseStatus.purchased) {
          oldSubscription = element;
        }
      });
    }
    return oldSubscription;
  }

  String convertProductTitle(productId) {
    switch (productId) {
      case 'membership_weekly':
        return S.current.premium_weekly;
      case 'membership_monthly':
        return S.current.premium_monthly;
      case 'membership_quarterly':
        return S.current.premium_quarterly;
      case 'membership_yearly':
        return S.current.premium_yearly;
    }
    return '';
  }

  Future<void> showLottieDialog(BuildContext context, String name) => showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (BuildContext context) {
        return Center(child: Lottie.asset(name, repeat: true));
      });

  void showToast(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFFCFCFD2),
        // action: SnackBarAction(
        //   label: S.current.resend,
        //   onPressed: () {},
        // ),
      ),
    );
  }

  void startShake() async {
    Future.delayed(const Duration(seconds: 1), () async {
      _shakeAnimationController.start(shakeCount: 1);
      await Future.delayed(const Duration(milliseconds: 2500));
      startShake();
    });
    // Future.delayed(const Duration(seconds: 3), () => {startShake()});
  }

  @override
  void initState() {
    initStoreInfo();
    startShake();

    super.initState();
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
      finishTransaction();
    }
    _subscription.cancel();
    _shakeAnimationController.removeListener();
    _shakeAnimationController.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        key: scaffoldMessengerKey,
        child: Stack(fit: StackFit.passthrough, alignment: AlignmentDirectional.topCenter, children: [
          Scaffold(
              appBar: AppBar(title: Text(S.current.premium, style: const TextStyle(overflow: TextOverflow.ellipsis))),
              body: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: PlatformUtils.isAndroidOrIOS ? 180 : 110,
                      height: PlatformUtils.isAndroidOrIOS ? 180 : 110,
                      child: Lottie.asset('assets/lottie/animation_ll82pe8f.json', repeat: true),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${S.current.appName} ${S.current.premium_plus_explain}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: _generateFeatureItems(),
                    ),
                    SizedBox(height: PlatformUtils.isAndroidOrIOS ? 20 : 10),
                    if (_products.isEmpty)
                      Shimmer.fromColors(
                        baseColor: Colors.white10,
                        highlightColor: Colors.white12,
                        enabled: true,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _membershipPlaceholder(),
                            _membershipPlaceholder(),
                            _membershipPlaceholder(),
                          ],
                        ),
                      ),
                    if (_products.isNotEmpty)
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                              height: PlatformUtils.isAndroidOrIOS ? 130 : 115,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: _membershipOptions(),
                              ))),
                    const SizedBox(height: 25),
                    ShakeAnimationWidget(
                        //抖动控制器
                        shakeAnimationController: _shakeAnimationController,
                        //微旋转的抖动
                        shakeAnimationType: ShakeAnimationType.RoateShake,
                        //设置不开启抖动
                        isForward: false,
                        //默认为 0 无限执行
                        shakeCount: 0,
                        //抖动的幅度 取值范围为[0,1]
                        shakeRange: 0.03,
                        //执行抖动动画的子Widget
                        child: Card(
                            elevation: 5,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.all(Radius.circular(50))),
                            shadowColor: gradientColor.colors[2],
                            child: Container(
                                width: 250,
                                height: 50,
                                decoration: BoxDecoration(
                                    gradient: gradientColor,
                                    borderRadius: const BorderRadiusDirectional.all(Radius.circular(50))),
                                child: ElevatedButton(
                                    onPressed: () async {
                                      HapticFeedback.mediumImpact();
                                      if (isAvailable) {
                                        final ProductDetails productDetail = _products[_checkedIndex];
                                        PurchaseParam purchaseParam;
                                        if (Platform.isAndroid) {
                                          final GooglePlayPurchaseDetails? oldSubscription = await _getOldSubscription();
                                          purchaseParam = GooglePlayPurchaseParam(
                                              productDetails: productDetail,
                                              changeSubscriptionParam: (oldSubscription != null)
                                                  ? ChangeSubscriptionParam(
                                                      oldPurchaseDetails: oldSubscription,
                                                      prorationMode: ProrationMode.immediateWithTimeProration,
                                                    )
                                                  : null);
                                        } else {
                                          finishTransaction();
                                          purchaseParam = PurchaseParam(productDetails: productDetail);
                                        }
                                        _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
                                      } else {
                                        showToast(S.current.purchase_error);
                                      }
                                    },
                                    style: ButtonStyle(
                                      shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                                      elevation: MaterialStateProperty.all(10.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                                      child: Text(
                                        S.current.subscribe,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ))))),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _agreementWidget(S.current.terms_use, () async {
                          await launchUrl(Uri.parse(Constant.termsUseUrl), mode: LaunchMode.inAppWebView);
                        }),
                        _agreementWidget(S.current.privacy_policy, () async {
                          await launchUrl(Uri.parse(Constant.privacyUrl), mode: LaunchMode.inAppWebView);
                        }),
                        _agreementWidget(S.current.restore, () {
                          showLottieDialog(context, 'assets/lottie/loading.json');
                          _manualRestore = true;
                          _inAppPurchase.restorePurchases();
                        })
                      ],
                    )
                  ],
                ),
              ))
        ]));
  }

  List<Widget> _generateFeatureItems() {
    List<Widget> widgets = <Widget>[];
    for (var element in _premiumFeatures) {
      widgets.add(Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(
          Icons.task_alt_outlined,
          color: Colors.green,
          size: 16,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          element,
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold),
        )
      ]));
    }
    return widgets;
  }

  Widget _membershipPlaceholder() {
    return Card(margin: const EdgeInsets.all(10), child: SizedBox(width: 100, height: Platform.isMacOS ? 95 : 110));
  }

  List<Widget> _membershipOptions() {
    List<Widget> widgets = <Widget>[];
    for (var index = 0; index < _products.length; index++) {
      ProductDetails productDetails = _products[index];
      widgets.add(GestureDetector(
        child: Card(
          elevation: 5,
          shadowColor: index == _checkedIndex ? gradientColor.colors[0] : Colors.white10,
          margin: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            alignment: AlignmentDirectional.center,
            decoration: BoxDecoration(
                gradient: _checkedIndex == index ? gradientColor : null,
                borderRadius: const BorderRadiusDirectional.all(Radius.circular(10))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Text(
                      convertProductTitle(productDetails.id),
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: _checkedIndex == index ? Colors.grey[200] : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      productDetails.price,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _checkedIndex == index ? Colors.grey[100] : Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      productDetails.description,
                      style: TextStyle(
                        fontSize: 10,
                        color: _checkedIndex == index ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    if (productDetails.id == LocalStorageService().getCurrentMembershipProductId())
                      Text(
                        S.current.current_level,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
        onTap: () {
          HapticFeedback.mediumImpact();
          setState(() {
            _checkedIndex = index;
          });
        },
      ));
    }
    return widgets;
  }

  Widget _agreementWidget(String title, Function pressed) {
    return TextButton(
        onPressed: () {
          pressed();
        },
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            decoration: TextDecoration.underline,
            decorationColor: Colors.white,
          ),
        ));
  }
}

class PaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
