import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityScreen extends StatefulWidget {
  @override
  _ConnectivityScreenState createState() => _ConnectivityScreenState();
}

class _ConnectivityScreenState extends State<ConnectivityScreen> {
  String connectionStatus = 'Checking...';

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    startListening();
  }

  Future<void> checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile) {
      setState(() {
        connectionStatus = 'Connected to mobile network';
      });
    } else if (connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        connectionStatus = 'Connected to Wi-Fi';
      });
    } else {
      setState(() {
        connectionStatus = 'No internet connection';
      });
    }
  }
  void startListening() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (result.isNotEmpty) {
        if (result.first == ConnectivityResult.mobile) {
          setState(() {
            connectionStatus = 'Connected to mobile network';
          });
        } else if (result.first == ConnectivityResult.wifi) {
          setState(() {
            connectionStatus = 'Connected to Wi-Fi';
          });
        } else {
          setState(() {
            connectionStatus = 'No internet connection';
          });
        }
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connectivity')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(connectionStatus),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}