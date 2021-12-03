import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'main.dart';

class WebViewActivity extends StatefulWidget {
  // final Process process;

  // WebViewActivity(this.process);

  @override
  _WebViewActivityState createState() => _WebViewActivityState();
}

class _WebViewActivityState extends State<WebViewActivity> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  WebViewController controllerGlobal;
  String url = "";

  @override
  void initState() {
    super.initState();
    getUrl();
  }

  @override
  void dispose() {
    BackButtonInterceptor.removeByName("SomeName");
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("Back press");
    exitApp(context);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    BackButtonInterceptor.add(myInterceptor);
    return WillPopScope(
      // onWillPop: () => exitApp(context),
      child: SafeArea(
        child: Scaffold(
          // appBar: AppBar(
          //   backgroundColor: Color(0xff1e467e),
          //   leading: Builder(
          //     builder: (context) {
          //       return IconButton(
          //         onPressed: () async {
          //           if (await controllerGlobal.canGoBack()) {
          //             print("onwill goback");
          //             controllerGlobal.goBack();
          //           } else {
          //             Scaffold.of(context).showSnackBar(
          //               const SnackBar(content: Text("No back history item")),
          //             );
          //             return Future.value(false);
          //           }
          //         },
          //         icon: Icon(
          //           Icons.arrow_back,
          //           color: Colors.blue,
          //         ),
          //       );
          //     },
          //   ),
          //   elevation: 1,
          //   centerTitle: true,
          //   title: Text(
          //     "TekDial",
          //     style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
          //   ),
          // ),
          body: url.isEmpty
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : WebView(
                  initialUrl: url,
                  debuggingEnabled: true,
                  userAgent: 'Chrome/62.0.3202.94',
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebResourceError: (WebResourceError error) {
                    log("error--->$error");
                  },
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller.complete(webViewController);
                    controllerGlobal = webViewController;
                  },
                  navigationDelegate: (NavigationRequest request) {
                    log("NavigationRequest--->${request.url}");
                    // if (request.url.startsWith(url)) {
                    //   return NavigationDecision.prevent;
                    // }

                    return NavigationDecision.navigate;
                  },
                  onPageStarted: (String url) {
                    log("onPageStarted--->$url");
                  },
                  onPageFinished: (String url) {
                    log("onPageFinished--->$url");
                  },
                  gestureNavigationEnabled: true,
                  javascriptChannels: <JavascriptChannel>[
                    _toasterJavascriptChannel(context),
                  ].toSet(),
                ),
        ),
      ),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  Future<bool> exitApp(BuildContext context) async {
    if (await controllerGlobal.canGoBack()) {
      print("onwill goback");
      controllerGlobal.goBack();
    } else {
      Scaffold.of(context).showSnackBar(
        const SnackBar(content: Text("No back history item")),
      );
    }
    return Future.value(false);
  }

  void _launchURL(BuildContext context, String url) async {
    try {
      await launch(
        // 'http://103.251.143.67:2390/agc/timbl.php',
        '$url',
        option: new CustomTabsOption(
          toolbarColor: Theme.of(context).primaryColor,

          enableDefaultShare: true,
          enableUrlBarHiding: true,
          showPageTitle: true,
          // animation: new CustomTabsAnimation.slideIn()
          // or user defined animation.
          animation: new CustomTabsAnimation(
            startEnter: 'slide_up',
            startExit: 'android:anim/fade_out',
            endEnter: 'android:anim/fade_in',
            endExit: 'slide_down',
          ),
          extraCustomTabs: <String>[
            // ref. https://play.google.com/store/apps/details?id=org.mozilla.firefox
            'org.mozilla.firefox',
            // ref. https://play.google.com/store/apps/details?id=com.microsoft.emmx
            'com.microsoft.emmx',
          ],
        ),
      );
    } catch (e) {
      // An exception is thrown if browser app is not installed on Android device.
      debugPrint(e.toString());
    }
  }

  void getUrl() async {
    try {
      var type = 0;
      if (Platform.isAndroid) {
        type = 1;
      }
      if (Platform.isIOS) {
        type = 2;
      }

      Map input = HashMap<String, dynamic>();
      input["method"] = "appVersion";
      input["type"] = type.toString();
      input["version"] = "1.1";

      Response res = await dio.post("http://vv.tekzee.in/mobileapi.php", data: input, options: Options(method: "POST"));
      log(res.toString());
      if (res.statusCode == 200) {
        Map result = res.data;

        if (result["status"].toString().contains("true")) {
          url = result["url"];
          log(url.toString());
          setState(() {});
          // _launchURL(context, url);
        } else {
          Fluttertoast.showToast(
              msg: result["message"],
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.SNACKBAR,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      }
    } catch (e) {
      log(e.toString());
      Fluttertoast.showToast(
          msg: "Internal server error!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
