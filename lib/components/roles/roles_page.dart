import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:vehiclemanagement/components/widgetmethods/appbar_method.dart';
import '../../config.dart';
import '../login/logout _method.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../widgetmethods/alert_widget.dart';
import '../widgetmethods/bottomnavigation_method.dart';
import '../widgetmethods/datagrid_class.dart';
import '../widgetmethods/datagrid_controller.dart';
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
  List<String> dropdownOptions = [];
  DataGridController _dataGridController = DataGridController();
  bool isLoading = false;

  List<ColumnConfig> getColumnsConfig() {
    return [
      ColumnConfig(
        columnName: 'roleName',
        labelText: 'Role Name',
        allowSorting: true,
        allowFiltering: true,
        visible: true,
      ),

      ColumnConfig(
        columnName: 'roleName',
        labelText: 'Role Name',
          visible: true,
      ),
      ColumnConfig(
          columnName: 'roleName',
          labelText: 'Role dropdown',
          visible: true,
          allowFiltering: true
      ),
    ];
  }



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
        showCustomAlertDialog(
          context,
          title: 'Permission Error',
          content: Text('Permission Type is not found.'),
          actions: [],
        );
        return;
      }

      canCreate = permissionType!.contains('C');
      canRead = permissionType!.contains('R');
      canUpdate = permissionType!.contains('U');
      canDelete = permissionType!.contains('D');
    });
  }

  Future<void> fetchRoles() async {
    if (token == null || !canRead) return;
    setState(() {
      isLoading = true;
    });
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
            filteredRoles = roles;
            dropdownOptions = ['Admin', 'User', 'Manager'];
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
    setState(() {
      isLoading = false;
    });
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
    if (token == null || !canDelete) return;

    final response = await http.delete(
      Uri.parse('${Config.apiUrl}Role/DeleteRole/$roleId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      showToast(msg: 'Role deleted successfully');
      fetchRoles();
    } else {
      showToast(msg: 'Failed to delete role');
    }
  }
  void _showAddRoleModal() {
    if (!canCreate) {
      showCustomAlertDialog(
        context,
        title: 'Permission Denied',
        content: Text('You do not have permission to add roles.'),
        actions: [],
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
      Uri.parse('${Config.apiUrl}Role/AddRole'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
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
  void _showEditRoleModal(int roleId, String roleName) {
    if (!canUpdate) {
      showCustomAlertDialog(
        context,
        title: 'Permission Denied',
        content: Text('You do not have permission to edit roles.'),
        actions: [],
      );
      return;
    }

    TextEditingController _editRoleNameController = TextEditingController(text: roleName);

    showCustomAlertDialog(
      context,
      title: 'Edit Role',
      content: TextField(
        controller: _editRoleNameController,
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
            if (_editRoleNameController.text.isEmpty) {
              showToast(msg: 'Role name cannot be empty');
            } else {
              _updateRole(roleId, _editRoleNameController.text);
            }
          },
          child: Text('Update'),
        ),
      ],
    );
  }

  Future<void> _updateRole(int roleId, String roleName) async {
    if (token == null || !canUpdate) return;

    final response = await http.put(
      Uri.parse('${Config.apiUrl}Role/UpdateRole/$roleId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
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
        Navigator.pop(context);
      } else {
        fetchRoles();
        showToast(
          msg: responseData['message'] ?? 'Role updated successfully',
          backgroundColor: Colors.green,
        );
        Navigator.pop(context);

      }
    } else {
      Map<String, dynamic> responseData = json.decode(response.body);
      showToast(
        msg: responseData['message'] ?? 'Failed to update role',
      );
    }
  }

  void _printSelectedRoleIds() {
    final selectedRows = _dataGridController.selectedRows;

    if (selectedRows.isEmpty) {
      showToast(msg: 'No roles selected');
      return;
    }

    final selectedRoleIds = selectedRows.map((row) {
      return row.getCells()[1].value;
    }).toList();

    print('Selected Role IDs: $selectedRoleIds');
    showToast(msg: 'Selected Role IDs: $selectedRoleIds', backgroundColor: Colors.green);
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
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else if (filteredRoles.isEmpty)
                NoDataFoundScreen()
              else
                Column(
                  children: [
                    Container(
                      height: 480,
                      child: SfDataGridTheme(
                        data: SfDataGridThemeData(
                          headerColor: Colors.blueAccent[100],
                        ),
                        child: SfDataGrid(
                          headerGridLinesVisibility: GridLinesVisibility.both,
                          gridLinesVisibility: GridLinesVisibility.both,
                          showCheckboxColumn: true,
                          selectionMode: SelectionMode.multiple,
                          allowSorting: true,
                          frozenColumnsCount: 2,
                          source: RoleDataSource(
                            roles: filteredRoles,
                            onEditRole: _showEditRoleModal,
                            onDeleteRole: _confirmDeleteRole,
                            dropdownOptions: dropdownOptions,
                          ),
                          allowFiltering: true,
                          columns: buildDataGridColumns(getColumnsConfig()),
                          controller: _dataGridController,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _printSelectedRoleIds,
                      child: Text('Print Selected Role IDs'),
                    ),
                  ],
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

class RoleDataSource extends DataGridSource {
  final List<Map<String, dynamic>> roles;
  final Function(int roleId, String roleName) onEditRole;
  final Function(int roleId) onDeleteRole;
  final List<String> dropdownOptions;
  final Map<int, String> _selectedRoleValue = {};
  final Map<int, bool> _selectedRoleCheckbox = {};  // Track checkbox state

  RoleDataSource({
    required this.roles,
    required this.onEditRole,
    required this.onDeleteRole,
    required this.dropdownOptions,
  }) {
    // Initialize checkbox state for each role to false by default
    for (var role in roles) {
      _selectedRoleCheckbox[role['roleId']] = false;
    }
  }

  @override
  List<DataGridRow> get rows => roles.map<DataGridRow>((role) {
    return DataGridRow(cells: [
      DataGridCell<String>(columnName: 'roleName', value: role['roleName']),
      DataGridCell<int>(columnName: 'roleId', value: role['roleId']),
      DataGridCell<String>(columnName: 'dropdown', value: _selectedRoleValue[role['roleId']] ?? dropdownOptions[0]),
      // Checkbox cell
      DataGridCell<bool>(
        columnName: 'checkbox',
        value: _selectedRoleCheckbox[role['roleId']] ?? false,
      ),
    ]);
  }).toList();

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final roleId = row.getCells()[1].value as int;
    final roleName = row.getCells()[0].value as String;
    final dropdownValue = row.getCells()[2].value as String;
    final checkboxValue = row.getCells()[3].value as bool;

    return DataGridRowAdapter(cells: [
      // Role Name cell
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(roleName),
      ),
      // Role ID cell
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: Text(roleName),
      ),
      // Dropdown cell
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.centerLeft,
        child: DropdownButton<String>(
          value: dropdownValue,
          onChanged: (String? newValue) {
            if (newValue != null) {
              _selectedRoleValue[roleId] = newValue;
              notifyListeners();
            }
          },
          items: dropdownOptions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
      // Checkbox cell
      Container(
        padding: EdgeInsets.all(8.0),
        alignment: Alignment.center,
        child: Checkbox(
          value: checkboxValue,
          onChanged: (bool? newValue) {
            if (newValue != null) {
              _selectedRoleCheckbox[roleId] = newValue;
              notifyListeners();
            }
          },
        ),
      ),
      // Edit button
      Container(
        alignment: Alignment.center,
        child: IconButton(
          icon: Icon(Icons.edit, color: Colors.green),
          onPressed: () {
            onEditRole(roleId, roleName);
          },
        ),
      ),
      // Delete button
      Container(
        alignment: Alignment.center,
        child: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            onDeleteRole(roleId);
          },
        ),
      ),
    ]);
  }
}
