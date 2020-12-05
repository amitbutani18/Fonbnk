import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _counter = "data";
  static const platform =
      const MethodChannel('samples.flutter.dev/wifimap.sample');
  List<Map<String, dynamic>> listHotspot = [];

  bool _isInit = true, _isLoad = false;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_isInit) {
      try {
        setState(() {
          _isLoad = true;
        });
        final result = await platform.invokeMethod('fetch', {
          "lat": 53.9000,
          "lng": 27.5667,
        });
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
        print(listHotspot[1]['HotspotPlace(title']);
        _counter = newStr[1].toString();
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
                        NameValuePair(
                          value: listHotspot[i]['Location(latitude'],
                          title: "Latitude : ",
                        ),
                        NameValuePair(
                          value: longitude,
                          title: "Longitude : ",
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: listHotspot.length,
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
