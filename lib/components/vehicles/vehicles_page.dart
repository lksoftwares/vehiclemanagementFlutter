import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehiclemanagement/components/widgetmethods/appbar_method.dart';
import 'package:vehiclemanagement/config.dart';
import '../widgetmethods/alert_widget.dart';
import '../login/logout _method.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  late Future<List<Vehicle>> _vehiclesFuture;
  String? token;

  String? permissionType;
  bool canRead = false;
  bool canCreate = false;
  bool canUpdate = false;
  bool canDelete = false;
  @override
  void initState() {
    super.initState();
    _getToken().then((_) {
      _getPermissionType().then((_) {
        if (canRead) {
          _vehiclesFuture = _fetchVehicles();
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

      canRead = permissionType!.toString().contains('R');
      canCreate = permissionType!.toString().contains('C');
      canUpdate = permissionType!.toString().contains('U');
      canDelete = permissionType!.toString().contains('D');

      if (!canRead) {
        showCustomAlertDialog(context, title: 'Permission Denied', content: Text('You do not have permission to view roles.'), actions: []);
      }

      if (!canCreate) {
        showCustomAlertDialog(context, title: 'Permission Denied', content: Text('You do not have permission to add roles.'), actions: []);
      }

      if (!canUpdate) {
        showCustomAlertDialog(context, title: 'Permission Denied', content: Text('You do not have permission to edit roles.'), actions: []);
      }

      if (!canDelete) {
        showCustomAlertDialog(context, title: 'Permission Denied', content: Text('You do not have permission to delete roles.'), actions: []);
      }
    });
  }
  Future<List<Vehicle>> _fetchVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null || !canRead) {
      throw Exception('error');
    }

    final response = await http.get(
      Uri.parse('${Config.apiUrl}Vehicle/GetAllVehicle'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['isSuccess'] == true) {
        List<dynamic> vehiclesData = responseData['apiResponse'];

        return vehiclesData
            .map((vehicle) => Vehicle.fromJson(vehicle))
            .toList();
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load vehicles');
      }
    } else {
      throw Exception('Failed to load vehicles');
    }
  }

  void _showAddOrEditVehicleDialog(BuildContext context, {Vehicle? vehicle}) {
    final _vehicleNoController =
        TextEditingController(text: vehicle?.vehicleNo ?? '');
    final _ownerNameController =
        TextEditingController(text: vehicle?.ownerName ?? '');
    final _contactNumberController =
        TextEditingController(text: vehicle?.contactNumber ?? '');

    String _vehicleStatus =
        vehicle?.vehicleStatus == false ? 'Inactive' : 'Active';
    if (!canCreate && !canUpdate) {
      showCustomAlertDialog(
        context,
        title: 'Permission Denied',
        content: Text('You do not have permission to add and edit roles.'), actions: [],
      );
      return;
    }
    showCustomAlertDialog(
      context,
      title: vehicle == null ? 'Add Vehicle' : 'Edit Vehicle',
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _vehicleNoController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Vehicle No',
              ),
            ),
            SizedBox(height: 7),
            TextField(
              controller: _ownerNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Owner Name',
              ),
            ),
            SizedBox(height: 7),
            TextField(
              controller: _contactNumberController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Contact Number',
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
            ),
            SizedBox(height: 7),
            Text('Vehicle Status'),
            Row(
              children: [
                ChoiceChip(
                  label: Text('Active'),
                  selected: _vehicleStatus == 'Active',
                  onSelected: (selected) {
                    setState(() {
                      _vehicleStatus = 'Active';
                    });
                  },
                  selectedColor: Colors.green,
                  labelStyle: TextStyle(
                      color: _vehicleStatus == 'Active'
                          ? Colors.white
                          : Colors.green),
                ),
                SizedBox(width: 7),
                ChoiceChip(
                  label: Text('Inactive'),
                  selected: _vehicleStatus == 'Inactive',
                  onSelected: (selected) {
                    setState(() {
                      _vehicleStatus = 'Inactive';
                    });
                  },
                  selectedColor: Colors.red,
                  labelStyle: TextStyle(
                      color: _vehicleStatus == 'Inactive'
                          ? Colors.white
                          : Colors.red),
                ),
              ],
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
          onPressed: () async {
            if (_vehicleNoController.text.trim().isEmpty ||
                _ownerNameController.text.trim().isEmpty ||
                _contactNumberController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please fill all the fields')),
              );
              return;
            }

            final prefs = await SharedPreferences.getInstance();
            final String? token = prefs.getString('token');
            if (token == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('No token found')),
              );
              return;
            }

            if (vehicle == null) {
              final response = await http.post(
                Uri.parse('${Config.apiUrl}Vehicle/AddVehicle'),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                },
                body: json.encode({
                  'vehicleNo': _vehicleNoController.text,
                  'ownerName': _ownerNameController.text,
                  'contactNumber': _contactNumberController.text,
                  'vehicle_Status': _vehicleStatus == 'Active',
                }),
              );

              if (response.statusCode == 200) {
                Navigator.of(context).pop();
                Map<String, dynamic> responseData = json.decode(response.body);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(responseData['message'] ??
                          'Vehicle added successfully')),
                );
                setState(() {
                  _vehiclesFuture = _fetchVehicles();
                });
              } else {
                Map<String, dynamic> responseData = json.decode(response.body);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(responseData['message'] ?? 'Failed')),
                );
              }
            } else {
              final response = await http.put(
                Uri.parse(
                    '${Config.apiUrl}Vehicle/updateVehicle/${vehicle.vehicleId}'),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                },
                body: json.encode({
                  'vehicleNo': _vehicleNoController.text,
                  'ownerName': _ownerNameController.text,
                  'contactNumber': _contactNumberController.text,
                  'vehicle_Status': _vehicleStatus == 'Active',
                }),
              );

              if (response.statusCode == 200) {
                Navigator.of(context).pop();
                Map<String, dynamic> responseData = json.decode(response.body);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(responseData['message'] ??
                          'Vehicle updated successfully')),
                );
                setState(() {
                  _vehiclesFuture = _fetchVehicles();
                });
              } else {
                Map<String, dynamic> responseData = json.decode(response.body);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(responseData['message'] ?? 'Failed')),
                );
              }
            }
          },
          child: Text(vehicle == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int vehicleId) {
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
      title: 'Confirm Delete',
      content: Text('Are you sure you want to delete this vehicle?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            final String? token = prefs.getString('token');
            if (token == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('No token found')),
              );
              return;
            }

            final response = await http.delete(
              Uri.parse('${Config.apiUrl}Vehicle/deleteVehicle/$vehicleId'),
              headers: {'Authorization': 'Bearer $token'},
            );

            if (response.statusCode == 200) {
              Navigator.of(context).pop();
              Map<String, dynamic> responseData = json.decode(response.body);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(responseData['message'] ??
                        'Vehicle deleted successfully')),
              );
              setState(() {
                _vehiclesFuture = _fetchVehicles();
              });
            } else {
              Navigator.of(context).pop();
              Map<String, dynamic> responseData = json.decode(response.body);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(responseData['message'] ?? 'Failed')),
              );
            }
          },
          child: Text('Yes'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Vehicles',
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
                    'Vehicles',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.blue, size: 30),
                    onPressed: () {
                      _showAddOrEditVehicleDialog(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<Vehicle>>(
                future: _vehiclesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No vehicles found.'));
                  } else {
                    List<Vehicle> vehicles = snapshot.data!;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('Vehicle No')),
                          DataColumn(label: Text('Owner Name')),
                          DataColumn(label: Text('Contact Number')),
                          DataColumn(label: Text('Vehicle Status')),
                          DataColumn(label: Text('Edit')),
                          DataColumn(label: Text('Delete')),
                        ],
                        rows: vehicles.map((vehicle) {
                          return DataRow(
                            cells: [
                              DataCell(Text(vehicle.vehicleNo)),
                              DataCell(Text(vehicle.ownerName)),
                              DataCell(Text(vehicle.contactNumber)),
                              DataCell(
                                Icon(
                                  vehicle.vehicleStatus
                                      ? Icons.check
                                      : Icons.close,
                                  color: vehicle.vehicleStatus
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              DataCell(IconButton(
                                icon: Icon(Icons.edit, color: Colors.green),
                                onPressed: () {
                                  _showAddOrEditVehicleDialog(context,
                                      vehicle: vehicle);
                                },
                              )),
                              DataCell(IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _showDeleteConfirmationDialog(
                                      context, vehicle.vehicleId);
                                },
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Vehicle {
  final int vehicleId;
  final String vehicleNo;
  final String ownerName;
  final String contactNumber;
  final bool vehicleStatus;

  Vehicle({
    required this.vehicleId,
    required this.vehicleNo,
    required this.ownerName,
    required this.contactNumber,
    required this.vehicleStatus,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleId: json['vehicleId'],
      vehicleNo: json['vehicleNo'],
      ownerName: json['ownerName'],
      contactNumber: json['contactNumber'],
      vehicleStatus: json['vehicle_Status'] == true,
    );
  }
}
