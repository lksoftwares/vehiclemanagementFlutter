import 'package:permission_handler/permission_handler.dart';

class MicrophonePermissionService {
  Future<PermissionStatus> checkMicrophonePermission() async {
    return await Permission.microphone.status;
  }
  Future<bool> requestMicrophonePermission() async {
    PermissionStatus status = await Permission.microphone.request();
    return status.isGranted;
  }
  Future<void> openAppSettings() async {
    if (await Permission.microphone.isPermanentlyDenied) {
      await openAppSettings();
    }
  }
}
