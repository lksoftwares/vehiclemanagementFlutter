import 'dart:io';
import 'package:flutter/material.dart';
import 'cameraaccess_method.dart';

class CameraScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Image'),
        ),
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  File? imageFile = await ImagePickerUtil.pickImageFromCamera();

                  if (imageFile != null) {
                    print("Image picked from camera: ${imageFile.path}");
                  }
                  },
                child: Text('Pick Image from camera'),
              ),
              ElevatedButton(
                onPressed: () async {
                  File? imageFile = await ImagePickerUtil.pickImageFromGallery();

                  if (imageFile != null) {
                    print("Image picked from gallery: ${imageFile.path}");
                  }
                  },
                child: Text('Pick Image from gallery'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

