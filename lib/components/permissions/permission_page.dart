// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vehiclemanagement/components/widgetmethods/appbar_method.dart';
// import '../../config.dart';
// import '../login/logout _method.dart';
// import '../widgetmethods/alert_widget.dart';
// import '../widgetmethods/bottomnavigation_method.dart';
// import '../widgetmethods/no_data_found.dart';
// import '../widgetmethods/toast_method.dart';
//
// class PermissionPage extends StatefulWidget {
//   const PermissionPage({super.key});
//
//   @override
//   State<PermissionPage> createState() => _PermissionPageState();
// }
//
// class _PermissionPageState extends State<PermissionPage> {
//   late Future<List<Permission>> permissions;
//   String? token;
//   String? permissionType;
//   bool canRead = false;
//   bool canCreate = false;
//   bool canUpdate = false;
//   bool canDelete = false;
//   int _currentIndex = 0;
//   TextEditingController _searchController = TextEditingController();
//   String _searchQuery = "";
//
//
//   @override
//   void initState() {
//     super.initState();
//     _getToken().then((_) {
//       _getPermissionType().then((_) {
//         if (canRead) {
//           permissions = fetchPermissions();
//         }
//       });
//     });
//
//     _searchController.addListener(() {
//       setState(() {
//         _searchQuery = _searchController.text.trim().toLowerCase();
//       });
//     });
//   }
//
//   Future<void> _getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       token = prefs.getString('token');
//     });
//   }
//
//   Future<void> _getPermissionType() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       permissionType = prefs.getString('selected_permission_type');
//
//       if (permissionType == null) {
//         showCustomAlertDialog(
//           context,
//           title: 'Permission Error',
//           content: Text('Permission Type is not found.'),
//           actions: [],
//         );
//         return;
//       }
//
//       canCreate = permissionType!.toString().contains('C');
//       canRead = permissionType!.toString().contains('R');
//       canUpdate = permissionType!.toString().contains('U');
//       canDelete = permissionType!.toString().contains('D');
//     });
//   }
//
//   Future<List<Permission>> fetchPermissions() async {
//     if (token == null || !canRead) {
//       throw Exception('Error');
//     }
//
//     final url = Uri.parse("${Config.apiUrl}Permission/GetAllPermission");
//
//     final response = await http.get(
//       url,
//       headers: {
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final responseData = json.decode(response.body);
//       final List<dynamic> data = responseData['apiResponse'];
//
//       return data.map((item) => Permission.fromJson(item)).toList();
//
//     } else {
//       throw Exception('Failed to load permissions');
//     }
//   }
//
//   Future<void> addPermission(String permissionType) async {
//     if (token == null || !canCreate) return;
//
//     final url = Uri.parse("${Config.apiUrl}Permission/AddPermission");
//
//     final response = await http.post(
//       url,
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//       body: json.encode({
//         "PermissionType": permissionType.trim(),
//       }),
//     );
//
//     final responseData = json.decode(response.body);
//     final bool isDuplicate = responseData['dup'] ?? false;
//     final String message = responseData['message'] ?? 'Unexpected error';
//
//     if (response.statusCode == 200 && !isDuplicate) {
//       setState(() {
//         permissions = fetchPermissions();
//       });
//       Navigator.of(context).pop();
//       showToast(
//         msg: message,
//         backgroundColor: Colors.green,
//       );
//     } else {
//       showToast(
//         msg: message,
//       );
//     }
//   }
//
//   void showAddPermissionDialog() {
//     final TextEditingController _controller = TextEditingController();
//     if (!canCreate) {
//       showCustomAlertDialog(
//         context,
//         title: 'Permission Denied',
//         content: Text('You do not have permission to add roles.'),
//         actions: [],
//       );
//       return;
//     }
//     showCustomAlertDialog(
//       context,
//       title: 'Add Permission',
//       content: TextField(
//         controller: _controller,
//         decoration: InputDecoration(
//           border: OutlineInputBorder(),
//           labelText: 'Permission Type',
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             if (_controller.text.trim().isNotEmpty) {
//               addPermission(_controller.text.trim());
//             } else {
//               showToast(
//                 msg: 'Please fill all fields',
//               );
//             }
//           },
//           child: const Text('Add'),
//         ),
//       ],
//     );
//   }
//
//   Future<void> updatePermission(int permissionId, String permissionType) async {
//     if (token == null || !canCreate) return;
//
//     final url = Uri.parse("${Config.apiUrl}Permission/updatePermission/$permissionId");
//
//     final response = await http.put(
//       url,
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//       body: json.encode({
//         "PermissionType": permissionType.trim(),
//       }),
//     );
//
//     final responseData = json.decode(response.body);
//     final String message = responseData['message'] ?? 'Update failed';
//
//     if (response.statusCode == 200) {
//       setState(() {
//         permissions = fetchPermissions();
//       });
//       Navigator.of(context).pop();
//       showToast(
//         msg: message,
//         backgroundColor: Colors.green,
//       );    } else {
//       showToast(
//         msg: message,
//       );    }
//   }
//
//   void showEditPermissionDialog(Permission permission) {
//     final TextEditingController _controller = TextEditingController(text: permission.permissionType);
//     if (!canUpdate) {
//       showCustomAlertDialog(
//         context,
//         title: 'Permission Denied',
//         content: Text('You do not have permission to edit roles.'),
//         actions: [],
//       );
//       return;
//     }
//     showCustomAlertDialog(
//       context,
//       title: 'Edit Permission Type',
//       content: TextField(
//         controller: _controller,
//         decoration: InputDecoration(
//           border: OutlineInputBorder(),
//           labelText: 'Permission Type',
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             if (_controller.text.trim().isNotEmpty) {
//               updatePermission(permission.permissionId, _controller.text.trim());
//             } else {
//               showToast(
//                 msg: 'Please fill all fields',
//               );
//             }
//           },
//           child: const Text('Update'),
//         ),
//       ],
//     );
//   }
//
//   Future<void> deletePermission(int permissionId) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');
//
//     final url = Uri.parse("${Config.apiUrl}Permission/deletePermission/$permissionId");
//
//     final response = await http.delete(
//       url,
//       headers: {
//         'Authorization': 'Bearer $token',
//       },
//     );
//     final responseData = json.decode(response.body);
//     final String message = responseData['message'] ?? 'delete failed';
//     if (response.statusCode == 200) {
//       setState(() {
//         permissions = fetchPermissions();
//       });
//       showToast(
//         msg: message,
//         backgroundColor: Colors.green,
//       );
//     } else {
//       showToast(
//         msg: message,
//       );
//     }
//   }
//
//   void showDeleteConfirmationDialog(Permission permission) {
//     if (!canDelete) {
//       showCustomAlertDialog(
//         context,
//         title: 'Permission Denied',
//         content: Text('You do not have permission to delete roles.'),
//         actions: [],
//       );
//       return;
//     }
//     showCustomAlertDialog(
//       context,
//       title: 'Delete Permission',
//       content: const Text('Are you sure you want to delete this permission?'),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//             deletePermission(permission.permissionId);
//           },
//           child: const Text('Yes'),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'Permissions',
//         onLogout: () => AuthService.logout(context),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     width: 280,
//                     child: TextField(
//                       controller: _searchController,
//                       decoration: InputDecoration(
//                         labelText: 'Search Permission Type',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.add, color: Colors.blue, size: 30),
//                     onPressed: showAddPermissionDialog,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               FutureBuilder<List<Permission>>(
//                 future: permissions,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return const Center(child: Text('No permissions found.'));
//                   } else {
//                     final permissionList = snapshot.data!;
//
//                     final filteredPermissions = permissionList
//                         .where((permission) => permission.permissionType
//                         .toLowerCase()
//                         .contains(_searchQuery))
//                         .toList();
//
//                     if (filteredPermissions.isEmpty) {
//                       return NoDataFoundScreen();
//                     }
//
//                     return Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         children: [
//                           Container(
//                             color: Colors.blueAccent,
//                             child: Row(
//                               children: const [
//                                 Expanded(
//                                   child: Padding(
//                                     padding: EdgeInsets.all(8.0),
//                                     child: Text('Permission', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: Colors.white
//                                     )),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Padding(
//                                     padding: EdgeInsets.all(8.0),
//                                     child: Text('Edit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: Colors.white)),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Padding(
//                                     padding: EdgeInsets.all(8.0),
//                                     child: Text('Delete', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,color: Colors.white)),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Container(
//                             height: 470,
//                             child: SingleChildScrollView(
//
//                               child: Column(
//                                 children: filteredPermissions.map((permission) {
//                                   return Container(
//                                     color: Colors.white,
//                                     child: Row(
//                                       children: [
//                                         Expanded(
//                                           child: Padding(
//                                             padding: const EdgeInsets.all(8.0),
//                                             child: Text(permission.permissionType),
//                                           ),
//                                         ),
//                                         Expanded(
//                                           child: IconButton(
//                                             icon: const Icon(Icons.edit, color: Colors.green),
//                                             onPressed: () => showEditPermissionDialog(permission),
//                                           ),
//                                         ),
//                                         Expanded(
//                                           child: IconButton(
//                                             icon: const Icon(Icons.delete, color: Colors.red),
//                                             onPressed: () => showDeleteConfirmationDialog(permission),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 }).toList(),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//                 },
//               ),
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
//
// class Permission {
//   final int permissionId;
//   final String permissionType;
//
//   Permission({required this.permissionId, required this.permissionType});
//
//   factory Permission.fromJson(Map<String, dynamic> json) {
//     return Permission(
//       permissionId: json['PermissionId'],
//       permissionType: json['PermissionType'],
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:vehiclemanagement/components/permissions/permission_class.dart';
// import 'package:vehiclemanagement/components/widgetmethods/appbar_method.dart';
// import '../login/logout _method.dart';
// import '../widgetmethods/alert_widget.dart';
// import '../widgetmethods/bottomnavigation_method.dart';
// import '../widgetmethods/no_data_found.dart';
// import '../widgetmethods/toast_method.dart';
// import 'permission_bloc.dart';
//
// class PermissionPage extends StatefulWidget {
//   const PermissionPage({super.key});
//
//   @override
//   State<PermissionPage> createState() => _PermissionPageState();
// }
//
// class _PermissionPageState extends State<PermissionPage> {
//   TextEditingController _searchController = TextEditingController();
//   String _searchQuery = "";
//
//   @override
//   void initState() {
//     super.initState();
//     context.read<PermissionBloc>().add(LoadPermissions());
//
//     _searchController.addListener(() {
//       setState(() {
//         _searchQuery = _searchController.text.trim().toLowerCase();
//       });
//     });
//   }
//
//   void showAddPermissionDialog() {
//     final TextEditingController _controller = TextEditingController();
//     showCustomAlertDialog(
//       context,
//       title: 'Add Permission',
//       content: TextField(
//         controller: _controller,
//         decoration: InputDecoration(
//           border: OutlineInputBorder(),
//           labelText: 'Permission Type',
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             if (_controller.text.trim().isNotEmpty) {
//               Permission newPermission = Permission(
//                 permissionId: 0,
//                 permissionType: _controller.text.trim(),
//               );
//               context.read<PermissionBloc>().add(AddPermission(newPermission));
//               Navigator.of(context).pop();
//             } else {
//               showToast(msg: 'Please fill all fields');
//             }
//           },
//           child: const Text('Add'),
//         ),
//       ],
//     );
//   }
//
//   void showEditPermissionDialog(Permission permission) {
//     final TextEditingController _controller = TextEditingController(text: permission.permissionType);
//
//     showCustomAlertDialog(
//       context,
//       title: 'Edit Permission Type',
//       content: TextField(
//         controller: _controller,
//         decoration: InputDecoration(
//           border: OutlineInputBorder(),
//           labelText: 'Permission Type',
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             if (_controller.text.trim().isNotEmpty) {
//               Permission updatedPermission = Permission(
//                 permissionId: permission.permissionId,
//                 permissionType: _controller.text.trim(),
//               );
//               context.read<PermissionBloc>().add(UpdatePermission(updatedPermission));
//               Navigator.of(context).pop();
//             } else {
//               showToast(msg: 'Please fill all fields');
//             }
//           },
//           child: const Text('Update'),
//         ),
//       ],
//     );
//   }
//
//   void showDeleteConfirmationDialog(Permission permission) {
//     showCustomAlertDialog(
//       context,
//       title: 'Delete Permission',
//       content: const Text('Are you sure you want to delete this permission?'),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.of(context).pop(),
//           child: const Text('Cancel'),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//             context.read<PermissionBloc>().add(DeletePermission(permission));
//           },
//           child: const Text('Yes'),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         title: 'Permissions',
//         onLogout: () => AuthService.logout(context),
//       ),
//       body: BlocBuilder<PermissionBloc, PermissionState>(
//         builder: (context, state) {
//           if (state is PermissionsLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is PermissionsError) {
//             return Center(child: Text('Error: ${state.message}'));
//           } else if (state is PermissionsLoaded) {
//             final permissionList = state.permissions;
//
//             final filteredPermissions = permissionList
//                 .where((permission) => permission.permissionType.toLowerCase().contains(_searchQuery))
//                 .toList();
//
//             if (filteredPermissions.isEmpty) {
//               return NoDataFoundScreen();
//             }
//
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Container(
//                         width: 280,
//                         child: TextField(
//                           controller: _searchController,
//                           decoration: InputDecoration(
//                             labelText: 'Search Permission Type',
//                             border: OutlineInputBorder(),
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.add, color: Colors.blue, size: 30),
//                         onPressed: showAddPermissionDialog,
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   // Display Permissions List
//                   Container(
//                     color: Colors.blueAccent,
//                     child: Row(
//                       children: const [
//                         Expanded(
//                           child: Padding(
//                             padding: EdgeInsets.all(8.0),
//                             child: Text('Permission', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
//                           ),
//                         ),
//                         Expanded(
//                           child: Padding(
//                             padding: EdgeInsets.all(8.0),
//                             child: Text('Edit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
//                           ),
//                         ),
//                         Expanded(
//                           child: Padding(
//                             padding: EdgeInsets.all(8.0),
//                             child: Text('Delete', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     height: 470,
//                     child: SingleChildScrollView(
//                       child: Column(
//                         children: filteredPermissions.map((permission) {
//                           return Container(
//                             color: Colors.white,
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Text(permission.permissionType),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: IconButton(
//                                     icon: const Icon(Icons.edit, color: Colors.green),
//                                     onPressed: () => showEditPermissionDialog(permission),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: IconButton(
//                                     icon: const Icon(Icons.delete, color: Colors.red),
//                                     onPressed: () {
//                                       showDeleteConfirmationDialog(permission);
//                                     }
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           return Container();
//         },
//       ),
//       bottomNavigationBar: BottomNavBar(
//         currentIndex: 0,
//         context: context,
//         onItemTapped: (index) {},
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vehiclemanagement/components/permissions/permission_class.dart';
import 'package:vehiclemanagement/components/widgetmethods/appbar_method.dart';
import '../login/logout _method.dart';
import '../widgetmethods/alert_widget.dart';
import '../widgetmethods/bottomnavigation_method.dart';
import '../widgetmethods/no_data_found.dart';
import '../widgetmethods/toast_method.dart';
import 'permission_bloc.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    context.read<PermissionBloc>().add(LoadPermissions());

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  void showAddPermissionDialog() {
    final TextEditingController _controller = TextEditingController();
    showCustomAlertDialog(
      context,
      title: 'Add Permission',
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Permission Type',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              Permission newPermission = Permission(
                permissionId: 0,
                permissionType: _controller.text.trim(),
              );
              context.read<PermissionBloc>().add(AddPermission(newPermission));
              Navigator.of(context).pop();
            } else {
              showToast(msg: 'Please fill all fields');
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  void showEditPermissionDialog(Permission permission) {
    final TextEditingController _controller = TextEditingController(text: permission.permissionType);

    showCustomAlertDialog(
      context,
      title: 'Edit Permission Type',
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Permission Type',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              Permission updatedPermission = Permission(
                permissionId: permission.permissionId,
                permissionType: _controller.text.trim(),
              );
              context.read<PermissionBloc>().add(UpdatePermission(updatedPermission));
              Navigator.of(context).pop();
            } else {
              showToast(msg: 'Please fill all fields');
            }
          },
          child: const Text('Update'),
        ),
      ],
    );
  }

  void showDeleteConfirmationDialog(Permission permission) {
    showCustomAlertDialog(
      context,
      title: 'Delete Permission',
      content: const Text('Are you sure you want to delete this permission?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            context.read<PermissionBloc>().add(DeletePermission(permission));
          },
          child: const Text('Yes'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Permissions',
        onLogout: () => AuthService.logout(context),
      ),
      body: BlocBuilder<PermissionBloc, PermissionState>(
        builder: (context, state) {
          if (state is PermissionsLoading) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: ListView.builder(
                itemCount: 11,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 40,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            );
          } else if (state is PermissionsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is PermissionsLoaded) {
            final permissionList = state.permissions;

            final filteredPermissions = permissionList
                .where((permission) => permission.permissionType.toLowerCase().contains(_searchQuery))
                .toList();

            if (filteredPermissions.isEmpty) {
              return NoDataFoundScreen();
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 280,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Search Permission Type',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.blue, size: 30),
                        onPressed: showAddPermissionDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Display Permissions List
                  Container(
                    color: Colors.blueAccent,
                    child: Row(
                      children: const [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Permission', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Edit', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Delete', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 470,
                    child: SingleChildScrollView(
                      child: Column(
                        children: filteredPermissions.map((permission) {
                          return Container(
                            color: Colors.white,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(permission.permissionType),
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.green),
                                    onPressed: () => showEditPermissionDialog(permission),
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        showDeleteConfirmationDialog(permission);
                                      }
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Container();
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        context: context,
        onItemTapped: (index) {},
      ),
    );
  }
}
