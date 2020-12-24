import 'dart:math' show cos, sqrt, asin;
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:wifi_iot/wifi_iot.dart';

class MyHomePage extends StatefulWidget {
  // final List<WifiNetwork> htResultNetwork;

  // MyHomePage({this.htResultNetwork});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform =
      const MethodChannel('samples.flutter.dev/wifimap.sample');
  List<Map<String, dynamic>> listHotspot = [];
  List<Map<String, dynamic>> newListHotspot = [];

  List<double> distanceList = [];
  List<WifiNetwork> _htResultNetwork = [];

  bool _isInit = true,
      _isLoad = false,
      _isConnecting = false,
      _isEnabled = false;

  double calculateDistance(lat1, lon1, lat2, lon2) {
    // var p = 0.017453292519943295;
    // var c = cos;
    // var a = 0.5 -
    //     c((lat2 - lat1) * p) / 2 +
    //     c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    // return 12742 * asin(sqrt(a));
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // getNearMeHotspot(double lat, double lng) {
  //   for (var i = 1; i < listHotspot.length; i++) {
  //     // print(listHotspot[i]['longitude']);
  //     // print(i);
  //     double dist = calculateDistance(
  //         lat,
  //         lng,
  //         double.parse(listHotspot[i]['Location(latitude']),
  //         double.parse(listHotspot[i]['longitude'].split(')').first));
  //     // Geodesy geodesy = Geodesy();
  //     // LatLng l1 = LatLng(lat, lng);
  //     // LatLng l2 = LatLng(double.parse(listHotspot[i]['Location(latitude']),
  //     //     double.parse(listHotspot[i]['longitude'].split(')').first));
  //     // print(geodesy.distanceBetweenTwoGeoPoints(l1, l2));
  //     distanceList.add(dist);
  //     print(listHotspot[i]['User(user'] == null
  //         ? "hello"
  //         : listHotspot[i]['User(user'].split(')))').first);
  //   }
  //   print(distanceList);
  // }

  storeAndConnect(String psSSID, String psKey) async {
    // await storeAPInfos();
    await WiFiForIoTPlugin.setWiFiAPSSID(psSSID);
    await WiFiForIoTPlugin.setWiFiAPPreSharedKey(psKey);
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_isInit) {
      try {
        setState(() {
          _isLoad = true;
        });
        LocationPermission permission;
        permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.deniedForever) {
          return Future.error(
              'Location permissions are permantly denied, we cannot request permissions.');
        }
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        List<WifiNetwork> htResultNetwork;

        htResultNetwork = await WiFiForIoTPlugin.loadWifiList();
        for (var i = 0; i < htResultNetwork.length; i++) {
          if (htResultNetwork[i].capabilities == "[ESS]") {
            _htResultNetwork.add(htResultNetwork[i]);
            print("capabilities " + htResultNetwork[i].capabilities);
            print("bssid " + htResultNetwork[i].bssid);
            print("frequency " + htResultNetwork[i].frequency.toString());
            print("level" + htResultNetwork[i].level.toString());
            print("ssid " + htResultNetwork[i].ssid);
            print(htResultNetwork[i].password);
          }
        }
        print(_htResultNetwork);
        _htResultNetwork = htResultNetwork;
        setState(() {});

        final result = await platform.invokeMethod('fetch', {
          "lat": position.latitude,
          "lng": position.longitude,
        });
        print(result);
        setState(() {
          _isLoad = false;
        });
        List<dynamic> newStr = result.split('Hotspot(');
        newStr.map((e) {
          List<dynamic> listFirst = e.split(',');
          Map<String, dynamic> map = {};
          listFirst.map((val) {
            List<dynamic> listSplitVal = val.split('=');
            print(listSplitVal);
            if (listSplitVal.length > 1) {
              if (listSplitVal.length == 3) {
                map.putIfAbsent(
                    listSplitVal[1].trim(), () => listSplitVal[2].toString());
              } else if (listSplitVal.length == 4) {
                map.putIfAbsent(
                    listSplitVal[2].trim(), () => listSplitVal[3].toString());
              } else {
                map.putIfAbsent(
                    listSplitVal[0].trim(), () => listSplitVal[1].toString());
              }
            }
          }).toList();
          listHotspot.add(map);
        }).toList();
        // print(listHotspot[1]['HotspotPlace(title']);
        for (var i = 1; i < listHotspot.length; i++) {
          double dist = calculateDistance(
              position.latitude,
              position.longitude,
              double.parse(listHotspot[i]['Location(latitude']),
              double.parse(listHotspot[i]['longitude'].split(')').first));
          if (dist < 599.00) {
            newListHotspot.add(listHotspot[i]);
          }
          distanceList.add(dist);
          // print(listHotspot[i]['User(user'] == null
          //     ? "hello"
          //     : listHotspot[i]['User(user'].split(')))').first);
        }
        print(newListHotspot);

        // getNearMeHotspot(position.latitude, position.longitude);
      } on PlatformException catch (e) {
        print(e);
      } catch (e) {
        print(e);
      }

      setState(() {});
    }
    _isInit = false;
  }

  @override
  void initState() {
    super.initState();
    print("Hello");
  }

  loadData() async {
    newListHotspot.clear();
    listHotspot.clear();
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final result = await platform.invokeMethod('fetch', {
      "lat": position.latitude,
      "lng": position.longitude,
    });
    print(result);

    List<dynamic> newStr = result.split('Hotspot(');
    newStr.map((e) {
      List<dynamic> listFirst = e.split(',');
      Map<String, dynamic> map = {};
      listFirst.map((val) {
        List<dynamic> listSplitVal = val.split('=');
        // print(listSplitVal);
        if (listSplitVal.length > 1) {
          if (listSplitVal.length == 3) {
            map.putIfAbsent(
                listSplitVal[1].trim(), () => listSplitVal[2].toString());
          } else if (listSplitVal.length == 4) {
            map.putIfAbsent(
                listSplitVal[2].trim(), () => listSplitVal[3].toString());
          } else {
            map.putIfAbsent(
                listSplitVal[0].trim(), () => listSplitVal[1].toString());
          }
        }
      }).toList();
      listHotspot.add(map);
    }).toList();
    // print(listHotspot[1]['HotspotPlace(title']);
    for (var i = 1; i < listHotspot.length; i++) {
      if (listHotspot[i]['Location(latitude'] != null) {
        double dist = calculateDistance(
            position.latitude,
            position.longitude,
            double.parse(listHotspot[i]['Location(latitude']),
            double.parse(listHotspot[i]['longitude'].split(')').first));
        if (dist < 599.00) {
          newListHotspot.add(listHotspot[i]);
        }
        distanceList.add(dist);
      }
    }
    print(newListHotspot.length);
  }

  @override
  Widget build(BuildContext context) {
    WiFiForIoTPlugin.isEnabled().then((val) {
      if (val != null) {
        setState(() {
          _isEnabled = val;
        });
      }
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF08B15B),
        title: Text("Fonbnk"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadData,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        color: Colors.red.withOpacity(.3),
        padding: EdgeInsets.all(15),
        child: Center(
          child: Text(
            "You are not allowed to connect password protected hotspot.",
            maxLines: 2,
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
      body: !_isEnabled
          ? Center(child: Text("Please turn on your Wifi!"))
          : Stack(
              children: [
                newListHotspot.length == 0 && _htResultNetwork.length == 0
                    ? Center(
                        child: Text("No data found"),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.builder(
                              physics: BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, i) {
                                return GestureDetector(
                                  onTap: _isConnecting
                                      ? null
                                      : () async {
                                          print("object");
                                          Scaffold.of(context)
                                              .hideCurrentSnackBar();
                                          setState(() {
                                            _isConnecting = true;
                                          });
                                          var status =
                                              await WiFiForIoTPlugin.connect(
                                                  _htResultNetwork[i].ssid,
                                                  joinOnce: true,
                                                  security:
                                                      NetworkSecurity.NONE);
                                          setState(() {
                                            _isConnecting = false;
                                          });
                                          if (status) {
                                            Scaffold.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(
                                                "Conneted successfully",
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor: Colors.green,
                                            ));
                                          } else {
                                            Scaffold.of(context)
                                                .showSnackBar(SnackBar(
                                              content: Text(
                                                "Something went wrong!",
                                              ),
                                              backgroundColor: Colors.red,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ));
                                          }
                                          print(status);
                                        },
                                  child: Container(
                                    // height: 100,
                                    margin: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        color: Color(0xFFffffff),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey,
                                              blurRadius: 5,
                                              spreadRadius: 1,
                                              offset: Offset(0, 1))
                                        ],
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          NameValuePair(
                                            value: _htResultNetwork[i].ssid,
                                            title: "Title : ",
                                          ),
                                          NameValuePair(
                                            value: _htResultNetwork[i].bssid,
                                            title: "Bssid : ",
                                          ),
                                          NameValuePair(
                                            value: _htResultNetwork[i]
                                                .frequency
                                                .toString(),
                                            title: "Frequency : ",
                                          ),
                                          // NameValuePair(
                                          //   value: place,
                                          //   title: "Category : ",
                                          // ),
                                          Row(
                                            children: [
                                              Text(
                                                "Password : ",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  _htResultNetwork[i]
                                                              .capabilities ==
                                                          "[ESS]"
                                                      ? "Open"
                                                      : "Password protected",
                                                  maxLines: null,
                                                  style: TextStyle(
                                                      color: _htResultNetwork[i]
                                                                  .capabilities ==
                                                              "[ESS]"
                                                          ? Colors.green
                                                          : Colors.red),
                                                ),
                                              ),
                                            ],
                                          ),
                                          // NameValuePair(
                                          //   value: _htResultNetwork[i]
                                          //               .capabilities ==
                                          //           "[ESS]"
                                          //       ? "Open"
                                          //       : "Password prot",
                                          //   title: "Password : ",
                                          // ),

                                          NameValuePair(
                                            value: DateFormat(
                                                    "MMMM dd, yyyy hh:mm")
                                                .format(DateTime.now()),
                                            title: "Created at : ",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              itemCount: _htResultNetwork.length,
                              // > 5 ? 6 : listHotspot.length,
                            ),
                            _isLoad
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, i) {
                                      // if (i == 0) {
                                      //   return GestureDetector(
                                      //     onTap: _isConnecting
                                      //         ? null
                                      //         : () async {
                                      //             print("object");
                                      //             Scaffold.of(context).hideCurrentSnackBar();
                                      //             setState(() {
                                      //               _isConnecting = true;
                                      //             });

                                      //             var status = await WiFiForIoTPlugin.connect(
                                      //                 'Calendar',
                                      //                 password: 'Denny@123',
                                      //                 joinOnce: true,
                                      //                 security: NetworkSecurity.WPA);
                                      //             setState(() {
                                      //               _isConnecting = false;
                                      //             });
                                      //             if (status) {
                                      //               Scaffold.of(context).showSnackBar(SnackBar(
                                      //                 content: Text(
                                      //                   "Conneted successfully",
                                      //                 ),
                                      //                 behavior: SnackBarBehavior.floating,
                                      //                 backgroundColor: Colors.green,
                                      //               ));
                                      //             } else {
                                      //               Scaffold.of(context).showSnackBar(SnackBar(
                                      //                 content: Text(
                                      //                   "Something went wrong!",
                                      //                 ),
                                      //                 backgroundColor: Colors.red,
                                      //                 behavior: SnackBarBehavior.floating,
                                      //               ));
                                      //             }
                                      //             print(status);
                                      //           },
                                      //     child: Container(
                                      //       // height: 100,
                                      //       margin: EdgeInsets.all(8),
                                      //       decoration: BoxDecoration(
                                      //           color: Color(0xFFffffff),
                                      //           boxShadow: [
                                      //             BoxShadow(
                                      //                 color: Colors.grey,
                                      //                 blurRadius: 5,
                                      //                 spreadRadius: 1,
                                      //                 offset: Offset(0, 1))
                                      //           ],
                                      //           borderRadius: BorderRadius.circular(8)),
                                      //       child: Padding(
                                      //         padding: const EdgeInsets.all(18.0),
                                      //         child: Column(
                                      //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      //           children: [
                                      //             NameValuePair(
                                      //               value: 'Calendar infotech',
                                      //               title: "Title : ",
                                      //             ),
                                      //             NameValuePair(
                                      //               value: 'Calendar',
                                      //               title: "Name : ",
                                      //             ),
                                      //             NameValuePair(
                                      //               value: "D Mart",
                                      //               title: "Address : ",
                                      //             ),
                                      //             NameValuePair(
                                      //               value: "Suart",
                                      //               title: "Category : ",
                                      //             ),
                                      //             NameValuePair(
                                      //               value: 'Denny@123',
                                      //               title: "Password : ",
                                      //             ),

                                      //             NameValuePair(
                                      //               value: newListHotspot[i]
                                      //                           ['HotspotTip(createdAt'] ==
                                      //                       null
                                      //                   ? "-"
                                      //                   : newListHotspot[i]
                                      //                           ['HotspotTip(createdAt']
                                      //                       .split(')))')
                                      //                       .first,
                                      //               title: "Created at : ",
                                      //             ),

                                      //             NameValuePair(
                                      //               value: '-',
                                      //               title: "Hotspot user : ",
                                      //             ),
                                      //             // NameValuePair(
                                      //             //   value: listHotspot[i]['Location(latitude'],
                                      //             //   title: "Latitude : ",
                                      //             // ),
                                      //             // NameValuePair(
                                      //             //   value: longitude,
                                      //             //   title: "Longitude : ",
                                      //             // ),
                                      //           ],
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   );
                                      // }
                                      String place =
                                          newListHotspot[i]['category'] == null
                                              ? "No category define"
                                              : newListHotspot[i]['category']
                                                  .split(')')
                                                  .first;
                                      String longitude =
                                          newListHotspot[i]['longitude'] == null
                                              ? "No longitude define"
                                              : newListHotspot[i]['longitude']
                                                  .split(')')
                                                  .first;
                                      return GestureDetector(
                                        onTap: _isConnecting
                                            ? null
                                            : () async {
                                                print("object");
                                                Scaffold.of(context)
                                                    .hideCurrentSnackBar();
                                                setState(() {
                                                  _isConnecting = true;
                                                });
                                                var ssid = newListHotspot[i]
                                                        ['HotspotPlace(title']
                                                    .toString()
                                                    .substring(
                                                        1,
                                                        (newListHotspot[i][
                                                                    'HotspotPlace(title']
                                                                .toString()
                                                                .length -
                                                            1));
                                                var password = newListHotspot[i]
                                                            [
                                                            'Secured(password'] ==
                                                        null
                                                    ? "-"
                                                    : newListHotspot[i]
                                                            ['Secured(password']
                                                        .split(')))')
                                                        .first
                                                        .toString()
                                                        .substring(
                                                            1,
                                                            (newListHotspot[i][
                                                                        'Secured(password']
                                                                    .split(
                                                                        ')))')
                                                                    .first
                                                                    .toString()
                                                                    .length -
                                                                1));
                                                print(ssid);
                                                print(password);
                                                var status =
                                                    await WiFiForIoTPlugin
                                                        .connect(ssid,
                                                            password: password,
                                                            joinOnce: true,
                                                            security:
                                                                NetworkSecurity
                                                                    .WPA);
                                                setState(() {
                                                  _isConnecting = false;
                                                });
                                                if (status) {
                                                  Scaffold.of(context)
                                                      .showSnackBar(SnackBar(
                                                    content: Text(
                                                      "Conneted successfully",
                                                    ),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    backgroundColor:
                                                        Colors.green,
                                                  ));
                                                } else {
                                                  Scaffold.of(context)
                                                      .showSnackBar(SnackBar(
                                                    content: Text(
                                                      "Something went wrong!",
                                                    ),
                                                    backgroundColor: Colors.red,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ));
                                                }
                                                print(status);
                                              },
                                        child: Container(
                                          // height: 100,
                                          margin: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              color: Color(0xFFffffff),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.grey,
                                                    blurRadius: 5,
                                                    spreadRadius: 1,
                                                    offset: Offset(0, 1))
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(18.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                NameValuePair(
                                                  value: newListHotspot[i]
                                                      ['HotspotPlace(title'],
                                                  title: "Title : ",
                                                ),
                                                NameValuePair(
                                                  value: newListHotspot[i]
                                                      ['ssid'],
                                                  title: "Name : ",
                                                ),
                                                NameValuePair(
                                                  value: newListHotspot[i]
                                                      ['street'],
                                                  title: "Address : ",
                                                ),
                                                NameValuePair(
                                                  value: place,
                                                  title: "Category : ",
                                                ),
                                                NameValuePair(
                                                  value: newListHotspot[i][
                                                              'Secured(password'] ==
                                                          null
                                                      ? "-"
                                                      : newListHotspot[i][
                                                              'Secured(password']
                                                          .split(')))')
                                                          .first,
                                                  title: "Password : ",
                                                ),

                                                NameValuePair(
                                                  value: newListHotspot[i][
                                                              'HotspotTip(createdAt'] ==
                                                          null
                                                      ? "-"
                                                      : newListHotspot[i][
                                                              'HotspotTip(createdAt']
                                                          .split(')))')
                                                          .first,
                                                  title: "Created at : ",
                                                ),

                                                NameValuePair(
                                                  value: newListHotspot[i][
                                                              'HotspotUser(name'] ==
                                                          null
                                                      ? "-"
                                                      : newListHotspot[i][
                                                              'HotspotUser(name']
                                                          .split(')))')
                                                          .first,
                                                  title: "Hotspot user : ",
                                                ),
                                                // NameValuePair(
                                                //   value: listHotspot[i]['Location(latitude'],
                                                //   title: "Latitude : ",
                                                // ),
                                                // NameValuePair(
                                                //   value: longitude,
                                                //   title: "Longitude : ",
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: newListHotspot.length,
                                    // > 5 ? 6 : listHotspot.length,
                                  ),
                          ],
                        ),
                      ),
                _isConnecting
                    ? Center(
                        child: Container(
                          height: 200,
                          width: 200,
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF08B15B)),
                                ),
                                Text(
                                  "Connecting...",
                                  style: TextStyle(fontSize: 25),
                                ),
                              ],
                            ),
                          ),
                          color: Colors.green[50],
                        ),
                      )
                    : Container(),
              ],
            ),
    );
  }
}

class NameValuePair extends StatelessWidget {
  const NameValuePair({
    Key key,
    @required this.title,
    @required this.value,
  }) : super(key: key);

  final String title, value;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: value == null
          ? Text("")
          : Row(
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Expanded(
                  child: Text(
                    value,
                    maxLines: null,
                  ),
                ),
              ],
            ),
    );
  }
}
