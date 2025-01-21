import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehiclemanagement/components/permissions/permission_page.dart';
import 'package:vehiclemanagement/components/roles/roles_page.dart';
import 'package:vehiclemanagement/components/users/users_page.dart';
import 'package:vehiclemanagement/components/usershifts/usershift_page.dart';
import 'package:vehiclemanagement/components/vehicles/vehicles_page.dart';
import 'package:vehiclemanagement/menurole.dart';
import '../../config.dart';
import '../login/login_page.dart';
import '../login/logout _method.dart';
import '../widgetmethods/appbar_method.dart';
import 'menu_page.dart';

class Menuswithsubmenu extends StatefulWidget {
  const Menuswithsubmenu({super.key});

  @override
  State<Menuswithsubmenu> createState() => _MenuswithsubmenuState();
}

class _MenuswithsubmenuState extends State<Menuswithsubmenu> {
  List<dynamic> menuData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMenuData();
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<int?> _getRoleId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('role_Id');
  }

  Future<void> fetchMenuData() async {
    final token = await _getToken();
    final roleId = await _getRoleId();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token not found')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (roleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Role ID not found')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse('${Config.apiUrl}Permission/GetRoleBasedMenus/$roleId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Map<String, dynamic> responseData = json.decode(response.body);

      if (data['apiResponse'] == null || (data['apiResponse'] is List && data['apiResponse'].isEmpty)) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(responseData['message'] ?? 'Role added successfully'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          menuData = data['apiResponse'];
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load menu data');
    }
  }

  Future<void> _savePermissionType(String permissionType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_permission_type', permissionType);
  }

  Widget buildMenu(List<dynamic> menus) {
    return ListView(
      children: menus.map((menu) => buildMenuItem(menu)).toList(),
    );
  }

  Widget buildMenuItem(Map<String, dynamic> menu) {
    TextStyle menuTextStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    Color menuBackgroundColor = Colors.blueAccent;

    String menuName = menu['menuName'] ?? 'Unknown Menu';

    if (menu['subMenus'] != null && menu['subMenus'].isNotEmpty) {
      return ExpansionTile(
        title: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: menuBackgroundColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            menuName,
            style: menuTextStyle,
          ),
        ),
        children: menu['subMenus'].map<Widget>((submenu) => buildMenuItem(submenu)).toList(),
      );
    } else {
      return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        title: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: menuBackgroundColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            menuName,
            style: menuTextStyle,
          ),
        ),
        onTap: () {
          if (menu['roles'] != null && menu['roles'].isNotEmpty) {
            String permissionType = menu['roles'][0]['permissionType'] ?? 'default_permission';
            _savePermissionType(permissionType);
          }

          if (menuName == 'Roles') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RolesPage(),
              ),
            );
          } else if(menuName == 'Vehicle'){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VehiclesPage(),
              ),
            );

          } else if(menuName == 'Users Shift'){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UsershiftPage(),
              ),
            );
          } else if(menuName == 'Users'){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UsersPage(),
              ),
            );
          } else if(menuName == 'Permission'){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PermissionPage(),
              ),
            );
          } else if(menuName == 'Menu Role Permission'){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MenuRolePage(),
              ),
            );
          } else if(menuName == 'Menus'){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MenuPage(),
              ),
            );
          }else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubmenuScreen(menuName: menuName),
              ),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Menus',
        onLogout: () => AuthService.logout(context),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : buildMenu(menuData),
    );
  }
}


class SubmenuScreen extends StatelessWidget {
  final String menuName;
  const SubmenuScreen({super.key, required this.menuName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(menuName),
      ),
      body: Center(
        child: Text('You have selected: $menuName'),
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vehiclemanagement/components/permissions/permission_page.dart';
// import 'package:vehiclemanagement/components/roles/roles_page.dart';
// import 'package:vehiclemanagement/components/users/users_page.dart';
// import 'package:vehiclemanagement/components/usershifts/usershift_page.dart';
// import 'package:vehiclemanagement/components/vehicles/vehicles_page.dart';
// import '../../config.dart';
// import '../login/login_page.dart';
// import '../login/logout _method.dart';
// import '../widgetmethods/appbar_method.dart';
//
// class Menuswithsubmenu extends StatefulWidget {
//   const Menuswithsubmenu({super.key});
//
//   @override
//   State<Menuswithsubmenu> createState() => _MenuswithsubmenuState();
// }
//
// class _MenuswithsubmenuState extends State<Menuswithsubmenu> {
//   List<dynamic> menuData = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchMenuData();
//   }
//
//   Future<String?> _getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }
//
//   Future<int?> _getRoleId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getInt('role_Id');
//   }
//
//   Future<void> fetchMenuData() async {
//     final token = await _getToken();
//     final roleId = await _getRoleId();
//
//     if (token == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Token not found')),
//       );
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }
//
//     if (roleId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Role ID not found')),
//       );
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }
//
//     final response = await http.get(
//       Uri.parse('${Config.apiUrl}Permission/GetAllMenuWithPermissions/$roleId'),
//       headers: {
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       Map<String, dynamic> responseData = json.decode(response.body);
//
//       if (data['apiResponse'] == null || (data['apiResponse'] is List && data['apiResponse'].isEmpty)) {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: const Text('Error'),
//               content: Text(responseData['message'] ?? 'Role added successfully'),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (context) => LoginPage()),
//                     );
//                   },
//                   child: const Text('OK'),
//                 ),
//               ],
//             );
//           },
//         );
//       } else {
//         setState(() {
//           menuData = data['apiResponse'];
//           isLoading = false;
//         });
//       }
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//       throw Exception('Failed to load menu data');
//     }
//   }
//
//   Future<void> _savePermissionType(String permissionType) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('selected_permission_type', permissionType);
//   }
//
//   Widget buildMenu(List<dynamic> menus) {
//     return ListView(
//       children: menus.map((menu) => buildMenuItem(menu)).toList(),
//     );
//   }
//
//   Widget buildMenuItem(Map<String, dynamic> menu) {
//     TextStyle menuTextStyle = TextStyle(
//       fontSize: 16,
//       fontWeight: FontWeight.w600,
//       color: Colors.white,
//     );
//
//     Color menuBackgroundColor = Colors.blueAccent;
//
//     String menuName = menu['menuName'] ?? 'Unknown Menu';
//
//     if (menu['subMenus'] != null && menu['subMenus'].isNotEmpty) {
//       return ExpansionTile(
//         title: Container(
//           padding: const EdgeInsets.all(8.0),
//           decoration: BoxDecoration(
//             color: menuBackgroundColor,
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//           child: Text(
//             menuName,
//             style: menuTextStyle,
//           ),
//         ),
//         children: menu['subMenus'].map<Widget>((submenu) => buildMenuItem(submenu)).toList(),
//       );
//     } else {
//       return ListTile(
//         contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//         title: Container(
//           padding: const EdgeInsets.all(8.0),
//           decoration: BoxDecoration(
//             color: menuBackgroundColor,
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//           child: Text(
//             menuName,
//             style: menuTextStyle,
//           ),
//         ),
//         onTap: () {
//           if (menu['roles'] != null && menu['roles'].isNotEmpty) {
//             String permissionType = menu['roles'][0]['permissionType'] ?? 'default_permission';
//             _savePermissionType(permissionType);
//           }
//
//           if (menuName == 'Roles') {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => RolesPage(),
//               ),
//             );
//           } else if(menuName == 'Vehicle'){
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => VehiclesPage(),
//               ),
//             );
//
//           } else if(menuName == 'UserShifts'){
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => UsershiftPage(),
//               ),
//             );
//           } else if(menuName == 'Users'){
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => UsersPage(),
//               ),
//             );
//           } else if(menuName == 'Permissions'){
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => PermissionPage(),
//               ),
//             );
//           } else {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => SubmenuScreen(menuName: menuName),
//               ),
//             );
//           }
//         },
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'Menus',
//         onLogout: () => AuthService.logout(context),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : buildMenu(menuData),
//     );
//   }
// }
//
//
// class SubmenuScreen extends StatelessWidget {
//   final String menuName;
//   const SubmenuScreen({super.key, required this.menuName});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(menuName),
//       ),
//       body: Center(
//         child: Text('You have selected: $menuName'),
//       ),
//     );
//   }
// }



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vehiclemanagement/components/permissions/permission_page.dart';
// import 'package:vehiclemanagement/components/roles/roles_page.dart';
// import 'package:vehiclemanagement/components/users/users_page.dart';
// import 'package:vehiclemanagement/components/usershifts/usershift_page.dart';
// import 'package:vehiclemanagement/components/vehicles/vehicles_page.dart';
// import '../../config.dart';
// import '../login/login_page.dart';
// import '../login/logout _method.dart';
// import '../widgetmethods/appbar_method.dart';
//
// class Menuswithsubmenu extends StatefulWidget {
//   const Menuswithsubmenu({super.key});
//
//   @override
//   State<Menuswithsubmenu> createState() => _MenuswithsubmenuState();
// }
//
// class _MenuswithsubmenuState extends State<Menuswithsubmenu> {
//   List<dynamic> menuData = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchMenuData();
//   }
//
//   Future<String?> _getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }
//
//   Future<int?> _getRoleId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getInt('role_Id');
//   }
//
//   Future<void> fetchMenuData() async {
//     final token = await _getToken();
//     final roleId = await _getRoleId();
//
//     if (token == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Token not found')),
//       );
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }
//
//     if (roleId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Role ID not found')),
//       );
//       setState(() {
//         isLoading = false;
//       });
//       return;
//     }
//
//     final response = await http.get(
//       Uri.parse('${Config.apiUrl}Permission/GetAllMenuWithPermissions/$roleId'),
//       headers: {
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       Map<String, dynamic> responseData = json.decode(response.body);
//
//       if (data['apiResponse'] == null || (data['apiResponse'] is List && data['apiResponse'].isEmpty)) {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: const Text('Error'),
//               content: Text(responseData['message'] ?? 'Role added successfully'),
//               actions: <Widget>[
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to login page
//                     );
//                   },
//                   child: const Text('OK'),
//                 ),
//               ],
//             );
//           },
//         );
//       } else {
//         setState(() {
//           menuData = data['apiResponse'];
//           isLoading = false;
//         });
//       }
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//       throw Exception('Failed to load menu data');
//     }
//   }
//
//
//   Future<void> _savePermissionType(String permissionType) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('selected_permission_type', permissionType);
//   }
//
//   Widget buildMenu(List<dynamic> menus) {
//     return ListView(
//       children: menus.map((menu) => buildMenuItem(menu)).toList(),
//     );
//   }
//
//   Widget buildMenuItem(Map<String, dynamic> menu) {
//     if (menu['subMenus'] != null && menu['subMenus'].isNotEmpty) {
//       return ExpansionTile(
//         title: Text(menu['menuName']),
//         children: menu['subMenus'].map<Widget>((submenu) => buildMenuItem(submenu)).toList(),
//       );
//     } else {
//       return ListTile(
//         title: Text(menu['menuName']),
//         onTap: () {
//           if (menu['roles'] != null && menu['roles'].isNotEmpty) {
//             String permissionType = menu['roles'][0]['permissionType'];
//             _savePermissionType(permissionType);
//           }
//
//           if (menu['menuName'] == 'Roles') {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => RolesPage(),
//               ),
//             );
//           } else if(menu['menuName'] == 'Vehicle'){
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => VehiclesPage(),
//               ),
//             );
//
//           }  else if(menu['menuName'] == 'UserShifts'){
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => UsershiftPage(),
//               ),
//             );
//
//           }else if(menu['menuName'] == 'Users'){
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => UsersPage(),
//               ),
//             );
//
//           }else if(menu['menuName'] == 'Permissions'){
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => PermissionPage(),
//               ),
//             );
//
//           }else{
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => SubmenuScreen(menuName: menu['menuName']),
//               ),
//             );
//           }
//         },
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'Menus',
//         onLogout: () => AuthService.logout(context),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : buildMenu(menuData),
//     );
//   }
// }
//
//
// class SubmenuScreen extends StatelessWidget {
//   final String menuName;
//
//   const SubmenuScreen({super.key, required this.menuName});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(menuName),
//       ),
//       body: Center(
//         child: Text('You have selected: $menuName'),
//       ),
//     );
//   }
// }
