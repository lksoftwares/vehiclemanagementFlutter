import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:vehiclemanagement/components/widgetmethods/appbar_method.dart';
import '../../config.dart';
import '../widgetmethods/alert_widget.dart';
import '../login/logout _method.dart';
import '../widgetmethods/bottomnavigation_method.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  List<Map<String, dynamic>> roles = [];
  String? token;
  String? permissionType;
  bool canRead = false;
  bool canCreate = false;
  bool canUpdate = false;
  bool canDelete = false;
  int _currentIndex = 0;

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
  }

  Future<void> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
  }

  Future<void> _getPermissionType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(permissionType);
    setState(() {
      permissionType = prefs.getString('selected_permission_type');

      if (permissionType == null) {
        showCustomAlertDialog(context, title: 'Permission Error', content: Text('Permission Type is not found .'), actions: []);
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
              data['apiResponse'].map((role) => {
                'roleId': role['roleId'] ?? 0,
                'roleName': role['roleName'] ?? 'Unknown Role',
              }),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Failed to load roles'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to fetch roles. Server error.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching roles: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDeleteRole(int roleId) {
    if (!canDelete) {
      showCustomAlertDialog(
        context,
        title: 'Permission Denied',
        content: Text('You do not have permission to delete roles.'), actions: [],
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid Role ID')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'] ?? 'Role deleted successfully')),
      );
    } else {
      Map<String, dynamic> responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'] ?? 'Failed')),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please fill in the role name')),
              );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Role added successfully')),
        );
      } else {
        fetchRoles();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Role added successfully')),
        );
        Navigator.pop(context);
      }
    } else {
      Map<String, dynamic> responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'] ?? 'Failed to add role')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid input or permission denied')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Role updated successfully')),

        );
      } else {
        fetchRoles();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? 'Role updated  successfully')),
        );
        Navigator.pop(context);

      }
    } else {
      Map<String, dynamic> responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'] ?? 'Failed to update role')),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Roles',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.blue, size: 30),
                      onPressed: _showAddRoleModal,
                    ),

                ],
              ),
              const SizedBox(height: 10),
              roles.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const <DataColumn>[
                    DataColumn(
                      label: Text(
                        'Role Name',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Edit',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Delete',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: roles
                      .map((role) => DataRow(
                    cells: [
                      DataCell(Text(role['roleName'])),
                        DataCell(IconButton(
                          icon: Icon(Icons.edit, color: Colors.green),
                          onPressed: () => _showEditRoleModal(role['roleId'], role['roleName']),
                        )),

                        DataCell(IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDeleteRole(role['roleId']),
                        ))

                    ],
                  ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
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
