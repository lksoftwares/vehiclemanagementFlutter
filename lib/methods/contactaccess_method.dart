import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactAccess {
  static Future<bool> requestContactPermission() async {
    PermissionStatus permissionStatus = await Permission.contacts.request();

    if (permissionStatus == PermissionStatus.granted) {
      return true;
    } else if (permissionStatus == PermissionStatus.denied) {
      return false;
    } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
      openAppSettings();
      return false;
    }
    return false;
  }

  static Future<List<Contact>> getContacts() async {
    bool hasPermission = await requestContactPermission();
    if (hasPermission) {
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: true,
      );
      return contacts;
    }
    return [];
  }

  static Future<void> openDialer(String phoneNumber) async {
    String formattedPhoneNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');

    final Uri dialUri = Uri(scheme: 'tel', path: formattedPhoneNumber);

    if (await launchUrl(dialUri)) {
      await launchUrl(dialUri);
    } else {
      throw 'Could not launch dialer';
    }
  }
}
