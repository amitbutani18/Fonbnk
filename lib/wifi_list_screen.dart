import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi_iot/wifi_iot.dart';

class WifiListScreen extends StatefulWidget {
  @override
  _WifiListScreenState createState() => _WifiListScreenState();
}

class _WifiListScreenState extends State<WifiListScreen> {
  List<WifiNetwork> _htResultNetwork = [];

  storeAndConnect(String psSSID, String psKey) async {
    // await storeAPInfos();
    await WiFiForIoTPlugin.setWiFiAPSSID(psSSID);
    await WiFiForIoTPlugin.setWiFiAPPreSharedKey(psKey);
  }

  Future<List<WifiNetwork>> loadWifiList() async {
    List<WifiNetwork> htResultNetwork;
    try {
      htResultNetwork = await WiFiForIoTPlugin.loadWifiList();
      for (var i = 0; i < htResultNetwork.length; i++) {
        if (htResultNetwork[i].ssid == "OnePlus 8T") {
          print("capabilities " + htResultNetwork[i].capabilities);
          print("bssid " + htResultNetwork[i].bssid);
          print("frequency " + htResultNetwork[i].frequency.toString());
          print("level" + htResultNetwork[i].level.toString());
          print("ssid " + htResultNetwork[i].ssid);
          print(htResultNetwork[i].password);
        }
      }
    } on PlatformException {
      htResultNetwork = List<WifiNetwork>();
    }

    return htResultNetwork;
  }

  @override
  void initState() {
    super.initState();
    loadWifiList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: RaisedButton(
                child: Text("Scan"),
                onPressed: () async {
                  _htResultNetwork = await loadWifiList();
                  setState(() {});
                },
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, i) => Container(
                child: GestureDetector(
                  onTap: () {
                    WiFiForIoTPlugin.connect(_htResultNetwork[i].ssid,
                        // password: "Denny@123",
                        joinOnce: true,
                        security: NetworkSecurity.NONE);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: Text(
                        '${_htResultNetwork[i].ssid}  ${_htResultNetwork[i].password}'),
                  ),
                ),
              ),
              itemCount: _htResultNetwork.length,
            )
          ],
        ),
      ),
    );
  }
}
