
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  File? _selectedImage;

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
              'iconPath': item['iconPath'],
              'iconUrl': item['iconUrl'],
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

  Future<void> _addMenu(String menuName, File? imageFile) async {
    final token = await _getToken();
    if (token == null) {
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${Config.apiUrl}Menus/addMenu'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['Menu_Name'] = menuName;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('IconPath', imageFile.path),
      );
    }

    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.of(context).pop();
      _fetchMenuData();
      final responseData = await response.stream.bytesToString();
      final decodedData = json.decode(responseData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(decodedData['message'] ?? 'Menu added successfully')),
      );
    } else {
      final responseData = await response.stream.bytesToString();
      final decodedData = json.decode(responseData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(decodedData['message'] ?? 'Failed')),
      );
    }
  }

  Future<void> _updateMenu(int menuId, String menuName, File? imageFile) async {
    final token = await _getToken();
    if (token == null) {
      return;
    }

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('${Config.apiUrl}Menus/updateMenu/$menuId'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['Menu_Name'] = menuName;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('IconPath', imageFile.path),
      );
    }

    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.of(context).pop();
      _fetchMenuData();
      final responseData = await response.stream.bytesToString();
      final decodedData = json.decode(responseData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(decodedData['message'] ?? 'Menu updated successfully')),
      );
    } else {
      final responseData = await response.stream.bytesToString();
      final decodedData = json.decode(responseData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(decodedData['message'] ?? 'Failed')),
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
            content: Text(responseData['message'] ?? 'Menu deleted successfully')),
      );
    } else {
      Map<String, dynamic> responseData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseData['message'] ?? 'Failed')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }
  void _showMenuDialog({int? menuId, String? currentName, String? currentImage}) {
    _menuNameController.text = currentName ?? '';
    _selectedMenuId = menuId;
    _selectedImage = null;

    showCustomAlertDialog(
      context,
      title: menuId == null ? 'Add Menu' : 'Edit Menu',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _menuNameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter Menu Name',
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: Icon(Icons.image),
            label: Text('Select Image'),
          ),
          const SizedBox(height: 10),
          if (_selectedImage != null)
            Image.file(
              _selectedImage!,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            )
          else if (currentImage != null)
            Image.network(
              currentImage,
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _menuNameController.clear();
            setState(() {
              _selectedImage = null;
            });
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final menuName = _menuNameController.text.trim();

            if (menuName.isEmpty || _selectedImage == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please fill all fields')),
              );
              return;
            }

            if (menuId == null) {
              _addMenu(menuName, _selectedImage);
            } else {
              _updateMenu(menuId, menuName, _selectedImage);
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
                    onPressed: () => _showMenuDialog(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _menuData.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                scrollDirection: Axis.horizontal,

                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Icon', style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),)),
                    DataColumn(label: Text('MenuName', style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),)),
                    DataColumn(label: Text('Edit', style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),)),
                    DataColumn(label: Text('Delete', style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),)),
                  ],
                  rows: _menuData.map((item) {
                    return DataRow(cells: [
                      DataCell(
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: item['iconUrl'] != null
                              ? NetworkImage(item['iconUrl'])
                              : null,
                          child: item['iconUrl'] == null
                              ? Icon(Icons.image_not_supported, size: 24)
                              : null,
                        ),
                      ),
                      DataCell(Text(item['menuName'])),
                      DataCell(Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.green),
                            onPressed: () => _showMenuDialog(
                              menuId: item['menuId'],
                              currentName: item['menuName'],
                              currentImage: item['iconUrl'],
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
