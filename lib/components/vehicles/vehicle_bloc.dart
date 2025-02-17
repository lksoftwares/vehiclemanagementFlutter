import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../config.dart';
import 'vehicle_class.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  VehicleBloc() : super(VehicleInitial()) {
    on<LoadVehicles>((event, emit) async {
      await VehicleLoadState(emit);
    });
  }
}

Future<void> VehicleLoadState(Emitter<VehicleState> emit) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    if (token == null) {
      throw Exception('Error: Token is missing');
    }

    final response = await http.get(
      Uri.parse('${Config.apiUrl}Vehicle/GetAllVehicle'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final List<dynamic> data = responseData['apiResponse'];
      final vehicleList = data.map((item) => VVehicle.fromJson(item)).toList();
      emit(VehicleFetch(vehicleList));
    } else {
      print('Error: ${response.statusCode}');
      throw Exception('Failed to load vehicles');
    }

  } catch (e) {
    print(e);
  }
}
