
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../config.dart';
class NavBar extends StatefulWidget {
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  String userName = "User Name";
  String roleName = "Role Name";
  String profileImage = 'images/lklogo.jpg';
  File? _image;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? storedUserName = prefs.getString('user_Name');
      String? storedRoleName = prefs.getString('role_Name');

      if (storedUserName != null) {
        setState(() {
          userName = storedUserName;
        });
      }
      if (storedRoleName != null) {
        setState(() {
          roleName = storedRoleName;
        });
      }
      _loadProfileImage();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading profile data: $e")),
      );
    }
  }

  Future<void> _loadProfileImage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_Id');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User ID not found in shared preferences")),
        );
        return;
      }

      String? token = prefs.getString('token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Token not found in shared preferences")),
        );
        return;
      }

      var response = await http.get(
        Uri.parse('${Config.apiUrl}Users/ProfileImage/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var imageUrl = data['apiResponse']['imageUrl'];

        setState(() {
          profileImage = imageUrl;
        });
      } else {
        Fluttertoast.showToast(
          msg: "Failed to Fetch Profile Image",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Check your API",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _updateImage(File(pickedFile.path));
    }
  }
  Future<void> _updateImage(File image) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? token = prefs.getString('token');
      int? userId = prefs.getInt('user_Id');

      if (userId == null || token == null) {
        Fluttertoast.showToast(
          msg: "User ID or Token not found in shared preferences",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }

      String userIdString = userId.toString();

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${Config.apiUrl}Users/updateUser/$userIdString'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var data = jsonDecode(responseBody);

        if (data != null && data['apiResponse'] != null && data['apiResponse']['message'] != null) {
          var message = data['apiResponse']['message'];
          Fluttertoast.showToast(
            msg: message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          Fluttertoast.showToast(
            msg: "Image updated successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }

        setState(() {
          profileImage = image.path;
        });
      } else {
        var responseBody = await response.stream.bytesToString();
        var data = jsonDecode(responseBody);
        var message = data != null && data['apiResponse'] != null && data['apiResponse']['message'] != null
            ? data['apiResponse']['message']
            : "Failed to update image";

        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to Update Image! Check your API ",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
            accountEmail: Text(
              userName,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
            ),
            accountName: Padding(
              padding: const EdgeInsets.only(top: 30,left: 9),
              child: Text(roleName,style: TextStyle(fontSize: 20),),
            ),

            currentAccountPicture: GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : (profileImage.startsWith('http')
                    ? NetworkImage(profileImage)
                    : AssetImage(profileImage) as ImageProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
