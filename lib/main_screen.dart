import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Fonbnk/home_page.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 1), () {
      Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (BuildContext context) => MyHomePage()));
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
