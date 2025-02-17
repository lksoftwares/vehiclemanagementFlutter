import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vehiclemanagement/components/vehicles/vehicle_bloc.dart';
import 'package:vehiclemanagement/components/vehicles/vehicle_class.dart';

class VehicleNewpage extends StatefulWidget {
  const VehicleNewpage({super.key});

  @override
  State<VehicleNewpage> createState() => _VehicleNewpageState();
}

class _VehicleNewpageState extends State<VehicleNewpage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<VehicleBloc>(context).add(LoadVehicles());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vehicles"),
      ),
      body: BlocBuilder<VehicleBloc, VehicleState>(
        builder: (context, state) {
          if (state is VehicleLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is VehicleFetch) {
            final vehicleList = state.Vehicles;

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    color: Colors.blueAccent,
                    child: Row(
                      children: const [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Vehicle No', style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('contact No', style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('vehicle No', style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: vehicleList.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicleList[index];
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(child: Text(vehicle.ownerName)),
                                Expanded(child: Text(vehicle.contactNumber)),
                                Expanded(child: Text(vehicle.vehicleNo)),

                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return Center(child: Text('No Vehicles Found.'));
        },
      ),
    );
  }
}
