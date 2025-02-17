//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vehiclemanagement/components/permissions/permission_page.dart';
// import 'package:vehiclemanagement/components/roles/roles_page.dart';
// import 'package:vehiclemanagement/components/users/users_page.dart';
// import 'package:vehiclemanagement/components/usershifts/usershift_page.dart';
// import 'package:vehiclemanagement/components/vehicles/vehicles_page.dart';
// import 'package:vehiclemanagement/sidebar/navbar.dart';
// import '../../config.dart';
// import '../login/login_page.dart';
// import '../login/logout _method.dart';
// import '../widgetmethods/appbar_method.dart';
// import '../widgetmethods/bottomnavigation_method.dart';
// import 'menu_page.dart';
// import 'menurolepermission.dart';
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
//   int _currentIndex = 0;
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
//
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
//       Uri.parse('${Config.apiUrl}Permission/GetRoleBasedMenus/$roleId'),
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
//               content: Text(responseData['message'] ?? 'Error'),
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
//     String? menuIcon = menu['icon'];
//
//     if (menu['subMenus'] != null && menu['subMenus'].isNotEmpty) {
//       return ExpansionTile(
//         title: Container(
//           padding: const EdgeInsets.all(5.0),
//           decoration: BoxDecoration(
//             color: menuBackgroundColor,
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//           child: Row(
//             children: [
//               menuIcon != null && menuIcon.isNotEmpty
//                   ? CircleAvatar(
//                 radius: 20,
//                 backgroundImage: NetworkImage(menuIcon),
//               )
//                   : CircleAvatar(radius: 20, backgroundColor: Colors.grey),
//               const SizedBox(width: 12),
//               Text(
//                 menuName,
//                 style: menuTextStyle,
//               ),
//             ],
//           ),
//         ),
//         children: menu['subMenus']
//             .map<Widget>((submenu) => buildMenuItem(submenu))
//             .toList(),
//       );
//     } else {
//       return ListTile(
//         contentPadding: EdgeInsets.only(left: 16.0, right: 8.0),
//         title: Container(
//           padding: const EdgeInsets.all(5.0),
//           decoration: BoxDecoration(
//             color: menuBackgroundColor,
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//           child: Row(
//             children: [
//               menuIcon != null && menuIcon.isNotEmpty
//                   ? CircleAvatar(
//                 radius: 20,
//                 backgroundImage: NetworkImage(menuIcon),
//               )
//                   : CircleAvatar(radius: 20, backgroundColor: Colors.grey),
//               const SizedBox(width: 12),
//               Text(
//                 menuName,
//                 style: menuTextStyle,
//               ),
//             ],
//           ),
//         ),
//         onTap: () {
//           if (menu['roles'] != null && menu['roles'].isNotEmpty) {
//             String permissionType = menu['roles'][0]['permissionType'] ?? 'default_permission';
//             _savePermissionType(permissionType);
//           }
//           if (menuName == 'Roles') {
//             Navigator.push(context, MaterialPageRoute(builder: (context) => RolesPage()));
//           } else if (menuName == 'Vehicle') {
//             Navigator.push(context, MaterialPageRoute(builder: (context) => VehiclesPage()));
//           } else if (menuName == 'Users Shift') {
//             Navigator.push(context, MaterialPageRoute(builder: (context) => UsershiftPage()));
//           } else if (menuName == 'Users') {
//             Navigator.push(context, MaterialPageRoute(builder: (context) => UsersPage()));
//           } else if (menuName == 'Permission') {
//             Navigator.push(context, MaterialPageRoute(builder: (context) => PermissionPage()));
//           } else if (menuName == 'Menu Role Permission') {
//             Navigator.push(context, MaterialPageRoute(builder: (context) => MenuRolePage()));
//           } else if (menuName == 'Menus') {
//             Navigator.push(context, MaterialPageRoute(builder: (context) => MenuPage()));
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
//       // appBar: AppBar(
//       //   title: const Text('Menus'),
//       //   actions: [
//       //     IconButton(
//       //       icon: const Icon(Icons.refresh),
//       //       onPressed: () {
//       //         setState(() {
//       //           isLoading = true;
//       //         });
//       //         fetchMenuData();
//       //       },
//       //     ),
//       //   ],
//       //   ],
//       // ),
//       appBar: CustomAppBar(
//         title: 'Menus',
//         onLogout: () => AuthService.logout(context),
//       ),
//       drawer: NavBar(),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//         onRefresh: fetchMenuData,
//         child: buildMenu(menuData),
//       ),
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: _currentIndex,
//         context: context,
//         onItemTapped: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//       ),
//     );
//   }
// }
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
// import 'package:vehiclemanagement/sidebar/navbar.dart';
// import '../../config.dart';
// import '../login/login_page.dart';
// import '../login/logout _method.dart';
// import '../widgetmethods/appbar_method.dart';
// import '../widgetmethods/bottomnavigation_method.dart';
// import 'menu_page.dart';
// import 'menurolepermission.dart';
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
//   int _currentIndex = 0;
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
//
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
//       Uri.parse('${Config.apiUrl}Permission/GetRoleBasedMenus/$roleId'),
//       headers: {
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//
//       if (data['apiResponse'] == null || (data['apiResponse'] is List && data['apiResponse'].isEmpty)) {
//         showDialog(
//           context: context,
//           builder: (BuildContext context) {
//             return AlertDialog(
//               title: const Text('Error'),
//               content: Text(data['message'] ?? 'Error'),
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
//     String menuName = menu['menuName'] is String ? menu['menuName'] : 'Unknown Menu';
//     String pageName = menu['pageName'] is String ? menu['pageName'] : ''; // Safely access pageName
//     String? menuIcon = menu['icon'];
//
//     if (menu['subMenus'] != null && menu['subMenus'].isNotEmpty) {
//       return ExpansionTile(
//         title: Container(
//           padding: const EdgeInsets.all(5.0),
//           decoration: BoxDecoration(
//             color: menuBackgroundColor,
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//           child: Row(
//             children: [
//               menuIcon != null && menuIcon.isNotEmpty
//                   ? CircleAvatar(
//                 radius: 20,
//                 backgroundImage: NetworkImage(menuIcon),
//               )
//                   : CircleAvatar(radius: 20, backgroundColor: Colors.grey),
//               const SizedBox(width: 12),
//               Text(
//                 menuName,
//                 style: menuTextStyle,
//               ),
//             ],
//           ),
//         ),
//         children: menu['subMenus'] is List
//             ? (menu['subMenus'] as List)
//             .map<Widget>((submenu) => buildMenuItem(submenu))
//             .toList()
//             : [],
//       );
//     } else {
//       return ListTile(
//         contentPadding: EdgeInsets.only(left: 16.0, right: 8.0),
//         title: Container(
//           padding: const EdgeInsets.all(5.0),
//           decoration: BoxDecoration(
//             color: menuBackgroundColor,
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//           child: Row(
//             children: [
//               menuIcon != null && menuIcon.isNotEmpty
//                   ? CircleAvatar(
//                 radius: 20,
//                 backgroundImage: NetworkImage(menuIcon),
//               )
//                   : CircleAvatar(radius: 20, backgroundColor: Colors.grey),
//               const SizedBox(width: 12),
//               Text(
//                 menuName,
//                 style: menuTextStyle,
//               ),
//             ],
//           ),
//         ),
//         onTap: () {
//           // Save the permission type (if exists)
//           if (menu['roles'] != null && menu['roles'].isNotEmpty) {
//             String permissionType = menu['roles'][0]['permissionType'] ?? 'default_permission';
//             _savePermissionType(permissionType);
//           }
//
//           // Navigate to the page based on the `pageName` field in the API response
//           if (pageName.isNotEmpty) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => _getPageForName(pageName),
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
//   Widget _getPageForName(String pageName) {
//     switch (pageName) {
//       case 'RolesPage':
//         return RolesPage();
//       case 'Users':
//         return UsersPage();
//       case 'Permission':
//         return PermissionPage();
//       case 'MenuRolePermission':
//         return MenuRolePage();
//       case 'UsershiftPage':
//         return UsershiftPage();
//       case 'VehiclesPage':
//         return VehiclesPage();
//       case 'MenuPage':
//         return MenuPage();
//       default:
//         return SubmenuScreen(menuName: pageName); // Fallback if pageName is unknown
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
//       drawer: NavBar(),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//         onRefresh: fetchMenuData,
//         child: buildMenu(menuData),
//       ),
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: _currentIndex,
//         context: context,
//         onItemTapped: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//       ),
//     );
//   }
// }
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
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehiclemanagement/components/permissions/permission_page.dart';
import 'package:vehiclemanagement/components/roles/roles_page.dart';
import 'package:vehiclemanagement/components/users/users_page.dart';
import 'package:vehiclemanagement/components/usershifts/usershift_page.dart';
import 'package:vehiclemanagement/components/vehicles/vehicles_page.dart';
import 'package:vehiclemanagement/sidebar/navbar.dart';
import '../../config.dart';
import '../login/login_page.dart';
import '../login/logout _method.dart';
import '../permissions/permission_bloc.dart';
import '../widgetmethods/appbar_method.dart';
import '../widgetmethods/bottomnavigation_method.dart';
import 'menu_page.dart';
import 'menurolepermission.dart';

class Menuswithsubmenu extends StatefulWidget {
  const Menuswithsubmenu({super.key});

  @override
  State<Menuswithsubmenu> createState() => _MenuswithsubmenuState();
}

class _MenuswithsubmenuState extends State<Menuswithsubmenu> {
  List<dynamic> menuData = [];
  bool isLoading = true;
  int _currentIndex = 0;
  Map<String, Widget Function(BuildContext)> pageMap = {
    'RolesPage': (context) => RolesPage(),
    'UsersPage': (context) => UsersPage(),
    'PermissionPage': (context) => BlocProvider<PermissionBloc>(
      create: (_) => PermissionBloc(),
      child: PermissionPage(),
    ),
    'MenuRolePage': (context) => MenuRolePage(),
    'UsershiftPage': (context) => UsershiftPage(),
    'VehiclesPage': (context) => VehiclesPage(),
    'MenuPage': (context) => MenuPage(),
  };
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

      if (data['apiResponse'] == null || (data['apiResponse'] is List && data['apiResponse'].isEmpty)) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(data['message'] ?? 'Error'),
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

    String menuName = menu['menuName'] is String ? menu['menuName'] : 'Unknown Menu';
    String pageName = menu['pageName'] is String ? menu['pageName'] : '';
    String? menuIcon = menu['icon'];

    if (menu['subMenus'] != null && menu['subMenus'].isNotEmpty) {
      return ExpansionTile(
        title: Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: menuBackgroundColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              menuIcon != null && menuIcon.isNotEmpty
                  ? CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(menuIcon),
              )
                  : CircleAvatar(radius: 20, backgroundColor: Colors.grey),
              const SizedBox(width: 12),
              Text(
                menuName,
                style: menuTextStyle,
              ),
            ],
          ),
        ),
        children: menu['subMenus'] is List
            ? (menu['subMenus'] as List)
            .map<Widget>((submenu) => buildMenuItem(submenu))
            .toList()
            : [],
      );
    } else {
      return ListTile(
        contentPadding: EdgeInsets.only(left: 16.0, right: 8.0),
        title: Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: menuBackgroundColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              menuIcon != null && menuIcon.isNotEmpty
                  ? CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(menuIcon),
              )
                  : CircleAvatar(radius: 20, backgroundColor: Colors.grey),
              const SizedBox(width: 12),
              Text(
                menuName,
                style: menuTextStyle,
              ),
            ],
          ),
        ),
        onTap: () {
          if (menu['roles'] != null && menu['roles'].isNotEmpty) {
            String permissionType = menu['roles'][0]['permissionType'] ?? 'default_permission';
            _savePermissionType(permissionType);
          }

          if (pageName.isNotEmpty && pageMap.containsKey(pageName)) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => pageMap[pageName]!(context),
              ),
            );
          }
          else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Page Not Found'),
                  content: Text('No page found for $menuName.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
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
      drawer: NavBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchMenuData,
        child: buildMenu(menuData),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        context: context,
        onItemTapped: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
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
