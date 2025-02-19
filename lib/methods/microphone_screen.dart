import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'microphone_method.dart';

class MyMicrophonePage extends StatelessWidget {
  final MicrophonePermissionService _permissionService = MicrophonePermissionService();

  Future<void> _checkAndRequestPermission() async {
    PermissionStatus status = await _permissionService.checkMicrophonePermission();
    if (status.isGranted) {
      print("Microphone permission granted");
    } else {
      bool isGranted = await _permissionService.requestMicrophonePermission();
      if (isGranted) {
        print("Microphone permission granted after request");
      } else {
        print("Microphone permission denied");
        await _permissionService.openAppSettings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Microphone")),
      body: Center(
        child: ElevatedButton(
          onPressed: _checkAndRequestPermission,
          child: Text("Request Microphone Permission"),
        ),
      ),
    );
  }
}
