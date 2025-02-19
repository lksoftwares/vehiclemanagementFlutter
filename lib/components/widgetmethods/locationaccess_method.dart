import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    PermissionStatus permissionStatus = await Permission.location.request();

    if (permissionStatus.isGranted) {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } else if (permissionStatus.isDenied) {
      return Future.error('Location permission denied. Please allow permission.');
    } else if (permissionStatus.isPermanentlyDenied) {
      openAppSettings();
      return Future.error('Location permission permanently denied.');
    }

    return null;
  }
}