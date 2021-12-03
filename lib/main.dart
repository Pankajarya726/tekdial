import 'dart:async';
import 'dart:developer';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tekdial/get_process_response.dart';
import 'package:tekdial/webview_activity.dart';
import 'package:webview_flutter/webview_flutter.dart';

var dio = Dio();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.blue, statusBarBrightness: Brightness.dark, statusBarColor: Colors.blueAccent));
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  dio.interceptors.add(LogInterceptor(
      request: true,
      responseBody: true,
      error: true,
      responseHeader: true,
      requestHeader: true,
      requestBody: true,
      logPrint: (message) {
        log(message);
      }));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
      ),
      home: WebViewActivity(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Process> processList = List();

  final Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    getProcess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(30, 71, 126, 1),
          leading: Builder(
            builder: (context) {
              return IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.blue,
                ),
              );
            },
          ),
          elevation: 1,
          centerTitle: true,
          title: Text(
            "TekDial",
            style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        body: processList.isEmpty
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WebViewActivity(processList[index])));
                    },
                    title: Text(processList[index].name),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    color: Colors.grey,
                  );
                },
                itemCount: processList.length));
  }

  void getProcess() async {
    if (await check()) {
      try {
        Dio dio = Dio();

        Response response = await dio.get("http://tekdev.tekzee.in/tekdial/dialerapi.php?getProcesses");

        if (response.statusCode == 200) {
          GetProcessResponse processResponse = GetProcessResponse.fromJson(response.toString());

          if (processResponse.success) {
            setState(() {
              processList = processResponse.process;
            });
          } else {
            print("could not found process");
          }
        } else {
          print("internal server error");
        }
      } catch (exception) {
        Dio dio = Dio();
      }
    } else {
      print("No internet");
    }
  }
}

Future<bool> check() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  print(connectivityResult.toString());
  return false;
}
