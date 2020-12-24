import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Fonbnk/home_page.dart';
import 'package:flutter/services.dart';
import 'package:wifi_iot/wifi_iot.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // List<WifiNetwork> _htResultNetwork = [];

  bool _isInit = true;
  // Future<List<WifiNetwork>> loadWifiList() async {
  //   print("Loading..");
  //   List<WifiNetwork> htResultNetwork;
  //   try {
  //     htResultNetwork = await WiFiForIoTPlugin.loadWifiList();
  //     for (var i = 0; i < htResultNetwork.length; i++) {
  //       if (htResultNetwork[i].capabilities == "[ESS]") {
  //         _htResultNetwork.add(htResultNetwork[i]);
  //         print("capabilities " + htResultNetwork[i].capabilities);
  //         print("bssid " + htResultNetwork[i].bssid);
  //         print("frequency " + htResultNetwork[i].frequency.toString());
  //         print("level" + htResultNetwork[i].level.toString());
  //         print("ssid " + htResultNetwork[i].ssid);
  //         print(htResultNetwork[i].password);
  //       }
  //     }
  //     print(_htResultNetwork);
  //     _htResultNetwork = htResultNetwork;
  //     setState(() {});
  //   } on PlatformException {
  //     htResultNetwork = List<WifiNetwork>();
  //   }
  //   return htResultNetwork;
  // }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_isInit) {
      Timer(Duration(seconds: 1), () {
        Navigator.of(context).pushReplacement(CupertinoPageRoute(
            builder: (BuildContext context) => MyHomePage()));
      });
    }
    setState(() {
      _isInit = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: height / 4,
              width: width / 4,
              child: Image.asset('assets/Fonbnk_dingbat.png'),
            ),
            Text(
              "Fonbnk",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                  color: Color(0xFF08B15B)),
            ),
            // RaisedButton(onPressed: () {
            //   Navigator.of(context).push(CupertinoPageRoute(
            //       builder: (BuildContext context) => MyHomePage()));
            // })
          ],
        ),
      ),
    );
  }
}
