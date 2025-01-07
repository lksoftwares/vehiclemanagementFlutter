import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehiclemanagement/config.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  late Future<List<Vehicle>> _vehiclesFuture;

  @override
  void initState() {
    super.initState();
    _vehiclesFuture = _fetchVehicles();
  }

  Future<List<Vehicle>> _fetchVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('No token found');
    }

    final response = await http.get(
      Uri.parse('${Config.apiUrl}Vehicle/GetAllVehicle'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((vehicle) => Vehicle.fromJson(vehicle)).toList();
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
    bool _vehicleStatus = vehicle?.vehicleStatus ?? true;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(vehicle == null ? 'Add Vehicle' : 'Edit Vehicle'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _vehicleNoController,
                  decoration: InputDecoration(labelText: 'Vehicle No'),
                ),
                TextField(
                  controller: _ownerNameController,
                  decoration: InputDecoration(labelText: 'Owner Name'),
                ),
                TextField(
                  controller: _contactNumberController,
                  decoration: InputDecoration(labelText: 'Contact Number'),
                  keyboardType: TextInputType.phone,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Vehicle Status'),
                    Switch(
                      value: _vehicleStatus,
                      onChanged: (value) {
                        setState(() {
                          _vehicleStatus = value;
                        });
                      },
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
                // Validate input fields
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
                  // Add new vehicle
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
                      'vehicle_Status': _vehicleStatus,
                    }),
                  );

                  if (response.statusCode == 200) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response.body)),
                    );
                    setState(() {
                      _vehiclesFuture = _fetchVehicles();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response.body)),
                    );
                  }
                } else {
                  // Edit existing vehicle
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
                      'vehicle_Status': _vehicleStatus,
                    }),
                  );

                  if (response.statusCode == 200) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response.body)),
                    );
                    setState(() {
                      _vehiclesFuture = _fetchVehicles();
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(response.body)),
                    );
                  }
                }
              },
              child: Text(vehicle == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int vehicleId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response.body)),
                  );
                  setState(() {
                    _vehiclesFuture = _fetchVehicles();
                  });
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response.body)),
                  );
                }
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vehicles')),
      body: Padding(
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
                        DataColumn(label: Text('Created At')),
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
                            DataCell(Text(vehicle.createdAt)),
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
    );
  }
}

class Vehicle {
  final int vehicleId;
  final String vehicleNo;
  final String ownerName;
  final String contactNumber;
  final bool vehicleStatus;
  final String createdAt;

  Vehicle({
    required this.vehicleId,
    required this.vehicleNo,
    required this.ownerName,
    required this.contactNumber,
    required this.vehicleStatus,
    required this.createdAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleId: json['vehicleId'],
      vehicleNo: json['vehicleNo'],
      ownerName: json['ownerName'],
      contactNumber: json['contactNumber'],
      vehicleStatus: json['vehicle_Status'] == true,
      createdAt: json['createdAt'],
    );
  }
}
