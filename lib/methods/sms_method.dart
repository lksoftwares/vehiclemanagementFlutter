import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';


class SmsMethod extends StatefulWidget {
  @override
  _SmsMethodState createState() => _SmsMethodState();
}

class _SmsMethodState extends State<SmsMethod> {
  static const platform = MethodChannel('com.example.sms');

  @override
  void initState() {
    super.initState();
  }

  Future<void> requestSmsPermission() async {
    final status = await Permission.sms.request();
    if (status.isGranted) {
      getSms();
    } else {
      print('SMS Permission Denied');
    }
  }

  Future<void> getSms() async {
    try {
      final sms = await platform.invokeMethod('getSms');
      print('Fetched SMS: $sms');
    } on PlatformException catch (e) {
      print("Failed to fetch SMS: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SMS Reader')),
      body: Center(
        child: ElevatedButton(
          onPressed: requestSmsPermission,
          child: Text('Request SMS Permission'),
        ),
      ),
    );
  }
}
