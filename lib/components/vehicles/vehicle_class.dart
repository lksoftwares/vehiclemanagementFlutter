


class VVehicle {
  final String ownerName;
final String contactNumber;
final String vehicleNo;
  VVehicle({required this.ownerName, required this.contactNumber, required this.vehicleNo});

  factory VVehicle.fromJson(Map<String, dynamic> json) {
    return VVehicle(
      ownerName: json['ownerName'],
        contactNumber: json['contactNumber'].toString(),
        vehicleNo: json['vehicleNo'].toString()


    );
  }
}

abstract class VehicleEvent{}

class LoadVehicles extends VehicleEvent{}
class AddVehicle extends VehicleEvent {
  final VVehicle vehicle;
  AddVehicle(this.vehicle);
}

class UpdateVehicle extends VehicleEvent {
  final VVehicle vehicle;

  UpdateVehicle(this.vehicle);
}

class DeleteVehicle extends VehicleEvent {
  final VVehicle vehicle;

  DeleteVehicle(this.vehicle);
}

abstract class VehicleState{}
class VehicleFetch extends VehicleState{
  final List<VVehicle> Vehicles;
  VehicleFetch(this.Vehicles);}

class VehicleLoading extends VehicleState{}
class VehicleInitial extends VehicleState {}
class VehicleAdded extends  VehicleState {}
class VehicleUpdated extends VehicleState{}
class VehicleDeleted extends VehicleState{}