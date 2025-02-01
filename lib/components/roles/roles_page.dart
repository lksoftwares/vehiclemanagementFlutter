//
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:vehiclemanagement/components/widgetmethods/appbar_method.dart';
// import '../../config.dart';
// import '../login/logout _method.dart';
// import '../widgetmethods/alert_widget.dart';
// import '../widgetmethods/bottomnavigation_method.dart';
//
// import '../widgetmethods/toast_method.dart';
// class RolesPage extends StatefulWidget {
//   const RolesPage({super.key});
//
//   @override
//   State<RolesPage> createState() => _RolesPageState();
// }
//
// class _RolesPageState extends State<RolesPage> {
//   List<Map<String, dynamic>> roles = [];
//   List<Map<String, dynamic>> filteredRoles = [];
//   String? token;
//   String? permissionType;
//   bool canRead = false;
//   bool canCreate = false;
//   bool canUpdate = false;
//   bool canDelete = false;
//   int _currentIndex = 0;
//   TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _getToken().then((_) {
//       _getPermissionType().then((_) {
//         if (canRead) {
//           fetchRoles();
//         }
//       });
//     });
//
//     _searchController.addListener(() {
//       filterRoles(_searchController.text);
//     });
//   }
//
//   void filterRoles(String query) {
//     final filtered = roles.where((role) {
//       final roleName = role['roleName'].toLowerCase();
//       return roleName.contains(query.toLowerCase());
//     }).toList();
//
//     setState(() {
//       filteredRoles = filtered;
//     });
//   }
//
//   Future<void> _getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       token = prefs.getString('token');
//     });
//   }
//
//   Future<void> _getPermissionType() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       permissionType = prefs.getString('selected_permission_type');
//
//       if (permissionType == null) {
//         showCustomAlertDialog(context, title: 'Permission Error',
//             content: Text('Permission Type is not found .'),
//             actions: []);
//         return;
//       }
//
//       canCreate = permissionType!.toString().contains('C');
//       canRead = permissionType!.toString().contains('R');
//       canUpdate = permissionType!.toString().contains('U');
//       canDelete = permissionType!.toString().contains('D');
//     });
//   }
//
//   Future<void> fetchRoles() async {
//     if (token == null || !canRead) return;
//
//     try {
//       final response = await http.get(
//         Uri.parse('${Config.apiUrl}Role/GetAllRole'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data['statusCode'] == 200 && data['apiResponse'] != null) {
//           setState(() {
//             roles = List<Map<String, dynamic>>.from(
//               data['apiResponse'].map((role) =>
//               {
//                 'roleId': role['roleId'] ?? 0,
//                 'roleName': role['roleName'] ?? 'Unknown Role',
//               }),
//             );
//             filteredRoles = roles;
//           });
//         } else {
//           showToast(msg: data['message'] ?? 'Failed to load roles');
//         }
//       } else {
//         showToast(msg: 'Failed to fetch roles. Server error.');
//       }
//     } catch (e) {
//       showToast(msg: 'Error fetching roles: $e');
//     }
//   }
//
//   void _confirmDeleteRole(int roleId) {
//     if (!canDelete) {
//       showCustomAlertDialog(
//         context,
//         title: 'Permission Denied',
//         content: Text('You do not have permission to delete roles.'),
//         actions: [],
//       );
//       return;
//     }
//
//     showCustomAlertDialog(
//       context,
//       title: 'Delete Role',
//       content: Text('Are you sure you want to delete this role?'),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             _deleteRole(roleId);
//             Navigator.pop(context);
//           },
//           child: Text('Delete'),
//         ),
//       ],
//     );
//   }
//
//   Future<void> _deleteRole(int roleId) async {
//     if (token == null || roleId == 0) {
//       showToast(msg: 'Invalid Role ID');
//       return;
//     }
//
//     final response = await http.delete(
//       Uri.parse('${Config.apiUrl}Role/deleteRole/$roleId'),
//       headers: {
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       fetchRoles();
//       Map<String, dynamic> responseData = json.decode(response.body);
//       showToast(
//         msg: responseData['message'] ?? 'Role deleted successfully',
//         backgroundColor: Colors.green,
//       );
//     } else {
//       Map<String, dynamic> responseData = json.decode(response.body);
//       showToast(
//         msg: responseData['message'] ?? 'Failed',
//       );
//     }
//   }
//
//   void _showAddRoleModal() {
//     if (!canCreate) {
//       showCustomAlertDialog(
//         context,
//         title: 'Permission Denied',
//         content: Text('You do not have permission to add roles.'), actions: [],
//       );
//       return;
//     }
//
//     String roleName = '';
//     const int permissionId = 2;
//
//     InputDecoration inputDecoration = InputDecoration(
//       labelText: 'Role Name',
//       border: OutlineInputBorder(),
//     );
//
//     showCustomAlertDialog(
//       context,
//       title: 'Add Role',
//       content: TextField(
//         onChanged: (value) => roleName = value,
//         decoration: inputDecoration,
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             if (roleName.isEmpty) {
//               showToast(msg: 'Please fill in the role name');
//             } else {
//               _addRole(roleName, permissionId);
//             }
//           },
//           child: Text('Add'),
//         ),
//       ],
//     );
//   }
//
//   Future<void> _addRole(String roleName, int permissionId) async {
//     if (token == null || !canCreate) return;
//
//     final response = await http.post(
//       Uri.parse('${Config.apiUrl}Role/addrole'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: jsonEncode({
//         'roleName': roleName,
//         'permissionId': permissionId,
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       Map<String, dynamic> responseData = json.decode(response.body);
//
//       if (responseData['dup'] == true) {
//         showToast(
//           msg: responseData['message'] ?? 'Role added successfully',
//           backgroundColor: Colors.green,
//         );
//       } else {
//         fetchRoles();
//         showToast(
//           msg: responseData['message'] ?? 'Role added successfully',
//           backgroundColor: Colors.green,
//         );
//         Navigator.pop(context);
//       }
//     } else {
//       Map<String, dynamic> responseData = json.decode(response.body);
//       showToast(
//         msg: responseData['message'] ?? 'Failed to add role',
//       );
//     }
//   }
//
//   void _showEditRoleModal(int roleId, String currentRoleName) {
//     if (!canUpdate) {
//       showCustomAlertDialog(
//         context,
//         title: 'Permission Denied',
//         content: Text('You do not have permission to edit roles.'), actions: [],
//       );
//       return;
//     }
//
//     String updatedRoleName = currentRoleName;
//
//     InputDecoration inputDecoration = InputDecoration(
//       labelText: 'Role Name',
//       border: OutlineInputBorder(),
//     );
//
//     showCustomAlertDialog(
//       context,
//       title: 'Edit Role',
//
//       content: TextField(
//         controller: TextEditingController(text: currentRoleName),
//         onChanged: (value) => updatedRoleName = value,
//         decoration: inputDecoration,
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             _updateRole(roleId, updatedRoleName);
//             Navigator.pop(context);
//           },
//           child: Text('Update'),
//         ),
//       ],
//     );
//   }
//
//   Future<void> _updateRole(int roleId, String roleName) async {
//     if (token == null || roleId == 0 || roleName.isEmpty || !canUpdate) {
//       showToast(msg: 'Invalid input or permission denied');
//       return;
//     }
//
//     final response = await http.put(
//       Uri.parse('${Config.apiUrl}Role/updateRole/$roleId'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: jsonEncode({
//         'roleName': roleName,
//       }),
//     );
//     if (response.statusCode == 200) {
//       Map<String, dynamic> responseData = json.decode(response.body);
//
//       if (responseData['dup'] == true) {
//         showToast(
//           msg: responseData['message'] ?? 'Role updated successfully',
//           backgroundColor: Colors.green,
//         );
//       } else {
//         fetchRoles();
//         showToast(
//           msg: responseData['message'] ?? 'Role updated successfully',
//           backgroundColor: Colors.green,
//         );
//       }
//     } else {
//       Map<String, dynamic> responseData = json.decode(response.body);
//       showToast(
//         msg: responseData['message'] ?? 'Failed to update role',
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'Roles',
//         onLogout: () => AuthService.logout(context),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     width: 280,
//                     child: TextField(
//                       controller: _searchController,
//                       decoration: InputDecoration(
//                         labelText: 'Search by RoleName',
//                         prefixIcon: Icon(Icons.search),
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.add, color: Colors.blue, size: 30),
//                     onPressed: _showAddRoleModal,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               filteredRoles.isEmpty
//                   ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(height: 200),
//                     Text(
//                       'No results found 😞',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.red,
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       'Try searching with a different term.',
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey,
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//                   : Column(
//                 children: [
//                   // Fixed Header
//                   Container(
//                     color: Colors.blueAccent,
//                     child: Row(
//                       children: const [
//                         Expanded(
//                           child: Padding(
//                             padding: EdgeInsets.all(8.0),
//                             child: Text('Role Name', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
//                           ),
//                         ),
//                         Expanded(
//                           child: Padding(
//                             padding: EdgeInsets.all(8.0),
//                             child: Text('Edit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
//                           ),
//                         ),
//                         Expanded(
//                           child: Padding(
//                             padding: EdgeInsets.all(8.0),
//                             child: Text('Delete', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Scrollable content
//                   Container(
//                     height: 470,
//                     child: SingleChildScrollView(
//                       child: Column(
//                         children: filteredRoles
//                             .map((role) => Container(
//                           color: Colors.white,
//                           child: Row(
//                             children: [
//                               Expanded(
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Text(role['roleName']),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: IconButton(
//                                   icon: const Icon(Icons.edit, color: Colors.green),
//                                   onPressed: () => _showEditRoleModal(role['roleId'], role['roleName']),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: IconButton(
//                                   icon: const Icon(Icons.delete, color: Colors.red),
//                                   onPressed: () => _confirmDeleteRole(role['roleId']),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ))
//                             .toList(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
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
//   }}


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:vehiclemanagement/components/widgetmethods/appbar_method.dart';
import '../../config.dart';
import '../login/logout _method.dart';
import '../widgetmethods/alert_widget.dart';
import '../widgetmethods/bottomnavigation_method.dart';

import '../widgetmethods/no_data_found.dart';
import '../widgetmethods/toast_method.dart';
class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  List<Map<String, dynamic>> roles = [];
  List<Map<String, dynamic>> filteredRoles = [];
  String? token;
  String? permissionType;
  bool canRead = false;
  bool canCreate = false;
  bool canUpdate = false;
  bool canDelete = false;
  int _currentIndex = 0;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getToken().then((_) {
      _getPermissionType().then((_) {
        if (canRead) {
          fetchRoles();
        }
      });
    });

    _searchController.addListener(() {
      filterRoles(_searchController.text);
    });
  }

  void filterRoles(String query) {
    final filtered = roles.where((role) {
      final roleName = role['roleName'].toLowerCase();
      return roleName.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredRoles = filtered;
    });
  }

  Future<void> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
  }

  Future<void> _getPermissionType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      permissionType = prefs.getString('selected_permission_type');

      if (permissionType == null) {
        showCustomAlertDialog(context, title: 'Permission Error',
            content: Text('Permission Type is not found .'),
            actions: []);
        return;
      }

      canCreate = permissionType!.toString().contains('C');
      canRead = permissionType!.toString().contains('R');
      canUpdate = permissionType!.toString().contains('U');
      canDelete = permissionType!.toString().contains('D');
    });
  }

  Future<void> fetchRoles() async {
    if (token == null || !canRead) return;

    try {
      final response = await http.get(
        Uri.parse('${Config.apiUrl}Role/GetAllRole'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['statusCode'] == 200 && data['apiResponse'] != null) {
          setState(() {
            roles = List<Map<String, dynamic>>.from(
              data['apiResponse'].map((role) =>
              {
                'roleId': role['roleId'] ?? 0,
                'roleName': role['roleName'] ?? 'Unknown Role',
              }),
            );
            filteredRoles = roles;
          });
        } else {
          showToast(msg: data['message'] ?? 'Failed to load roles');
        }
      } else {
        showToast(msg: 'Failed to fetch roles. Server error.');
      }
    } catch (e) {
      showToast(msg: 'Error fetching roles: $e');
    }
  }

  void _confirmDeleteRole(int roleId) {
    if (!canDelete) {
      showCustomAlertDialog(
        context,
        title: 'Permission Denied',
        content: Text('You do not have permission to delete roles.'),
        actions: [],
      );
      return;
    }

    showCustomAlertDialog(
      context,
      title: 'Delete Role',
      content: Text('Are you sure you want to delete this role?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            _deleteRole(roleId);
            Navigator.pop(context);
          },
          child: Text('Delete'),
        ),
      ],
    );
  }

  Future<void> _deleteRole(int roleId) async {
    if (token == null || roleId == 0) {
      showToast(msg: 'Invalid Role ID');
      return;
    }

    final response = await http.delete(
      Uri.parse('${Config.apiUrl}Role/deleteRole/$roleId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      fetchRoles();
      Map<String, dynamic> responseData = json.decode(response.body);
      showToast(
        msg: responseData['message'] ?? 'Role deleted successfully',
        backgroundColor: Colors.green,
      );
    } else {
      Map<String, dynamic> responseData = json.decode(response.body);
      showToast(
        msg: responseData['message'] ?? 'Failed',
      );
    }
  }

  void _showAddRoleModal() {
    if (!canCreate) {
      showCustomAlertDialog(
        context,
        title: 'Permission Denied',
        content: Text('You do not have permission to add roles.'), actions: [],
      );
      return;
    }

    String roleName = '';
    const int permissionId = 2;

    InputDecoration inputDecoration = InputDecoration(
      labelText: 'Role Name',
      border: OutlineInputBorder(),
    );

    showCustomAlertDialog(
      context,
      title: 'Add Role',
      content: TextField(
        onChanged: (value) => roleName = value,
        decoration: inputDecoration,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (roleName.isEmpty) {
              showToast(msg: 'Please fill in the role name');
            } else {
              _addRole(roleName, permissionId);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  Future<void> _addRole(String roleName, int permissionId) async {
    if (token == null || !canCreate) return;

    final response = await http.post(
      Uri.parse('${Config.apiUrl}Role/addrole'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'roleName': roleName,
        'permissionId': permissionId,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['dup'] == true) {
        showToast(
          msg: responseData['message'] ?? 'Role added successfully',
          backgroundColor: Colors.green,
        );
      } else {
        fetchRoles();
        showToast(
          msg: responseData['message'] ?? 'Role added successfully',
          backgroundColor: Colors.green,
        );
        Navigator.pop(context);
      }
    } else {
      Map<String, dynamic> responseData = json.decode(response.body);
      showToast(
        msg: responseData['message'] ?? 'Failed to add role',
      );
    }
  }

  void _showEditRoleModal(int roleId, String currentRoleName) {
    if (!canUpdate) {
      showCustomAlertDialog(
        context,
        title: 'Permission Denied',
        content: Text('You do not have permission to edit roles.'), actions: [],
      );
      return;
    }

    String updatedRoleName = currentRoleName;

    InputDecoration inputDecoration = InputDecoration(
      labelText: 'Role Name',
      border: OutlineInputBorder(),
    );

    showCustomAlertDialog(
      context,
      title: 'Edit Role',

      content: TextField(
        controller: TextEditingController(text: currentRoleName),
        onChanged: (value) => updatedRoleName = value,
        decoration: inputDecoration,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            _updateRole(roleId, updatedRoleName);
            Navigator.pop(context);
          },
          child: Text('Update'),
        ),
      ],
    );
  }

  Future<void> _updateRole(int roleId, String roleName) async {
    if (token == null || roleId == 0 || roleName.isEmpty || !canUpdate) {
      showToast(msg: 'Invalid input or permission denied');
      return;
    }

    final response = await http.put(
      Uri.parse('${Config.apiUrl}Role/updateRole/$roleId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'roleName': roleName,
      }),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['dup'] == true) {
        showToast(
          msg: responseData['message'] ?? 'Role updated successfully',
          backgroundColor: Colors.green,
        );
      } else {
        fetchRoles();
        showToast(
          msg: responseData['message'] ?? 'Role updated successfully',
          backgroundColor: Colors.green,
        );
      }
    } else {
      Map<String, dynamic> responseData = json.decode(response.body);
      showToast(
        msg: responseData['message'] ?? 'Failed to update role',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
        title: 'Roles',
        onLogout: () => AuthService.logout(context),
      ),
            body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 280,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search by RoleName',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.blue, size: 30),
                    onPressed: _showAddRoleModal,
                  ),
                ],
              ),
              SizedBox(height: 20),
              filteredRoles.isEmpty
                  ? NoDataFoundScreen()
                  : Container(
                height: 570,
                    child: SfDataGrid(
                      frozenColumnsCount: 1,
                      source: RoleDataSource(
                        roles: filteredRoles,
                        onEditRole: _showEditRoleModal,
                        onDeleteRole:_confirmDeleteRole,

                      ),
                                    columns: [
                    GridColumn(
                      columnName: 'roleName',
                      label: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(8.0),
                        child: Text('Role Name'),
                      ),
                    ),
                    GridColumn(
                      columnName: 'edit',
                      label: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(8.0),
                        child: Text('Edit'),
                      ),
                    ),
                    GridColumn(
                      columnName: 'delete',
                      label: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(8.0),
                        child: Text('Delete'),
                      ),
                    ),
                    GridColumn(
                      columnName: 'edit',
                      label: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(8.0),
                        child: Text('Edit'),
                      ),
                    ),
                    GridColumn(
                      columnName: 'delete',
                      label: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(8.0),
                        child: Text('Delete'),
                      ),
                    ),
                                    ],
                                  ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleDataSource extends DataGridSource {
  final List<Map<String, dynamic>> roles;
  final Function(int roleId, String roleName) onEditRole;
  final Function(int roleId) onDeleteRole;

  RoleDataSource({required this.roles, required this.onEditRole,     required this.onDeleteRole,});

  @override
  List<DataGridRow> get rows => roles
      .map<DataGridRow>((role) => DataGridRow(cells: [
    DataGridCell<String>(columnName: 'roleName', value: role['roleName']),
    DataGridCell<int>(columnName: 'roleId', value: role['roleId']),
  ]))
      .toList();

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(cells: [
      // Display role name
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(row.getCells()[0].value as String),
      ),
      // Edit button
      Container(
        alignment: Alignment.center,
        child: IconButton(
          icon: Icon(Icons.edit, color: Colors.green),
          onPressed: () {
            final roleId = row.getCells()[1].value as int;
            final roleName = row.getCells()[0].value as String;
            // Call the callback function to show edit modal
            onEditRole(roleId, roleName);
          },
        ),
      ),
      Container(
        alignment: Alignment.center,
        child: IconButton(
          icon: Icon(Icons.edit, color: Colors.green),
          onPressed: () {
            final roleId = row.getCells()[1].value as int;
            final roleName = row.getCells()[0].value as String;
            // Call the callback function to show edit modal
            onEditRole(roleId, roleName);
          },
        ),
      ), Container(
        alignment: Alignment.center,
        child: IconButton(
          icon: Icon(Icons.edit, color: Colors.green),
          onPressed: () {
            final roleId = row.getCells()[1].value as int;
            final roleName = row.getCells()[0].value as String;
            onEditRole(roleId, roleName);
          },
        ),
      ),      Container(
        alignment: Alignment.center,
        child: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            final roleId = row.getCells()[1].value as int;
            onDeleteRole(roleId);
          },
        ),
      ),
    ]);
  }
}