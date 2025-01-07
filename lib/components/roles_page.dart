import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:vehiclemanagement/appbar_method.dart';
import '../config.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  List<Map<String, dynamic>> roles = [];
  String? token;

  @override
  void initState() {
    super.initState();
    _getToken().then((_) {
      fetchRoles();
    });
  }

  Future<void> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token');
    });
  }

  Future<void> fetchRoles() async {
    if (token == null) return;

    final response = await http.get(
      Uri.parse('${Config.apiUrl}Role/getallrole'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> roleData = json.decode(response.body);
      setState(() {
        roles = roleData.map((role) {
          return {
            'roleId': role['roleId'] ?? 0,
            'roleName': role['roleName'] ?? 'Unknown Role',
          };
        }).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.body)),
      );
    }
  }

  void _confirmDeleteRole(int roleId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Role'),
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
      },
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
      fetchRoles(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.body)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.body)),
      );
    }
  }

  void _showAddRoleModal() {
    String roleName = '';
    const int permissionId = 2;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Role'),
          content: TextField(
            onChanged: (value) => roleName = value,
            decoration: InputDecoration(
              labelText: 'Role Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Check if the role name is empty
                if (roleName.isEmpty) {
                  // Show a snackbar if the role name is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in the role name')),
                  );
                } else {
                  // Add the role and close the dialog
                  _addRole(roleName, permissionId);
                  Navigator.pop(
                      context); // Close the dialog after adding the role
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addRole(String roleName, int permissionId) async {
    if (token == null) return;

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
      fetchRoles();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Role added successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.body)),
      );
    }
  }

  void _showEditRoleModal(int roleId, String currentRoleName) {
    String updatedRoleName = currentRoleName;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Role'),
          content: TextField(
            controller: TextEditingController(text: currentRoleName),
            onChanged: (value) => updatedRoleName = value,
            decoration: InputDecoration(
              labelText: 'Role Name',
              border: OutlineInputBorder(),
            ),
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
      },
    );
  }

  Future<void> _updateRole(int roleId, String roleName) async {
    if (token == null || roleId == 0 || roleName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid input')),
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
      fetchRoles(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.body)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.body)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Roles',
      ),
      body: Padding(
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
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Edit',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Delete',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: roles
                          .map((role) => DataRow(
                                cells: [
                                  DataCell(Text(role['roleName'])),
                                  DataCell(IconButton(
                                    icon: Icon(Icons.edit, color: Colors.green),
                                    onPressed: () => _showEditRoleModal(
                                        role['roleId'], role['roleName']),
                                  )),
                                  DataCell(IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () =>
                                        _confirmDeleteRole(role['roleId']),
                                  )),
                                ],
                              ))
                          .toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
