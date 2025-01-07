import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vehiclemanagement/appbar_method.dart';

class UsershiftPage extends StatefulWidget {
  const UsershiftPage({super.key});

  @override
  State<UsershiftPage> createState() => _UsershiftPageState();
}

class _UsershiftPageState extends State<UsershiftPage> {
  late Future<List<dynamic>> shiftsFuture;

  @override
  void initState() {
    super.initState();
    shiftsFuture = fetchShifts();
  }

  Future<List<dynamic>> fetchShifts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('http://192.168.1.66:7148/UsersShift/GetAllShifts'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load shifts');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'User Shift',
      ),
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
                  onPressed: () {},
                ),
              ],
            ),
            FutureBuilder<List<dynamic>>(
              future: shiftsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No shifts available.'));
                }

                final shifts = snapshot.data!;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Shift Name')),
                      DataColumn(label: Text('Start Time')),
                      DataColumn(label: Text('End Time')),
                      DataColumn(label: Text('Grace Time')),
                      DataColumn(label: Text('Created At')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: shifts.map((shift) {
                      return DataRow(cells: [
                        DataCell(Text(shift['shiftName'])),
                        DataCell(Text(shift['startTime'])),
                        DataCell(Text(shift['endTime'])),
                        DataCell(Text(shift['graceTime'].toString())),
                        DataCell(Text(shift['createdAt'])),
                        DataCell(
                          Icon(
                            shift.vehicleStatus ? Icons.check : Icons.close,
                            color:
                                shift.vehicleStatus ? Colors.green : Colors.red,
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
