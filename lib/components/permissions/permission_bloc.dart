//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vehiclemanagement/components/permissions/permission_class.dart';
//
// import '../../config.dart';
// import '../widgetmethods/toast_method.dart';
//
// class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
//   PermissionBloc() : super(PermissionInitial()) {
//     on<LoadPermissions>((event, emit) => _mapLoadPermissionsToState(emit));
//     on<AddPermission>((event, emit) => _mapAddPermissionToState(event.permissionType, emit));
//     on<UpdatePermission>((event, emit) => _mapUpdatePermissionToState(event.permissionId, event.permissionType, emit));
//     on<DeletePermission>((event, emit) => _mapDeletePermissionToState(event.permissionId, emit));
//   }
//
//   Future<String> _getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token') ?? '';
//   }
//
//   Future<void> _mapLoadPermissionsToState(Emitter<PermissionState> emit) async {
//     emit(PermissionsLoading());
//
//     try {
//       final token = await _getToken();
//       final url = Uri.parse("${Config.apiUrl}Permission/GetAllPermission");
//
//       final response = await http.get(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         final List<dynamic> data = responseData['apiResponse'];
//
//         final permissions = data.map((item) => Permission.fromJson(item)).toList();
//         emit(PermissionsLoaded(permissions));
//       } else {
//         final responseData = json.decode(response.body);
//         String errorMessage = responseData['message'] ?? 'Failed to load permissions';
//         showToast(msg: errorMessage);
//         emit(PermissionsError(errorMessage));
//       }
//     } catch (e) {
//       showToast(msg: 'An error occurred while loading permissions');
//       emit(PermissionsError('An error occurred'));
//     }
//   }
//
//   Future<void> _mapAddPermissionToState(String permissionType, Emitter<PermissionState> emit) async {
//     try {
//       final token = await _getToken();
//       final url = Uri.parse("${Config.apiUrl}Permission/AddPermission");
//
//       final response = await http.post(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           "PermissionType": permissionType.trim(),
//         }),
//       );
//
//       final responseData = json.decode(response.body);
//       if (response.statusCode == 200) {
//         String sucessMessage = responseData['message'] ?? 'permission added successfully';
//         showToast(msg: sucessMessage, backgroundColor: Colors.green);
//         emit(PermissionAdded());
//         add(LoadPermissions());
//       } else {
//         String errorMessage = responseData['message'] ?? 'Failed to add permission';
//         showToast(msg: errorMessage);
//         emit(PermissionsError(errorMessage));
//       }
//     } catch (e) {
//       showToast(msg: 'An error occurred while adding the permission');
//       emit(PermissionsError('An error occurred while adding the permission'));
//     }
//   }
//
//   Future<void> _mapUpdatePermissionToState(int permissionId, String permissionType, Emitter<PermissionState> emit) async {
//     try {
//       final token = await _getToken();
//       final url = Uri.parse("${Config.apiUrl}Permission/updatePermission/$permissionId");
//
//       final response = await http.put(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//         body: json.encode({
//           "PermissionType": permissionType.trim(),
//         }),
//       );
//
//       final responseData = json.decode(response.body);
//       if (response.statusCode == 200) {
//         String sucessMessage = responseData['message'] ?? 'permission updated successfully';
//         showToast(msg: sucessMessage, backgroundColor: Colors.green);
//         emit(PermissionUpdated());
//         add(LoadPermissions());
//       } else {
//         String errorMessage = responseData['message'] ?? 'Failed to update permission';
//         showToast(msg: errorMessage);
//         emit(PermissionsError(errorMessage));
//       }
//     } catch (e) {
//       showToast(msg: 'An error occurred while updating the permission');
//       emit(PermissionsError('An error occurred while updating the permission'));
//     }
//   }
//
//   Future<void> _mapDeletePermissionToState(int permissionId, Emitter<PermissionState> emit) async {
//     try {
//       final token = await _getToken();
//       final url = Uri.parse("${Config.apiUrl}Permission/deletePermission/$permissionId");
//
//       final response = await http.delete(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       final responseData = json.decode(response.body);
//       if (response.statusCode == 200) {
//         String sucessMessage = responseData['message'] ?? 'permission deleted successfully';
//
//         showToast(msg: sucessMessage, backgroundColor: Colors.green);
//         emit(PermissionDeleted());
//         add(LoadPermissions());
//       } else {
//         String errorMessage = responseData['message'] ?? 'Failed to delete permission';
//         showToast(msg: errorMessage);
//         emit(PermissionsError(errorMessage));
//       }
//     } catch (e) {
//       showToast(msg: 'An error occurred while deleting the permission');
//       emit(PermissionsError('An error occurred while deleting the permission'));
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehiclemanagement/components/permissions/permission_class.dart';

import '../../config.dart';
import '../widgetmethods/toast_method.dart';

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  PermissionBloc() : super(PermissionInitial()) {
    on<LoadPermissions>((event, emit) => _mapLoadPermissionsToState(emit));
    on<AddPermission>((event, emit) => _mapAddPermissionToState(event.permission.permissionType, emit));
    on<UpdatePermission>((event, emit) => _mapUpdatePermissionToState(event.permission.permissionId, event.permission.permissionType, emit));
    on<DeletePermission>((event, emit) => _mapDeletePermissionToState(event.permission.permissionId, emit));
  }

  Future<String> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<void> _mapLoadPermissionsToState(Emitter<PermissionState> emit) async {
    emit(PermissionsLoading());

    try {
      final token = await _getToken();
      final url = Uri.parse("${Config.apiUrl}Permission/GetAllPermission");

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['apiResponse'];

        final permissions = data.map((item) => Permission.fromJson(item)).toList();
        emit(PermissionsLoaded(permissions));
      } else {
        final responseData = json.decode(response.body);
        String errorMessage = responseData['message'] ?? 'Failed to load permissions';
        showToast(msg: errorMessage);
        emit(PermissionsError(errorMessage));
      }
    } catch (e) {
      showToast(msg: 'An error occurred while loading permissions');
      emit(PermissionsError('An error occurred'));
    }
  }

  Future<void> _mapAddPermissionToState(String permissionType, Emitter<PermissionState> emit) async {
    try {
      final token = await _getToken();
      final url = Uri.parse("${Config.apiUrl}Permission/AddPermission");

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "PermissionType": permissionType.trim(),
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        String successMessage = responseData['message'] ?? 'Permission added successfully';
        showToast(msg: successMessage, backgroundColor: Colors.green);
        emit(PermissionAdded());
        add(LoadPermissions());
      } else {
        String errorMessage = responseData['message'] ?? 'Failed to add permission';
        if (responseData['dup'] == true) {
          showToast(msg: 'Error: ${responseData['message']}');
        } else {
          showToast(msg: errorMessage);
        }

      }
    } catch (e) {
      showToast(msg: 'An error occurred while adding the permission');
    }
  }

  Future<void> _mapUpdatePermissionToState(int permissionId, String permissionType, Emitter<PermissionState> emit) async {
    try {
      final token = await _getToken();
      final url = Uri.parse("${Config.apiUrl}Permission/updatePermission/$permissionId");

      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "PermissionType": permissionType.trim(),
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        String successMessage = responseData['message'] ?? 'Permission updated successfully';
        showToast(msg: successMessage, backgroundColor: Colors.green);
        emit(PermissionUpdated());
        add(LoadPermissions());
      } else {
        String errorMessage = responseData['message'] ?? 'Failed to update permission';

        if (responseData['dup'] == true) {
          showToast(msg: 'Error: ${responseData['message']}');
        } else {
          showToast(msg: errorMessage);
        }

      }
    } catch (e) {
      showToast(msg: 'An error occurred while updating the permission');
    }
  }

  Future<void> _mapDeletePermissionToState(int permissionId, Emitter<PermissionState> emit) async {
    try {
      final token = await _getToken();
      final url = Uri.parse("${Config.apiUrl}Permission/deletePermission/$permissionId");

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        String successMessage = responseData['message'] ?? 'Permission deleted successfully';
        showToast(msg: successMessage, backgroundColor: Colors.green);
        emit(PermissionDeleted());
        add(LoadPermissions());
      } else {
        String errorMessage = responseData['message'] ?? 'Failed to delete permission';
        if (responseData['dup'] == true) {
          showToast(msg: 'Error: ${responseData['message']}');
        } else {
          showToast(msg: errorMessage);
        }

      }
    } catch (e) {
      showToast(msg: 'An error occurred while deleting the permission');
    }
  }
}
