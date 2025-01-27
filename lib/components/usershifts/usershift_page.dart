// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'package:vehiclemanagement/components/widgetmethods/appbar_method.dart';
//
// import '../../config.dart';
// import '../widgetmethods/alert_widget.dart';
// import '../login/logout _method.dart';
// import '../widgetmethods/bottomnavigation_method.dart';
//
// class UsershiftPage extends StatefulWidget {
//   const UsershiftPage({super.key});
//
//   @override
//   State<UsershiftPage> createState() => _UsershiftPageState();
// }
//
// class _UsershiftPageState extends State<UsershiftPage> {
//   late Future<List<dynamic>> shiftsFuture;
//   String? token;
//   String? permissionType;
//   bool canRead = false;
//   bool canCreate = false;
//   bool canUpdate = false;
//   int _currentIndex = 0;
//
//   bool canDelete = false;
//   @override
//   void initState() {
//     super.initState();
//     _getToken().then((_) {
//       _getPermissionType().then((_) {
//         if (canRead) {
//           shiftsFuture = fetchShifts();
//         }
//       });
//     });
//   }
//   Future<void> _getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       token = prefs.getString('token');
//     });
//   }
//
//   Future<void> _getPermissionType() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     print(permissionType);
//     setState(() {
//       permissionType = prefs.getString('selected_permission_type');
//
//       if (permissionType == null) {
//         showCustomAlertDialog(context, title: 'Permission Error', content: Text('Permission Type is not found .'), actions: []);
//         return;
//       }
//
//       canRead = permissionType!.toString().contains('R');
//       canCreate = permissionType!.toString().contains('C');
//       canUpdate = permissionType!.toString().contains('U');
//       canDelete = permissionType!.toString().contains('D');
//
//     });
//   }
//
//   Future<List<dynamic>> fetchShifts() async {
//
//     if (token == null || !canRead) {
//       throw Exception('error');
//     };
//
//     final response = await http.get(
//       Uri.parse('${Config.apiUrl}UsersShift/GetAllShifts'),
//       headers: {
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       return List.from(data['apiResponse']);
//     } else {
//       throw Exception('Failed to load shifts');
//     }
//   }
//
//   Future<void> deleteShift(int shiftId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token') ?? '';
//
//     final response = await http.delete(
//       Uri.parse('${Config.apiUrl}UsersShift/deleteShift/$shiftId'),
//       headers: {
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       Navigator.of(context).pop();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(response.body)),
//       );
//       setState(() {
//         shiftsFuture = fetchShifts();
//       });
//     } else {
//       Navigator.of(context).pop();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(response.body)),
//       );
//     }
//   }
//
//   void confirmDelete(int shiftId) {
//     if (!canDelete) {
//       showCustomAlertDialog(
//         context,
//         title: 'Permission Denied',
//         content: Text('You do not have permission to delete roles.'), actions: [],
//       );
//       return;
//     }
//     showCustomAlertDialog(
//       context,
//       title: 'Confirm Delete',
//       content: const Text('Are you sure you want to delete this shift?'),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Cancel'),
//         ),
//         TextButton(
//           onPressed: () {
//             deleteShift(shiftId);
//           },
//           child: const Text('Delete', style: TextStyle(color: Colors.red)),
//         ),
//       ],
//     );
//   }
//
//   void showEditShiftDialog(int shiftId, String shiftName, String startTime,
//       String endTime, int graceTime, bool shiftStatus) {
//     final TextEditingController shiftNameController =
//         TextEditingController(text: shiftName);
//     final TextEditingController graceTimeController =
//         TextEditingController(text: graceTime.toString());
//     TimeOfDay? startTimePicked = TimeOfDay(
//         hour: int.parse(startTime.split(":")[0]),
//         minute: int.parse(startTime.split(":")[1]));
//     TimeOfDay? endTimePicked = TimeOfDay(
//         hour: int.parse(endTime.split(":")[0]),
//         minute: int.parse(endTime.split(":")[1]));
//     bool shiftStatusEdit = shiftStatus;
//
//     Future<void> updateShift() async {
//       if (token == null || !canUpdate) return;
//
//
//       final response = await http.put(
//         Uri.parse('${Config.apiUrl}UsersShift/updateShift/$shiftId'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           'shiftName': shiftNameController.text,
//           'startTime': startTimePicked?.format(context),
//           'endTime': endTimePicked?.format(context),
//           'graceTime': int.tryParse(graceTimeController.text) ?? 0.0,
//           'shiftStatus': shiftStatusEdit,
//         }),
//       );
//
//
//       if (response.statusCode == 200) {
//         Map<String, dynamic> responseData = json.decode(response.body);
//
//         if (responseData['dup'] == true) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(responseData['message'] ?? 'Shift updated successfully')),
//           );
//         } else {
//           fetchShifts();
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(responseData['message'] ?? 'Shift updated successfully')),
//           );
//           Navigator.pop(context);
//         }
//       } else {
//         Map<String, dynamic> responseData = json.decode(response.body);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(responseData['message'] ?? 'Failed to add role')),
//         );
//       }
//     }
//
//     Future<void> selectTime(BuildContext context, bool isStartTime) async {
//       final TimeOfDay? pickedTime = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//       );
//
//       if (pickedTime != null) {
//         setState(() {
//           if (isStartTime) {
//             startTimePicked = pickedTime;
//           } else {
//             endTimePicked = pickedTime;
//           }
//         });
//       }
//     }
//     if (!canUpdate) {
//       showCustomAlertDialog(
//         context,
//         title: 'Permission Denied',
//         content: Text('You do not have permission to edit roles.'), actions: [],
//       );
//       return;
//     }
//     showCustomAlertDialog(
//       context,
//       title: 'Edit Shift',
//       content: SingleChildScrollView(
//         child: Column(
//           children: [
//             TextField(
//               controller: shiftNameController,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'Shift Name',
//               ),
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     startTimePicked != null
//                         ? 'Start Time: ${startTimePicked!.format(context)}'
//                         : 'Select Start Time',
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.access_time),
//                   onPressed: () => selectTime(context, true),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     endTimePicked != null
//                         ? 'End Time: ${endTimePicked!.format(context)}'
//                         : 'Select End Time',
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.access_time),
//                   onPressed: () => selectTime(context, false),
//                 ),
//               ],
//             ),
//             TextField(
//               controller: graceTimeController,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'Grace Time(in min)',
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             SwitchListTile(
//               title: const Text('Shift Status'),
//               value: shiftStatusEdit,
//               onChanged: (bool value) {
//                 setState(() {
//                   shiftStatusEdit = value;
//                 });
//               },
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: updateShift,
//           child: const Text('Update Shift'),
//         ),
//       ],
//     );
//   }
//
//   void showAddShiftDialog() {
//     final TextEditingController shiftNameController = TextEditingController();
//     final TextEditingController graceTimeController = TextEditingController();
//     TimeOfDay? startTime;
//     TimeOfDay? endTime;
//     bool shiftStatus = true;
//
//     Future<void> addShift() async {
//       if (token == null || !canCreate) return;
//
//
//       final response = await http.post(
//         Uri.parse('${Config.apiUrl}UsersShift/AddShift'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode({
//           'shiftName': shiftNameController.text,
//           'startTime': startTime != null ? startTime?.format(context) : '',
//           'endTime': endTime != null ? endTime?.format(context) : '',
//           'graceTime': int.tryParse(graceTimeController.text) ?? 0.0,
//           'shiftStatus': shiftStatus,
//         }),
//       );
//
//
//       if (response.statusCode == 200) {
//         Map<String, dynamic> responseData = json.decode(response.body);
//
//         if (responseData['dup'] == true) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(responseData['message'] ?? 'Shift added successfully')),
//           );
//         } else {
//           fetchShifts();
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(responseData['message'] ?? 'Shift added successfully')),
//           );
//           Navigator.pop(context);
//         }
//       } else {
//         Map<String, dynamic> responseData = json.decode(response.body);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(responseData['message'] ?? 'Failed to add Shift')),
//         );
//       }
//     }
//
//     Future<void> selectTime(BuildContext context, bool isStartTime) async {
//       final TimeOfDay? pickedTime = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//       );
//
//       if (pickedTime != null) {
//         setState(() {
//           if (isStartTime) {
//             startTime = pickedTime;
//           } else {
//             endTime = pickedTime;
//           }
//         });
//       }
//     }
//     if (!canCreate) {
//       showCustomAlertDialog(
//         context,
//         title: 'Permission Denied',
//         content: Text('You do not have permission to add roles.'), actions: [],
//       );
//       return;
//     }
//     showCustomAlertDialog(
//       context,
//       title: 'Add New Shift',
//       content: SingleChildScrollView(
//         child: Column(
//           children: [
//             TextField(
//               controller: shiftNameController,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'Shift Name',
//               ),
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     startTime != null
//                         ? 'Start Time: ${startTime!.format(context)}'
//                         : 'Select Start Time',
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.access_time),
//                   onPressed: () => selectTime(context, true),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     endTime != null
//                         ? 'End Time: ${endTime!.format(context)}'
//                         : 'Select End Time',
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.access_time),
//                   onPressed: () => selectTime(context, false),
//                 ),
//               ],
//             ),
//             TextField(
//               controller: graceTimeController,
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(),
//                 labelText: 'Grace Time(in min)',
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             SwitchListTile(
//               title: const Text('Shift Status'),
//               value: shiftStatus,
//               onChanged: (bool value) {
//                 setState(() {
//                   shiftStatus = value;
//                 });
//               },
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: addShift,
//           child: const Text('Add Shift'),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'User Shift',
//         onLogout: () => AuthService.logout(context),
//
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'User Shifts',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.add, color: Colors.blue, size: 30),
//                     onPressed: showAddShiftDialog,
//                   ),
//                 ],
//               ),
//               FutureBuilder<List<dynamic>>(
//                 future: shiftsFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   }
//
//                   return SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: DataTable(
//                       columns: const [
//                         DataColumn(label: Text('Shift Name')),
//                         DataColumn(label: Text('Start Time')),
//                         DataColumn(label: Text('End Time')),
//                         DataColumn(label: Text('Grace Time')),
//                         DataColumn(label: Text('Status')),
//                         DataColumn(label: Text('Edit')),
//                         DataColumn(label: Text('Delete')),
//                       ],
//                       rows: snapshot.data!.map((shift) {
//                         return DataRow(cells: [
//                           DataCell(Text(shift['shiftName'])),
//                           DataCell(Text(shift['startTime'])),
//                           DataCell(Text(shift['endTime'])),
//                           DataCell(Text(shift['graceTime'].toString())),
//                           DataCell(
//                             Icon(
//                               shift['shiftStatus'] ? Icons.check : Icons.close,
//                               color: shift['shiftStatus']
//                                   ? Colors.green
//                                   : Colors.red,
//                             ),
//                           ),
//                           DataCell(
//                             Row(
//                               children: [
//                                 IconButton(
//                                   icon:
//                                       const Icon(Icons.edit, color: Colors.green),
//                                   onPressed: () => showEditShiftDialog(
//                                     shift['shiftId'],
//                                     shift['shiftName'],
//                                     shift['startTime'],
//                                     shift['endTime'],
//                                     shift['graceTime'],
//                                     shift['shiftStatus'],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           DataCell(
//                             Row(
//                               children: [
//                                 IconButton(
//                                   icon:
//                                       const Icon(Icons.delete, color: Colors.red),
//                                   onPressed: () =>
//                                       confirmDelete(shift['shiftId']),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ]);
//                       }).toList(),
//                     ),
//                   );
//                 },
//               )
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: _currentIndex,
//         context: context,
//         onItemTapped: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import fluttertoast

import 'package:vehiclemanagement/components/widgetmethods/appbar_method.dart';
import '../../config.dart';
import '../widgetmethods/alert_widget.dart';
import '../login/logout _method.dart';
import '../widgetmethods/bottomnavigation_method.dart';

class UsershiftPage extends StatefulWidget {
  const UsershiftPage({super.key});

  @override
  State<UsershiftPage> createState() => _UsershiftPageState();
}

class _UsershiftPageState extends State<UsershiftPage> {
  late Future<List<dynamic>> shiftsFuture;
  List<dynamic> allShifts = [];
  List<dynamic> filteredShifts = [];
  String? token;
  String? permissionType;
  bool canRead = false;
  bool canCreate = false;
  bool canUpdate = false;
  int _currentIndex = 0;
  bool canDelete = false;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getToken().then((_) {
      _getPermissionType().then((_) {
        if (canRead) {
          shiftsFuture = fetchShifts();
        }
      });
    });

    searchController.addListener(() {
      filterShifts(searchController.text);
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
        showCustomAlertDialog(context, title: 'Permission Error', content: Text('Permission Type is not found .'), actions: []);
        return;
      }

      canRead = permissionType!.toString().contains('R');
      canCreate = permissionType!.toString().contains('C');
      canUpdate = permissionType!.toString().contains('U');
      canDelete = permissionType!.toString().contains('D');
    });
  }

  Future<List<dynamic>> fetchShifts() async {
    if (token == null || !canRead) {
      throw Exception('error');
    }

    final response = await http.get(
      Uri.parse('${Config.apiUrl}UsersShift/GetAllShifts'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      allShifts = List.from(data['apiResponse']);
      filteredShifts = List.from(allShifts);
      return filteredShifts;
    } else {
      throw Exception('Failed to load shifts');
    }
  }

  void filterShifts(String query) {
    setState(() {
      filteredShifts = allShifts
          .where((shift) =>
          shift['shiftName'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> deleteShift(int shiftId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.delete(
      Uri.parse('${Config.apiUrl}UsersShift/deleteShift/$shiftId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      Map<String, dynamic> responseData = json.decode(response.body);

      Fluttertoast.showToast(
        msg: responseData['message'] ?? 'UserShift deleted successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      setState(() {
        shiftsFuture = fetchShifts();
      });
    } else {
      Navigator.of(context).pop();
      Map<String, dynamic> responseData = json.decode(response.body);

      Fluttertoast.showToast(
        msg: responseData['message'] ?? 'Failed',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void confirmDelete(int shiftId) {
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
      content: const Text('Are you sure you want to delete this shift?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            deleteShift(shiftId);
          },
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  void showEditShiftDialog(int shiftId, String shiftName, String startTime,
      String endTime, int graceTime, bool shiftStatus) {
    final TextEditingController shiftNameController =
    TextEditingController(text: shiftName);
    final TextEditingController graceTimeController =
    TextEditingController(text: graceTime.toString());
    TimeOfDay? startTimePicked = TimeOfDay(
        hour: int.parse(startTime.split(":")[0]),
        minute: int.parse(startTime.split(":")[1]));
    TimeOfDay? endTimePicked = TimeOfDay(
        hour: int.parse(endTime.split(":")[0]),
        minute: int.parse(endTime.split(":")[1]));
    bool shiftStatusEdit = shiftStatus;

    Future<void> updateShift() async {
      if (token == null || !canUpdate) return;

      final response = await http.put(
        Uri.parse('${Config.apiUrl}UsersShift/updateShift/$shiftId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'shiftName': shiftNameController.text,
          'startTime': startTimePicked?.format(context),
          'endTime': endTimePicked?.format(context),
          'graceTime': int.tryParse(graceTimeController.text) ?? 0.0,
          'shiftStatus': shiftStatusEdit,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['dup'] == true) {
          Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Shift updated successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          fetchShifts();
          Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Shift updated successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          Navigator.pop(context);
        }
      } else {
        Map<String, dynamic> responseData = json.decode(response.body);
        Fluttertoast.showToast(
          msg: responseData['message'] ?? 'Failed to update shift',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }

    Future<void> selectTime(BuildContext context, bool isStartTime) async {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          if (isStartTime) {
            startTimePicked = pickedTime;
          } else {
            endTimePicked = pickedTime;
          }
        });
      }
    }
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
      title: 'Edit Shift',
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: shiftNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Shift Name',
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    startTimePicked != null
                        ? 'Start Time: ${startTimePicked!.format(context)}'
                        : 'Select Start Time',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () => selectTime(context, true),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    endTimePicked != null
                        ? 'End Time: ${endTimePicked!.format(context)}'
                        : 'Select End Time',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () => selectTime(context, false),
                ),
              ],
            ),
            TextField(
              controller: graceTimeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Grace Time(in min)',
              ),
              keyboardType: TextInputType.number,
            ),
            SwitchListTile(
              title: const Text('Shift Status'),
              value: shiftStatusEdit,
              onChanged: (bool value) {
                setState(() {
                  shiftStatusEdit = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: updateShift,
          child: const Text('Update Shift'),
        ),
      ],
    );
  }

  void showAddShiftDialog() {
    final TextEditingController shiftNameController = TextEditingController();
    final TextEditingController graceTimeController = TextEditingController();
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    bool shiftStatus = true;

    Future<void> addShift() async {
      if (token == null || !canCreate) return;

      final response = await http.post(
        Uri.parse('${Config.apiUrl}UsersShift/AddShift'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'shiftName': shiftNameController.text,
          'startTime': startTime != null ? startTime?.format(context) : '',
          'endTime': endTime != null ? endTime?.format(context) : '',
          'graceTime': int.tryParse(graceTimeController.text) ?? 0.0,
          'shiftStatus': shiftStatus,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['dup'] == true) {
          Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Shift added successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          fetchShifts();
          Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Shift added successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          Navigator.pop(context);
        }
      } else {
        Map<String, dynamic> responseData = json.decode(response.body);
        Fluttertoast.showToast(
          msg: responseData['message'] ?? 'Failed to add Shift',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    }

    Future<void> selectTime(BuildContext context, bool isStartTime) async {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          if (isStartTime) {
            startTime = pickedTime;
          } else {
            endTime = pickedTime;
          }
        });
      }
    }
    if (!canCreate) {
      showCustomAlertDialog(
        context,
        title: 'Permission Denied',
        content: Text('You do not have permission to add roles.'), actions: [],
      );
      return;
    }
    showCustomAlertDialog(
      context,
      title: 'Add New Shift',
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: shiftNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Shift Name',
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    startTime != null
                        ? 'Start Time: ${startTime!.format(context)}'
                        : 'Select Start Time',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () => selectTime(context, true),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    endTime != null
                        ? 'End Time: ${endTime!.format(context)}'
                        : 'Select End Time',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () => selectTime(context, false),
                ),
              ],
            ),
            TextField(
              controller: graceTimeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Grace Time(in min)',
              ),
              keyboardType: TextInputType.number,
            ),
            SwitchListTile(
              title: const Text('Shift Status'),
              value: shiftStatus,
              onChanged: (bool value) {
                setState(() {
                  shiftStatus = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: addShift,
          child: const Text('Add Shift'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'User Shift',
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
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search by Shift Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.blue, size: 30),
                    onPressed: showAddShiftDialog,
                  ),

                ],
              ),

              const SizedBox(height: 10),
              FutureBuilder<List<dynamic>>(
                future: shiftsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  List<dynamic> displayedShifts = filteredShifts.isNotEmpty
                      ? filteredShifts
                      : snapshot.data!;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Shift Name')),
                        DataColumn(label: Text('Start Time')),
                        DataColumn(label: Text('End Time')),
                        DataColumn(label: Text('Grace Time')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Edit')),
                        DataColumn(label: Text('Delete')),
                      ],
                      rows: displayedShifts.map((shift) {
                        return DataRow(cells: [
                          DataCell(Text(shift['shiftName'])),
                          DataCell(Text(shift['startTime'])),
                          DataCell(Text(shift['endTime'])),
                          DataCell(Text(shift['graceTime'].toString())),
                          DataCell(
                            Icon(
                              shift['shiftStatus'] ? Icons.check : Icons.close,
                              color: shift['shiftStatus']
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.green),
                                  onPressed: () => showEditShiftDialog(
                                    shift['shiftId'],
                                    shift['shiftName'],
                                    shift['startTime'],
                                    shift['endTime'],
                                    shift['graceTime'],
                                    shift['shiftStatus'],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => confirmDelete(shift['shiftId']),
                                ),
                              ],
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
