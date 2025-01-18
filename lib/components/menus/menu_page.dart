import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widgetmethods/appbar_method.dart';
import '../../config.dart';
import '../widgetmethods/alert_widget.dart';
import '../login/logout _method.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Map<String, dynamic>> _menuData = [];
  final TextEditingController _menuNameController = TextEditingController();
  int? _selectedMenuId;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchMenuData() async {
    final token = await _getToken();
    if (token == null) {
      return;
    }

    final response = await http.get(
      Uri.parse('${Config.apiUrl}Menus/GetAllMenu'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['statusCode'] == 200 && data['isSuccess']) {
        setState(() {
          _menuData =
              List<Map<String, dynamic>>.from(data['apiResponse'].map((item) {
            return {
              'menuId': item['menuId'],
              'menuName': item['menuName'],
            };
          }).toList());
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(data['message'] ?? 'Failed to load menu data')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load menu data')),
      );
    }
  }

  Future<void> _addMenu(String menuName) async {
    final token = await _getToken();
    if (token == null) {
      return;
    }

    final response = await http.post(
      Uri.parse('${Config.apiUrl}Menus/addMenu'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'menuName': menuName}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.of(context).pop();
      _fetchMenuData();
      Map<String, dynamic> responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(responseData['message'] ?? 'Menu added successfully')),
      );
    } else {
      Map<String, dynamic> responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'] ?? 'Failed')),
      );
    }
  }

  Future<void> _updateMenu(int menuId, String menuName) async {
    final token = await _getToken();
    if (token == null) {
      return;
    }

    final response = await http.put(
      Uri.parse('${Config.apiUrl}Menus/updateMenu/$menuId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'menuName': menuName}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.of(context).pop();
      _fetchMenuData();
      Map<String, dynamic> responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(responseData['message'] ?? 'Menu updated successfully')),
      );
    } else {
      Map<String, dynamic> responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'] ?? 'Failed')),
      );
    }
  }

  Future<void> _deleteMenu(int menuId) async {
    final token = await _getToken();
    if (token == null) {
      return;
    }

    final response = await http.delete(
      Uri.parse('${Config.apiUrl}Menus/deletemenu/$menuId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      Navigator.of(context).pop();
      _fetchMenuData();
      Map<String, dynamic> responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(responseData['message'] ?? 'Menu deleted successfully')),
      );
    } else {
      Map<String, dynamic> responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'] ?? 'Failed')),
      );
    }
  }

  void _showMenuDialog({int? menuId, String? currentName}) {
    _menuNameController.text = currentName ?? '';
    _selectedMenuId = menuId;

    showCustomAlertDialog(
      context,
      title: menuId == null ? 'Add Menu' : 'Edit Menu',
      content: TextField(
        controller: _menuNameController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Enter Menu Name',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _menuNameController.clear();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final menuName = _menuNameController.text.trim();
            if (menuName.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please fill in the menu name field')),
              );
              return;
            }
            if (menuId == null) {
              _addMenu(menuName);
            } else {
              _updateMenu(menuId, menuName);
            }
          },
          child: Text(menuId == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(int menuId) {
    showCustomAlertDialog(
      context,
      title: 'Confirm Deletion',
      content: Text('Are you sure you want to delete this menu?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _deleteMenu(menuId),
          child: Text('Yes'),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchMenuData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Menus',
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
                    'Menus',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.blue, size: 30),
                    onPressed: _showMenuDialog,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _menuData.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Menu Name', style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),)),
                          DataColumn(label: Text('Edit', style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),)),
                          DataColumn(label: Text('Delete', style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),)),
                        ],
                        rows: _menuData.map((item) {
                          return DataRow(cells: [
                            DataCell(Text(item['menuName'])),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.green),
                                  onPressed: () => _showMenuDialog(
                                    menuId: item['menuId'],
                                    currentName: item['menuName'],
                                  ),
                                ),
                              ],
                            )),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showDeleteConfirmationDialog(
                                      item['menuId']),
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
