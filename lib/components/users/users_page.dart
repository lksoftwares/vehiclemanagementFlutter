import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';  // Import fluttertoast package
import '../login/logout _method.dart';
import '../widgetmethods/appbar_method.dart';
import '../../config.dart';
import '../widgetmethods/alert_widget.dart';
import '../widgetmethods/bottomnavigation_method.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<dynamic> userList = [];
  List<dynamic> roles = [];
  int? selectedRoleId;
  bool isLoading = true;
  String? token;
  String? permissionType;
  int _currentIndex = 0;
  bool canRead = false;
  bool canCreate = false;
  bool canUpdate = false;
  bool canDelete = false;

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchRoles();
    _getToken().then((_) {
      _getPermissionType().then((_) {
        if (canRead) {
          fetchData();
        }
      });
    });
  }

  List<dynamic> getFilteredUsers() {
    if (_searchController.text.isEmpty) {
      return userList;
    }

    String query = _searchController.text.toLowerCase();

    return userList.where((user) {
      bool matchesUserName = user['userName'].toLowerCase().contains(query);
      bool matchesUserEmail = user['userEmail'].toLowerCase().contains(query);
      bool matchesUserRole = user['userRole'].toLowerCase().contains(query);

      return matchesUserName || matchesUserEmail || matchesUserRole;
    }).toList();
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
        showCustomAlertDialog(context, title: 'Permission Error', content: Text('Permission Type is not found.'), actions: []);
        return;
      }

      canCreate = permissionType!.toString().contains('C');
      canRead = permissionType!.toString().contains('R');
      canUpdate = permissionType!.toString().contains('U');
      canDelete = permissionType!.toString().contains('D');
    });
  }

  Future<void> fetchRoles() async {
    final response = await http.get(Uri.parse('${Config.apiUrl}Role/getallrole'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['isSuccess'] == true) {
        setState(() {
          roles = data['apiResponse'];
        });
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Failed to fetch roles',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  Future<void> fetchData() async {
    if (token == null || !canRead) return;

    final response = await http.get(
      Uri.parse('${Config.apiUrl}Users/GetAllUsers'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': '*/*',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['isSuccess'] == true) {
        setState(() {
          userList = data['apiResponse']['usersLists'];
          isLoading = false;
        });
      } else {
        Fluttertoast.showToast(
            msg: data['message'] ?? 'Failed to fetch users',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Failed to load data: ${response.statusCode}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  Future<void> addUser(String name, String email, String password) async {
    if (token == null || !canCreate) return;

    final response = await http.post(
      Uri.parse('${Config.apiUrl}Users/register'),
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'User_Name': name,
        'User_Email': email,
        'User_Password': password,
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['dup'] == true) {
        Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Users added successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
        Navigator.pop(context);
      } else {
        fetchData();
        Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Users added successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    } else {
      Map<String, dynamic> responseData = json.decode(response.body);
      Fluttertoast.showToast(
          msg: responseData['message'] ?? 'Failed to add users',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  void showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    final _formKey = GlobalKey<FormState>();

    if (!canCreate) {
      showCustomAlertDialog(
        context,
        title: 'Permission Denied',
        content: Text('You do not have permission to add roles.'),
        actions: [],
      );
      return;
    }

    showCustomAlertDialog(
      context,
      title: 'Add User',
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            SizedBox(height: 7),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
                if (!emailRegExp.hasMatch(value)) {
                  return 'Please enter a valid Gmail address';
                }
                return null;
              },
            ),
            SizedBox(height: 7),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              addUser(nameController.text, emailController.text, passwordController.text);
              Navigator.of(context).pop();
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  Future<void> deleteUser(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null || userId == 0) {
      Fluttertoast.showToast(
          msg: 'Invalid User ID',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }

    final response = await http.delete(
      Uri.parse('${Config.apiUrl}Users/deleteUser/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      fetchData();
      Map<String, dynamic> responseData = json.decode(response.body);
      Fluttertoast.showToast(
          msg: responseData['message'] ?? 'User deleted successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } else {
      Map<String, dynamic> responseData = json.decode(response.body);
      Fluttertoast.showToast(
          msg: responseData['message'] ?? 'Failed to delete user',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  Future<void> updateUser(int userId, String name, String email, String password, int Role_Id) async {
    if (token == null || !canUpdate) return;

    Map<String, String> requestBody = {
      'User_Name': name,
      'User_Email': email,
      'User_Password': password,
      'Role_Id': Role_Id.toString(),
    };

    final response = await http.put(
      Uri.parse('${Config.apiUrl}Users/updateUser/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['dup'] == true) {
        Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Users updated successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
      } else {
        fetchData();
        Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Users updated successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
        Navigator.pop(context);
      }
    } else {
      Map<String, dynamic> responseData = json.decode(response.body);
      Fluttertoast.showToast(
          msg: responseData['message'] ?? 'Failed to update users',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  void showEditUserDialog(Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['userName']);
    final emailController = TextEditingController(text: user['userEmail']);
    final passwordController = TextEditingController(text: user['userPassword']);

    int? selectedRoleId = roles.firstWhere(
          (role) => role['roleName'] == user['userRole'],
      orElse: () => {'roleId': 0},
    )['roleId'];

    if (!canUpdate) {
      showCustomAlertDialog(
        context,
        title: 'Permission Denied',
        content: Text('You do not have permission to edit roles.'), actions: [],
      );
      return;
    }

    showCustomAlertDialog(
      context,
      title: 'Edit User',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Name',
            ),
          ),
          SizedBox(height: 7),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Email',
            ),
          ),
          SizedBox(height: 7),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Password',
            ),
          ),
          SizedBox(height: 7),
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Role',
            ),
            items: roles.map<DropdownMenuItem<int>>((role) {
              return DropdownMenuItem<int>(
                value: role['roleId'],
                child: Text(role['roleName']),
              );
            }).toList(),
            onChanged: (int? value) {
              setState(() {
                selectedRoleId = value;
              });
            },
            value: selectedRoleId,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            updateUser(user['userId'], nameController.text, emailController.text, passwordController.text, selectedRoleId ?? 0);
          },
          child: Text('Update'),
        ),
      ],
    );
  }

  void showDeleteUserDialog(int userId) {
    showCustomAlertDialog(
      context,
      title: 'Delete User',
      content: Text('Are you sure you want to delete this user?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            deleteUser(userId);
            Navigator.of(context).pop();
          },
          child: Text('Delete'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Users',
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
                        labelText: 'Search by UserName, UserEmail and UserRole',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (query) {
                        setState(() {});
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.blue, size: 30),
                    onPressed: showAddUserDialog,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              getFilteredUsers().isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 200,),
                    Text(
                      'No results found 😞',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Try searching with a different term.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ) : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Username', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('User Email', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('User Role', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('User Password', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Edit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Delete', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold))),
                  ],
                  rows: getFilteredUsers().map((user) {
                    return DataRow(
                      cells: [
                        DataCell(Text(user['userName'] ?? '')),
                        DataCell(Text(user['userEmail'] ?? '')),
                        DataCell(Text(user['userRole'] ?? '')),
                        DataCell(Text(user['userPassword'] ?? '')),
                        DataCell(IconButton(
                          icon: Icon(Icons.edit, color: Colors.green),
                          onPressed: () => showEditUserDialog(user),
                        )),
                        DataCell(IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => showDeleteUserDialog(user['userId']),
                        )),
                      ],
                    );
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
