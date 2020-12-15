import 'dart:math' show cos, sqrt, asin;
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform =
      const MethodChannel('samples.flutter.dev/wifimap.sample');
  List<Map<String, dynamic>> listHotspot = [];
  List<double> distanceList = [];

  bool _isInit = true, _isLoad = false;

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  getNearMeHotspot(double lat, double lng) {
    for (var i = 1; i < listHotspot.length; i++) {
      // print(listHotspot[i]['longitude']);
      // print(i);
      double dist = calculateDistance(
          lat,
          lng,
          double.parse(listHotspot[i]['Location(latitude']),
          double.parse(listHotspot[i]['longitude'].split(')').first));
      // Geodesy geodesy = Geodesy();
      // LatLng l1 = LatLng(lat, lng);
      // LatLng l2 = LatLng(double.parse(listHotspot[i]['Location(latitude']),
      //     double.parse(listHotspot[i]['longitude'].split(')').first));
      // print(geodesy.distanceBetweenTwoGeoPoints(l1, l2));
      distanceList.add(dist);
      // print(listHotspot[i]['Secured(password'] == null
      //     ? "hello"
      //     : listHotspot[i]['Secured(password'].split(')))').first +
      //         listHotspot[i]['HotspotPlace(title'] +
      //         " " +
      //         dist.toString());
    }
    print(distanceList);
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
              } else {
                map.putIfAbsent(
                    listSplitVal[0].trim(), () => listSplitVal[1].toString());
              }
            }
          }).toList();
          listHotspot.add(map);
        }).toList();
        // print(listHotspot[1]['HotspotPlace(title']);
        getNearMeHotspot(position.latitude, position.longitude);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF08B15B),
        title: Text("Fonbnk"),
      ),
      body: _isLoad
          ? Center(
              child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF08B15B)),
            ))
          : ListView.builder(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Container();
                }
                String place = listHotspot[i]['category'] == null
                    ? "No category define"
                    : listHotspot[i]['category'].split(')').first;
                String longitude = listHotspot[i]['longitude'] == null
                    ? "No longitude define"
                    : listHotspot[i]['longitude'].split(')').first;
                return Container(
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        NameValuePair(
                          value: listHotspot[i]['HotspotPlace(title'],
                          title: "Title : ",
                        ),
                        NameValuePair(
                          value: listHotspot[i]['ssid'],
                          title: "Name : ",
                        ),
                        NameValuePair(
                          value: listHotspot[i]['street'],
                          title: "Address : ",
                        ),
                        NameValuePair(
                          value: place,
                          title: "Category : ",
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
                );
              },
              itemCount: listHotspot.length > 5 ? 6 : listHotspot.length,
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
