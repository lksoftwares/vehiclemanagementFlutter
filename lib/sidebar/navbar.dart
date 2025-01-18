import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehiclemanagement/components/permissions/permission_page.dart';
import 'package:vehiclemanagement/components/roles/roles_page.dart';
import 'package:vehiclemanagement/components/users/users_page.dart';
import 'package:vehiclemanagement/components/usershifts/usershift_page.dart';
import 'package:vehiclemanagement/components/vehicles/vehicles_page.dart';
import '../config.dart';
import '../components/home/home_page.dart';
import '../components/menus/menu_page.dart';

class NavBar extends StatefulWidget {
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  File? _image;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();
  int? user_Id;
  int? role_Id;
  String? token;
  String? roleName;
  List<dynamic> menus = [];

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  _fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    user_Id = prefs.getInt('user_Id');
    role_Id = prefs.getInt('role_Id');

    token = prefs.getString('token');
    roleName = prefs.getString('role_Name');

    if (token != null && user_Id != null) {
      await _fetchMenus();
    }

    setState(() {});
  }
  _fetchMenus() async {
    if (token == null || user_Id == null) return;

    final response = await http.get(
      Uri.parse('http://192.168.1.57:7248/Permission/GetAllMenuWithPermissions/${role_Id}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print(' Response: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['isSuccess']) {
        setState(() {
          menus = data['apiResponse'];
        });
      } else {
        Fluttertoast.showToast(msg: 'Failed to fetch menus');
      }
    } else {
      Fluttertoast.showToast(msg: 'Failed to fetch menus');
    }
  }

  Future<void> _selectImage() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Choose image source"),
        actions: <Widget>[
          TextButton(
            child: Text("Camera"),
            onPressed: () {
              Navigator.pop(context, ImageSource.camera);
            },
          ),
          TextButton(
            child: Text("Gallery"),
            onPressed: () {
              Navigator.pop(context, ImageSource.gallery);
            },
          ),
        ],
      ),
    );
    if (source == null) return;

    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      await _uploadImage(pickedFile);
    }
  }

  _uploadImage(XFile pickedFile) async {
    if (user_Id == null || token == null) return;

    final uri = Uri.parse('${Config.apiUrl}Users/updateUser/$user_Id');
    final request = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = 'Bearer $token';
    final file = await http.MultipartFile.fromPath('Image', pickedFile.path);
    request.files.add(file);
    final response = await request.send();

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: 'Image updated successfully');
      _fetchProfileImage();
    } else {
      Fluttertoast.showToast(msg: 'Failed to update image');
    }
  }

  _fetchProfileImage() async {
    if (user_Id == null || token == null) return;

    final response = await http.get(
      Uri.parse('${Config.apiUrl}Users/ProfileImage/$user_Id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _imageUrl = data['imageUrl'];
      });
      _saveImageUrlToPreferences(_imageUrl);
    } else {
      Fluttertoast.showToast(msg: 'Failed to fetch image');
    }
  }

  _saveImageUrlToPreferences(String? imageUrl) async {
    final prefs = await SharedPreferences.getInstance();
    if (imageUrl != null) {
      await prefs.setString('profile_image_url', imageUrl);
    }
  }

  Widget _buildMenuList(List<dynamic> menuItems) {
    return Column(
      children: menuItems.map<Widget>((menu) {
        return _buildMenuItem(menu);
      }).toList(),
    );
  }

  Widget _buildMenuItem(dynamic menu) {
    return ExpansionTile(
      leading: Icon(Icons.home),
      title: Text(menu['menuName']),
      children: menu['subMenus'] != null && menu['subMenus'].isNotEmpty
          ? menu['subMenus'].map<Widget>((submenu) {
        return _buildSubMenuItem(submenu);
      }).toList()
          : [],
    );
  }

  Widget _buildSubMenuItem(dynamic submenu) {
    return ExpansionTile(
      leading: Icon(Icons.arrow_forward,size: 20,),
      title: Text(submenu['menuName']),
      children: submenu['subMenus'] != null && submenu['subMenus'].isNotEmpty
          ? submenu['subMenus'].map<Widget>((subsubmenu) {
        return _buildSubSubMenuItem(subsubmenu);
      }).toList()
          : [],
    );
  }

  Widget _buildSubSubMenuItem(dynamic subsubmenu) {
    return ListTile(
      title: Text(subsubmenu['menuName']),
      onTap: () {
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountEmail: Padding(
              padding: const EdgeInsets.only(bottom: 30, left: 7),
              child: Text(
                roleName ?? 'Loading...',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
              ),
            ),
            accountName: Text(''),
            currentAccountPicture: GestureDetector(
              onTap: _selectImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : (_imageUrl != null
                    ? NetworkImage(_imageUrl!)
                    : AssetImage('images/lklogo.jpg') as ImageProvider),
                backgroundColor: Colors.grey[200],
              ),
            ),
          ),
          _buildMenuList(menus),
        ],
      ),
    );
  }
}

//           if (roleName == 'Admin') ...[
//             _buildMenuList(menus),
//           ] else ...[
//             ListTile(
//               leading: Icon(Icons.home),
//               title: Text('Home'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => DashboardScreen()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.person_add_outlined),
//               title: Text('Roles'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => RolesPage()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.people),
//               title: Text('Users'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => UsersPage()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.car_rental),
//               title: Text('Vehicles'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => VehiclesPage()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.watch_later),
//               title: Text('UserShifts'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => UsershiftPage()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.input),
//               title: Text('Menus'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => MenuPage()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.perm_identity),
//               title: Text('Permissions'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => PermissionPage()),
//                 );
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.supervised_user_circle_rounded),
//               title: Text('Menu Role Permissions'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => MenurolepermissionsPage()),
//                 );
//               },
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
