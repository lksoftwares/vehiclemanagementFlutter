
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../login/logout _method.dart';
import '../widgetmethods/appbar_method.dart';
import '../../config.dart';
import '../widgetmethods/alert_widget.dart';
import '../widgetmethods/bottomnavigation_method.dart';
import '../widgetmethods/no_data_found.dart';
import '../widgetmethods/toast_method.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  List<Map<String, dynamic>> _menuData = [];
  List<Map<String, dynamic>> _filteredMenuData = [];
  List<Map<String, dynamic>> _allMenus = [];
  String? _selectedMenuName;
  int? _selectedParentMenuId;
  final TextEditingController _menuNameController = TextEditingController();
  final TextEditingController _pageNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  int? _selectedMenuId;
  File? _selectedImage;
  int _currentIndex = 0;
  bool isLoading = false;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchMenuData() async {
    final token = await _getToken();
    if (token == null) {
      return;
    }
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse('${Config.apiUrl}Menus/GetAllMenu'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['statusCode'] == 200 && data['isSuccess']) {
        setState(() {
          _menuData = List<Map<String, dynamic>>.from(data['apiResponse'].map((item) {
            return {
              'menuId': item['menuId'],
              'menuName': item['menuName'],
              'iconPath': item['iconPath'],
              'iconUrl': item['iconUrl'],
            };
          }).toList());
          _filteredMenuData = List<Map<String, dynamic>>.from(_menuData);
          _allMenus = List<Map<String, dynamic>>.from(data['apiResponse']);
        });
      } else {
        showToast(
          msg: data['message'] ?? 'Failed to load menus',

        );
      }
    } else {
      showToast(
        msg: 'Failed to load menu ',
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  void _filterMenuData(String query) {
    final filteredMenus = _menuData.where((menu) {
      final menuName = menu['menuName'].toLowerCase();
      final searchQuery = query.toLowerCase();
      return menuName.contains(searchQuery);
    }).toList();

    setState(() {
      _filteredMenuData = filteredMenus;
    });
  }

  void _showMenuDialog({int? menuId, String? currentName, String? currentImage}) {
    _menuNameController.text = currentName ?? '';
    _pageNameController.text = '';
    _selectedMenuId = menuId;
    _selectedImage = null;
    _selectedMenuName = null;
    _selectedParentMenuId = 0;

    if (menuId != null) {
      final selectedMenu = _allMenus.firstWhere((menu) => menu['menuId'] == menuId);
      _selectedParentMenuId = selectedMenu['parentId'];

      _pageNameController.text = selectedMenu['pageName']?.isNotEmpty == true
          ? selectedMenu['pageName']!
          : '';

      if (_selectedParentMenuId != 0) {
        _selectedMenuName = _allMenus.firstWhere(
                (menu) => menu['menuId'] == _selectedParentMenuId)['menuName'];
      }
    }

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
          const SizedBox(height: 8),
          TextField(
            controller: _pageNameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter Page Name',
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedMenuName,
            onChanged: (String? newValue) {
              setState(() {
                _selectedMenuName = newValue;

                if (newValue == 'No Parent') {
                  _selectedParentMenuId = 0;
                } else {
                  if (newValue != null) {
                    _selectedParentMenuId = _allMenus.firstWhere(
                            (menu) => menu['menuName'] == newValue
                    )['menuId'];
                  }
                }
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Select Parent Menu',
            ),
            items: [
              DropdownMenuItem<String>(
                value: 'No Parent',
                child: Text('No Parent'),
              ),
              ..._allMenus.map<DropdownMenuItem<String>>((menu) {
                return DropdownMenuItem<String>(
                  value: menu['menuName'],
                  child: Text(menu['menuName']),
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text('Select Image'),
              ),
              const SizedBox(width: 8),
              if (_selectedImage != null)
                Image.file(
                  _selectedImage!,
                  height: 55,
                  width: 55,
                  fit: BoxFit.cover,
                )
              else if (currentImage != null)
                Image.network(
                  currentImage,
                  height: 55,
                  width: 55,
                  fit: BoxFit.cover,
                ),
            ],
          ),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _menuNameController.clear();
            _pageNameController.clear();
            setState(() {
              _selectedImage = null;
            });
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final menuName = _menuNameController.text.trim();
            final pageName = _pageNameController.text.trim();

            if (menuName.isEmpty) {
              showToast(
                msg:'Menu Name cannot be empty',

              );
              return;
            }

            if (menuId == null) {
              _addMenu(menuName, pageName, _selectedImage, _selectedParentMenuId);
            } else {
              _updateMenu(menuId!, menuName, pageName, _selectedImage, _selectedParentMenuId);
            }
          },
          child: Text(menuId == null ? 'Add' : 'Update'),
        )
      ],
    );
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

  Future<void> _addMenu(String menuName, String pageName, File? imageFile, int? parentMenuId) async {
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

    if (pageName.isNotEmpty) {
      request.fields['Page_Name'] = pageName;
    }

    if (parentMenuId != null) {
      request.fields['Parent_Id'] = parentMenuId.toString();
    }

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
      showToast(
        msg: decodedData['message'] ?? 'Menu added successfully',
        backgroundColor: Colors.green,

      );
    } else {
      final responseData = await response.stream.bytesToString();
      final decodedData = json.decode(responseData);
      showToast(
        msg: decodedData['message'] ?? 'Failed',

      );
    }
  }

  Future<void> _updateMenu(int menuId, String menuName, String pageName, File? imageFile, int? parentMenuId) async {
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

    if (pageName.isNotEmpty) {
      request.fields['Page_Name'] = pageName;
    }

    if (parentMenuId != null) {
      request.fields['Parent_Id'] = parentMenuId.toString();
    }

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
      showToast(
        msg: decodedData['message'] ?? 'Menu updated successfully',
        backgroundColor: Colors.green,

      );
    } else {
      final responseData = await response.stream.bytesToString();
      final decodedData = json.decode(responseData);
      showToast(
        msg: decodedData['message'] ?? 'Failed',

      );
    }
  }

  void _showDeleteConfirmationDialog(int menuId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Menu'),
          content: Text('Are you sure you want to delete this menu?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteMenu(menuId);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMenu(int menuId) async {
    final token = await _getToken();
    if (token == null) {
      return;
    }

    final response = await http.delete(
      Uri.parse('${Config.apiUrl}Menus/deleteMenu/$menuId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      _fetchMenuData();
      final responseData = json.decode(response.body);
      showToast(
        msg: responseData['message'] ?? 'Menu deleted successfully',
        backgroundColor: Colors.green,

      );
    } else {
      final responseData = json.decode(response.body);
      showToast(
        msg: responseData['message'] ?? 'Failed',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMenuData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Menus',
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
                        labelText: 'Search by MenuName',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (query) {
                        _filterMenuData(query);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.blue, size: 30),
                    onPressed: () => _showMenuDialog(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else if (_filteredMenuData.isEmpty)
                NoDataFoundScreen()
              else SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Icon', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('MenuName', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Edit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Delete', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                  ],
                  rows: _filteredMenuData.map((item) {
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
                            onPressed: () => _showDeleteConfirmationDialog(item['menuId']),
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
