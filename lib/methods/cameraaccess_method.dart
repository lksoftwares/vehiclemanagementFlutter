import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ImagePickerUtil {
  static Future<File?> pickImageFromCamera() async {
    var status = await Permission.camera.request();

    if (status.isGranted) {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      return image != null ? File(image.path) : null;
    } else {
      print("Camera permission is required to take a photo.");
      return null;
    }
  }
  static Future<File?> pickImageFromGallery() async {
    var status = await Permission.photos.request();

    if (status.isGranted) {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      return image != null ? File(image.path) : null;
    } else {
      print("Gallery permission is required to pick an image.");
      return null;
    }
  }
}
