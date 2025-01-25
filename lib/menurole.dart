// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'components/login/logout _method.dart';
// import 'components/widgetmethods/appbar_method.dart';
// import 'config.dart';
//
// class MenuRolePage extends StatefulWidget {
//   @override
//   _MenuRolePageState createState() => _MenuRolePageState();
// }
//
// class _MenuRolePageState extends State<MenuRolePage> {
//   late Future<List<Menu>> menus;
//   String? token;
//   List<dynamic> roles = [];
//   int? selectedRoleId;
//   int? selectedPermissionId;
//   int? selectedMenuId;
//
//   List<Map<String, dynamic>> selectedPermissions = [];
//
//   @override
//   void initState() {
//     super.initState();
//     menus = fetchMenus();
//     _fetchRoles();
//   }
//
//   Future<void> _fetchRoles() async {
//     try {
//       final response = await http.get(Uri.parse('${Config.apiUrl}role/getallrole'));
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           roles = data['apiResponse'] ?? [];
//         });
//       } else {
//         var responseBody = jsonDecode(response.body);
//         String errorMessage = responseBody['message'] ?? 'Failed to add permission';
//         print(errorMessage);
//       }
//     } catch (e) {
//       print("Exception: $e");
//     }
//   }
//
//   Future<List<Menu>> fetchMenus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     int? savedRoleId = prefs.getInt('selectedRoleId');
//
//     if (savedRoleId == null) {
//       print("Role ID is not set in SharedPreferences");
//       return [];
//     }
//
//     try {
//       final response = await http.get(Uri.parse('${Config.apiUrl}Permission/GetAllMenusWithRole/$savedRoleId'));
//
//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         List<Menu> menuList = [];
//         if (data['apiResponse'] != null) {
//           for (var menu in data['apiResponse']) {
//             menuList.add(Menu.fromJson(menu));
//           }
//         }
//         return menuList;
//       } else {
//         var responseBody = jsonDecode(response.body);
//         String errorMessage = responseBody['message'] ?? 'Failed to add permission';
//         throw Exception(errorMessage);
//       }
//     } catch (e) {
//       print("Error fetching menus: $e");
//       return [];
//     }
//   }
//
//   Future<void> _sendPermissions() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     token = prefs.getString('token');
//
//     if (selectedPermissions.isEmpty) {
//       print("Please select values before submitting.");
//       return;
//     }
//
//     final url = Uri.parse('${Config.apiUrl}MenuRolePermission/AddMenuRolePermission');
//     final body = jsonEncode(selectedPermissions);
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: body,
//       );
//       print('Request Body: $body');
//       if (response.statusCode == 200) {
//         var responseBody = jsonDecode(response.body);
//         String successMessage = responseBody['message'] ?? 'Permissions added successfully';
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(successMessage),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         var responseBody = jsonDecode(response.body);
//         String errorMessage = responseBody['message'] ?? 'Failed to add permissions';
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(errorMessage),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       print("Error: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $e'),
//           backgroundColor: Colors.orange,
//         ),
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
//       body: Column(
//         children: [
//           SizedBox(height: 20),
//           DropdownButtonFormField<int>(
//             value: selectedRoleId,
//             decoration: InputDecoration(
//               labelText: 'Select Role',
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               prefixIcon: Icon(Icons.group),
//             ),
//             items: roles.isNotEmpty
//                 ? roles.map<DropdownMenuItem<int>>((role) {
//               return DropdownMenuItem<int>(
//                 value: role['roleId'],
//                 child: Text(role['roleName']),
//               );
//             }).toList()
//                 : [],
//             onChanged: (value) async {
//               setState(() {
//                 selectedRoleId = value;
//               });
//               SharedPreferences prefs = await SharedPreferences.getInstance();
//               if (value != null) {
//                 await prefs.setInt('selectedRoleId', value);
//               }
//               menus = fetchMenus();
//             },
//             hint: Text('Select Role'),
//           ),
//           SizedBox(height: 40),
//           Expanded(
//             child: FutureBuilder<List<Menu>>(
//               future: menus,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return Center(child: Text('No menus available.'));
//                 } else {
//                   return ListView.builder(
//                     itemCount: snapshot.data!.length,
//                     itemBuilder: (context, index) {
//                       return buildMenu(snapshot.data![index]);
//                     },
//                   );
//                 }
//               },
//             ),
//           ),
//           IconButton(
//             onPressed: _sendPermissions,
//             icon: Icon(Icons.add,color: Colors.blueAccent, size: 40,),          ),
//         ],
//       ),
//     );
//   }
//
//   Widget buildMenu(Menu menu) {
//     if (menu.subMenus.isEmpty || menu.subMenus.every((subMenu) => subMenu.menuName.isEmpty)) {
//       return ListTile(
//         title: Row(
//           children: [
//             Expanded(child: Text(menu.menuName)),
//             SubmenuPermissionDropdown(
//               menu: menu,
//               onPermissionSelected: (permissionId) {
//                 setState(() {
//                   selectedPermissionId = permissionId;
//                 });
//               },
//               onMenuSelected: (menuId) {
//                 setState(() {
//                   selectedMenuId = menuId;
//                   if (selectedRoleId != null && selectedPermissionId != null) {
//                     selectedPermissions.add({
//                       'RoleId': selectedRoleId,
//                       'MenuID': selectedMenuId,
//                       'PermissionId': selectedPermissionId,
//                     });
//                   }
//                 });
//               },
//             ),
//           ],
//         ),
//       );
//     } else {
//       return ExpansionTile(
//         key: Key(menu.menuName),
//         title: Text(menu.menuName),
//         children: [
//           ...menu.subMenus.map<Widget>((subMenu) {
//             return buildSubMenuWithPermission(subMenu);
//           }).toList(),
//         ],
//       );
//     }
//   }
//   Widget buildSubMenuWithPermission(Menu subMenu) {
//     if (subMenu.subMenus.isEmpty || subMenu.subMenus.every((subSubMenu) => subSubMenu.menuName.isEmpty)) {
//       return ListTile(
//         title: Row(
//           children: [
//             Expanded(child: Text(subMenu.menuName)),
//             SubmenuPermissionDropdown(
//               menu: subMenu,
//               onPermissionSelected: (permissionId) {
//                 setState(() {
//                   selectedPermissionId = permissionId;
//                 });
//               },
//               onMenuSelected: (menuId) {
//                 setState(() {
//                   selectedMenuId = menuId;
//                   if (selectedRoleId != null && selectedPermissionId != null) {
//                     selectedPermissions.add({
//                       'RoleId': selectedRoleId,
//                       'MenuID': selectedMenuId,
//                       'PermissionId': selectedPermissionId,
//                     });
//                   }
//                 });
//               },
//             ),
//           ],
//         ),
//       );
//     } else {
//       return ExpansionTile(
//         key: Key(subMenu.menuName),
//         title: Text(subMenu.menuName),
//         children: [
//           ...subMenu.subMenus.map<Widget>((subSubMenu) {
//             return buildSubMenuWithPermission(subSubMenu);
//           }).toList(),
//         ],
//       );
//     }
//   }
// }
//
// class Menu {
//   final String menuName;
//   final int menuID;
//   final List<Role> roles;
//   final List<Menu> subMenus;
//
//   Menu({
//     required this.menuName,
//     required this.menuID,
//     required this.roles,
//     required this.subMenus,
//   });
//
//   factory Menu.fromJson(Map<String, dynamic> json) {
//     var subMenusList = json['subMenus'] as List? ?? [];
//     List<Menu> subMenus = subMenusList.map((item) => Menu.fromJson(item)).toList();
//
//     var rolesList = json['roles'] as List? ?? [];
//     List<Role> roles = rolesList.map((item) => Role.fromJson(item)).toList();
//
//     return Menu(
//       menuName: json['menuName'] ?? '',
//       menuID: json['menuID'] != null
//           ? (json['menuID'] is int ? json['menuID'] : int.tryParse(json['menuID'].toString()) ?? 0)
//           : 0,
//       roles: roles,
//       subMenus: subMenus,
//     );
//   }
// }
//
// class Role {
//   final int roleId;
//   final String roleName;
//   final String permissionType;
//
//   Role({required this.roleId, required this.roleName, required this.permissionType});
//
//   factory Role.fromJson(Map<String, dynamic> json) {
//     return Role(
//       roleId: json['roleId'] is int ? json['roleId'] : 0,
//       roleName: json['roleName'] ?? '',
//       permissionType: json['permissionType'] ?? '',
//     );
//   }
// }
//
// class Permission {
//   final String permissionType;
//   final int permissionId;
//
//   Permission({required this.permissionType, required this.permissionId});
// }
//
// class SubmenuPermissionDropdown extends StatefulWidget {
//   final Menu menu;
//   final Function(int) onPermissionSelected;
//   final Function(int) onMenuSelected;
//
//   const SubmenuPermissionDropdown({
//     Key? key,
//     required this.menu,
//     required this.onPermissionSelected,
//     required this.onMenuSelected,
//   }) : super(key: key);
//
//   @override
//   _SubmenuPermissionDropdownState createState() =>
//       _SubmenuPermissionDropdownState();
// }
//
// class _SubmenuPermissionDropdownState extends State<SubmenuPermissionDropdown> {
//   String? selectedPermission;
//   List<Permission> permissionTypes = [];
//   int retryCount = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchPermissionTypes();
//   }
//
//   Future<void> fetchPermissionTypes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');
//
//     if (token == null) {
//       print("No token found");
//       return;
//     }
//
//     try {
//       final response = await http.get(
//         Uri.parse('${Config.apiUrl}Permission/GetAllPermission'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         if (data['isSuccess']) {
//           List<Permission> fetchedPermissions = [];
//           for (var permission in data['apiResponse']) {
//             fetchedPermissions.add(Permission(
//               permissionType: permission['PermissionType'],
//               permissionId: permission['PermissionId'],
//             ));
//           }
//           setState(() {
//             permissionTypes = fetchedPermissions;
//             if (widget.menu.roles.isNotEmpty &&
//                 widget.menu.roles[0].permissionType.isNotEmpty) {
//               selectedPermission = widget.menu.roles[0].permissionType;
//             } else {
//               selectedPermission = null;
//             }
//           });
//           return;
//         } else {
//           print("API response 'isSuccess' is false");
//         }
//       } else {
//         print("Failed to load permissions with status code: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error fetching permission types: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return DropdownButton<Permission>(
//       value: selectedPermission == null
//           ? null
//           : permissionTypes.firstWhere(
//             (permission) => permission.permissionType == selectedPermission,
//         orElse: () => permissionTypes.isNotEmpty
//             ? permissionTypes[0]
//             : Permission(permissionType: 'Select ', permissionId: 0),
//       ),
//       hint: Text('Select'),
//       onChanged: (Permission? newValue) {
//         setState(() {
//           if (newValue == null) {
//             selectedPermission = null;
//             widget.onPermissionSelected(0);
//             widget.onMenuSelected(widget.menu.menuID);
//           } else {
//             selectedPermission = newValue.permissionType;
//             widget.onPermissionSelected(newValue.permissionId);
//             widget.onMenuSelected(widget.menu.menuID);
//           }
//         });
//       },
//       items: [
//         DropdownMenuItem<Permission>(
//           value: null,
//           child: Text('Select'),
//         ),
//         ...permissionTypes.map<DropdownMenuItem<Permission>>((Permission permission) {
//           return DropdownMenuItem<Permission>(
//             value: permission,
//             child: Text(permission.permissionType),
//           );
//         }).toList(),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'components/login/logout _method.dart';
import 'components/widgetmethods/appbar_method.dart';
import 'components/widgetmethods/bottomnavigation_method.dart';
import 'config.dart';

class MenuRolePage extends StatefulWidget {
  @override
  _MenuRolePageState createState() => _MenuRolePageState();
}

class _MenuRolePageState extends State<MenuRolePage> {
  late Future<List<Menu>> menus;
  String? token;
  int _currentIndex = 0;

  List<dynamic> roles = [];
  int? selectedRoleId;
  int? selectedPermissionId;
  int? selectedMenuId;

  List<Map<String, dynamic>> selectedPermissions = [];

  @override
  void initState() {
    super.initState();
    menus = fetchMenus();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    try {
      final response = await http.get(Uri.parse('${Config.apiUrl}role/getallrole'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          roles = data['apiResponse'] ?? [];
        });
      } else {
        var responseBody = jsonDecode(response.body);
        String errorMessage = responseBody['message'] ?? 'Failed to add permission';
        print(errorMessage);
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  Future<List<Menu>> fetchMenus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? savedRoleId = prefs.getInt('selectedRoleId');

    if (savedRoleId == null) {
      print("Role ID is not set in SharedPreferences");
      return [];
    }

    try {
      final response = await http.get(Uri.parse('${Config.apiUrl}Permission/GetAllMenusWithRole/$savedRoleId'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<Menu> menuList = [];
        if (data['apiResponse'] != null) {
          for (var menu in data['apiResponse']) {
            menuList.add(Menu.fromJson(menu));
          }
        }
        return menuList;

      } else {
        var responseBody = jsonDecode(response.body);
        String errorMessage = responseBody['message'] ?? 'Failed to add permission';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("Error fetching menus: $e");
      return [];
    }
  }

  Future<void> _sendPermissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (selectedPermissions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text( 'Select values from dropdown before adding')    ,
          backgroundColor: Colors.orange,
        ),
      );      return;
    }

    final url = Uri.parse('${Config.apiUrl}MenuRolePermission/AddMenuRolePermission');
    final body = jsonEncode(selectedPermissions);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );
      print('Request Body: $body');
      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        String successMessage = responseBody['message'] ?? 'Permissions added successfully';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        var responseBody = jsonDecode(response.body);
        String errorMessage = responseBody['message'] ?? 'Failed to add permissions';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
  Future<void> resetPermissions() async {
    List<Menu>? menuList = await menus;
    setState(() {
      selectedPermissionId = null;
      selectedPermissions.clear();
      if (menuList != null) {
        for (var menu in menuList) {
          menu.roles.clear();
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Menus',
        onLogout: () => AuthService.logout(context),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          DropdownButtonFormField<int>(
            value: selectedRoleId,
            decoration: InputDecoration(
              labelText: 'Select Role',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixIcon: Icon(Icons.group),
            ),
            items: roles.isNotEmpty
                ? roles.map<DropdownMenuItem<int>>((role) {
              return DropdownMenuItem<int>(
                value: role['roleId'],
                child: Text(role['roleName']),
              );
            }).toList()
                : [],
            onChanged: (value) async {
              setState(() {
                selectedRoleId = value;
              });
              SharedPreferences prefs = await SharedPreferences.getInstance();
              if (value != null) {
                await prefs.setInt('selectedRoleId', value);
              }
              menus = fetchMenus();
            },
            hint: Text('Select Role'),
          ),
          SizedBox(height: 40),
          Expanded(
            child: FutureBuilder<List<Menu>>(
              future: menus,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No menus available.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return buildMenu(snapshot.data![index]);
                    },
                  );
                }
              },
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Reset Permissions'),
                        content: Text('Are you sure you want to reset all permissions?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await menus.then((menuList) {
                                setState(() {
                                  selectedPermissionId = null;
                                  selectedPermissions.clear();
                                  for (var menu in menuList) {
                                    menu.roles.clear();
                                  }
                                });
                              });
                            },
                            child: Text('Reset'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.refresh,size: 40, color: Colors.orange,),
              ),
              SizedBox(width: 245,),

              IconButton(
                onPressed: _sendPermissions,
                icon: Icon(Icons.add,color: Colors.blueAccent, size: 40,),  ),
            ],
          ),
        ],
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
  Widget buildMenu(Menu menu) {
    if (menu.subMenus.isEmpty || menu.subMenus.every((subMenu) => subMenu.menuName.isEmpty)) {
      return ListTile(
        title: Row(
          children: [
            Expanded(child: Text(menu.menuName)),
            SubmenuPermissionDropdown(
              menu: menu,
              onPermissionSelected: (permissionId) {
                setState(() {
                  selectedPermissionId = permissionId;
                });
              },
              onMenuSelected: (menuId) {
                setState(() {
                  selectedMenuId = menuId;
                  if (selectedRoleId != null && selectedPermissionId != null) {
                    selectedPermissions.add({
                      'RoleId': selectedRoleId,
                      'MenuID': selectedMenuId,
                      'PermissionId': selectedPermissionId,
                    });
                  }
                });
              },
            ),
          ],
        ),
      );
    } else {
      return ExpansionTile(
        key: Key(menu.menuName),
        title: Text(menu.menuName),
        children: [
          ...menu.subMenus.map<Widget>((subMenu) {
            return buildSubMenuWithPermission(subMenu);
          }).toList(),
        ],
      );
    }
  }

  Widget buildSubMenuWithPermission(Menu subMenu) {
    if (subMenu.subMenus.isEmpty || subMenu.subMenus.every((subSubMenu) => subSubMenu.menuName.isEmpty)) {
      return ListTile(
        title: Row(
          children: [
            Expanded(child: Text(subMenu.menuName)),
            SubmenuPermissionDropdown(
              menu: subMenu,
              onPermissionSelected: (permissionId) {
                setState(() {
                  selectedPermissionId = permissionId;
                });
              },
              onMenuSelected: (menuId) {
                setState(() {
                  selectedMenuId = menuId;
                  if (selectedRoleId != null && selectedPermissionId != null) {
                    selectedPermissions.add({
                      'RoleId': selectedRoleId,
                      'MenuID': selectedMenuId,
                      'PermissionId': selectedPermissionId,
                    });
                  }
                });
              },
            ),
          ],
        ),
      );
    } else {
      return ExpansionTile(
        key: Key(subMenu.menuName),
        title: Text(subMenu.menuName),
        children: [
          ...subMenu.subMenus.map<Widget>((subSubMenu) {
            return buildSubMenuWithPermission(subSubMenu);
          }).toList(),
        ],
      );
    }
  }
}

class Menu {
  final String menuName;
  final int menuID;
  final List<Role> roles;
  final List<Menu> subMenus;

  Menu({
    required this.menuName,
    required this.menuID,
    required this.roles,
    required this.subMenus,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    var subMenusList = json['subMenus'] as List? ?? [];
    List<Menu> subMenus = subMenusList.map((item) => Menu.fromJson(item)).toList();

    var rolesList = json['roles'] as List? ?? [];
    List<Role> roles = rolesList.map((item) => Role.fromJson(item)).toList();

    return Menu(
      menuName: json['menuName'] ?? '',
      menuID: json['menuID'] != null
          ? (json['menuID'] is int ? json['menuID'] : int.tryParse(json['menuID'].toString()) ?? 0)
          : 0,
      roles: roles,
      subMenus: subMenus,
    );
  }
}

class Role {
  final int roleId;
  final String roleName;
  final String permissionType;

  Role({required this.roleId, required this.roleName, required this.permissionType});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      roleId: json['roleId'] is int ? json['roleId'] : 0,
      roleName: json['roleName'] ?? '',
      permissionType: json['permissionType'] ?? '',
    );
  }
}

class Permission {
  final String permissionType;
  final int permissionId;

  Permission({required this.permissionType, required this.permissionId});
}

class SubmenuPermissionDropdown extends StatefulWidget {
  final Menu menu;
  final Function(int) onPermissionSelected;
  final Function(int) onMenuSelected;

  const SubmenuPermissionDropdown({
    Key? key,
    required this.menu,
    required this.onPermissionSelected,
    required this.onMenuSelected,
  }) : super(key: key);

  @override
  _SubmenuPermissionDropdownState createState() =>
      _SubmenuPermissionDropdownState();
}

class _SubmenuPermissionDropdownState extends State<SubmenuPermissionDropdown> {
  String? selectedPermission;
  List<Permission> permissionTypes = [];
  int retryCount = 0;

  @override
  void initState() {
    super.initState();
    fetchPermissionTypes();
  }

  Future<void> fetchPermissionTypes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print("No token found");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${Config.apiUrl}Permission/GetAllPermission'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['isSuccess']) {
          List<Permission> fetchedPermissions = [];
          for (var permission in data['apiResponse']) {
            fetchedPermissions.add(Permission(
              permissionType: permission['PermissionType'],
              permissionId: permission['PermissionId'],
            ));
          }
          setState(() {
            permissionTypes = fetchedPermissions;
            if (widget.menu.roles.isNotEmpty &&
                widget.menu.roles[0].permissionType.isNotEmpty) {
              selectedPermission = widget.menu.roles[0].permissionType;
            } else {
              selectedPermission = null;
            }
          });
          return;
        } else {
          print("API response 'isSuccess' is false");
        }
      } else {
        print("Failed to load permissions with status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching permission types: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          DropdownButton<Permission>(
            value: selectedPermission == null
                ? null
                : permissionTypes.firstWhere(
                  (permission) => permission.permissionType == selectedPermission,
              orElse: () => permissionTypes.isNotEmpty
                  ? permissionTypes[0]
                  : Permission(permissionType: 'Select ', permissionId: 0),
            ),
            hint: Text('Select'),
            onChanged: (Permission? newValue) {
              setState(() {
                if (newValue == null) {
                  selectedPermission = null;
                  widget.onPermissionSelected(0);
                  widget.onMenuSelected(widget.menu.menuID);
                } else {
                  selectedPermission = newValue.permissionType;
                  widget.onPermissionSelected(newValue.permissionId);
                  widget.onMenuSelected(widget.menu.menuID);
                }
              });
            },
            items: [
              DropdownMenuItem<Permission>(
                value: null,
                child: Text('Select'),
              ),
              ...permissionTypes.map<DropdownMenuItem<Permission>>((Permission permission) {
                return DropdownMenuItem<Permission>(
                  value: permission,
                  child: Text(permission.permissionType),
                );
              }).toList(),
            ],
          ),
        ],
       );
    }
}