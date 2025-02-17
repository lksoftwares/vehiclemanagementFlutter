import 'package:equatable/equatable.dart';
 class Permission{
  final int permissionId;
  final String permissionType;

  Permission({required this.permissionId, required this.permissionType});

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      permissionId: json['PermissionId'],
      permissionType: json['PermissionType'],
    );
  }

}

abstract class PermissionEvent {}

class LoadPermissions extends PermissionEvent {}
class AddPermission extends PermissionEvent {
  // final String permissionType;
  // AddPermission(this.permissionType);
  final Permission permission;
  AddPermission(this.permission);
}

class UpdatePermission extends PermissionEvent {
  // final int permissionId;
  // final String permissionType;
  // UpdatePermission(this.permissionId, this.permissionType);
  final Permission permission;
  UpdatePermission(this.permission);
}

class DeletePermission extends PermissionEvent {
  // final int permissionId;
  // DeletePermission(this.permissionId);
  final Permission permission;
  DeletePermission(this.permission);
}


abstract class PermissionState {}

class PermissionInitial extends PermissionState {}

class PermissionsLoading extends PermissionState {}

class PermissionsLoaded extends PermissionState {
  final List<Permission> permissions;
  PermissionsLoaded(this.permissions);
}

class PermissionsError extends PermissionState {
  final String message;
  PermissionsError(this.message);
}

class PermissionAdded extends PermissionState {}

class PermissionUpdated extends PermissionState {}

class PermissionDeleted extends PermissionState {}

