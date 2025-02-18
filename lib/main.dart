

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vehiclemanagement/components/splash_screen/splash_screen.dart';
import 'package:vehiclemanagement/components/widgetmethods/shimmer.dart';

class LocationService {
  Future<LocationPermission> _checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  Future<Position> getCurrentLocation() async {
    LocationPermission permissionStatus = await _checkAndRequestPermission();

    if (permissionStatus == LocationPermission.whileInUse ||
        permissionStatus == LocationPermission.always) {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } else {
      throw Exception('Location permission is denied');
    }
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    try {
      LocationPermission permissionStatus = await _locationService._checkAndRequestPermission();
      if (permissionStatus == LocationPermission.whileInUse || permissionStatus == LocationPermission.always) {
        Position position = await _locationService.getCurrentLocation();
        setState(() {
          print( "Location: ${position.latitude}, ${position.longitude}") ;
        });
      } else {
        setState(() {
          print ("Permission denied!");
        });
      }
    } catch (e) {
      setState(() {
        print( "Error: $e") ;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoadingScreen()
    );
  }
}



// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:uuid/uuid.dart';
// import 'package:vehiclemanagement/components/splash_screen/splash_screen.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
//
// void printIpAddress() async {
//   try {
//     var interfaces = await NetworkInterface.list();
//     for (var interface in interfaces) {
//       for (var addr in interface.addresses) {
//         print('IP Address: ${addr.address}');
//       }
//     }
//   } catch (e) {
//     print("Error fetching IP address: $e");
//   }
// }
//
// Future<String> getDeviceId() async {
//   final deviceInfoPlugin = DeviceInfoPlugin();
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   const uuid = Uuid();
//
//   String deviceId = prefs.getString('deviceId') ?? '';
//
//   if (deviceId.isEmpty) {
//     try {
//       if (Platform.isAndroid) {
//         final androidInfo = await deviceInfoPlugin.androidInfo;
//         deviceId = uuid.v4();
//       } else if (Platform.isIOS) {
//         final iosInfo = await deviceInfoPlugin.iosInfo;
//         deviceId = iosInfo.identifierForVendor ?? uuid.v4();
//       }
//     } catch (e) {
//       print("Error fetching generating device ID: $e");
//       deviceId = uuid.v4();
//     }
//     await prefs.setString('deviceId', deviceId);
//   }
//   return deviceId;
// }
//
// Future<void> getCurrentLocation() async {
//   LocationPermission permission = await Geolocator.requestPermission();
//   if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
//     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     print('Current location: Latitude: ${position.latitude}, Longitude: ${position.longitude}');
//
//     List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
//     if (placemarks.isNotEmpty) {
//       Placemark placemark = placemarks.first;
//       print('Address: ${placemark.street}, ${placemark.name},${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}');
//     } else {
//       print('No address found');
//     }
//   } else {
//     print('Location permission not granted');
//   }
// }
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   String deviceId = await getDeviceId();
//   print("Device ID: $deviceId");
//   printIpAddress();
//   await getCurrentLocation();
//
//   runApp(MyApp(deviceId: deviceId));
// }
//
// class MyApp extends StatelessWidget {
//   final String deviceId;
//
//   MyApp({required this.deviceId});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SplashScreen(),
//     );
//   }
// }


// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:uuid/uuid.dart';
// import 'package:vehiclemanagement/components/splash_screen/splash_screen.dart';
//
// void printIpAddress() async {
//   try {
//     var interfaces = await NetworkInterface.list();
//     for (var interface in interfaces) {
//       for (var addr in interface.addresses) {
//         print('IP Address: ${addr.address}');
//       }
//     }
//   } catch (e) {
//     print("Error fetching IP address: $e");
//   }
// }
//
// Future<String> getDeviceId() async {
//   final deviceInfoPlugin = DeviceInfoPlugin();
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   const uuid = Uuid();
//
//   String deviceId = prefs.getString('deviceId') ?? '';
//
//   if (deviceId.isEmpty) {
//     try {
//       if (Platform.isAndroid) {
//         final androidInfo = await deviceInfoPlugin.androidInfo;
//         deviceId = uuid.v4();
//       } else if (Platform.isIOS) {
//         final iosInfo = await deviceInfoPlugin.iosInfo;
//         deviceId = iosInfo.identifierForVendor ?? uuid.v4();
//       }
//     } catch (e) {
//       print("Error fetching/generating device ID: $e");
//       deviceId = uuid.v4();
//     }
//
//     await prefs.setString('deviceId', deviceId);
//   }
//
//   return deviceId;
// }
//
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   String deviceId = await getDeviceId();
//   print("Device ID: $deviceId");
//   printIpAddress();
//
//   runApp(MyApp(deviceId: deviceId));
// }
//
// class MyApp extends StatelessWidget {
//   final String deviceId;
//
//   MyApp({required this.deviceId});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SplashScreen(),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'counter_controller.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       home: HomeScreen(),
//     );
//   }
// }
//
// class HomeScreen extends StatelessWidget {
//   final CounterController controller = Get.put(CounterController());
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('GetX '),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Obx(() => Text(
//               'Counter: ${controller.counter}',
//               style: TextStyle(fontSize: 30),
//             )),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 controller.increment();
//               },
//               child: Text('Increment'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:get/get_navigation/src/root/get_material_app.dart';
// import 'package:get/get_navigation/src/routes/get_route.dart';
// import 'package:vehiclemanagement/components/permissions/permission_equatable.dart';
// import 'package:vehiclemanagement/components/roles/roles_page.dart';
// import 'package:vehiclemanagement/components/splash_screen/splash_screen.dart';
// import 'package:vehiclemanagement/components/vehicles/vehicle_bloc.dart';
// import 'components/menus/menu_page.dart';
// import 'components/menus/menuswithsubmenu.dart';
// import 'components/permissions/permission_bloc.dart';
//
// void main() {
//   runApp(MyApp());
//   var a = Person(name: "shreya", lastname: "crud");
//   var b = Person(name: "shreya", lastname: "crud");
//
//   print(a == b);
//
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Vehicle Management',
//
//       home: MultiBlocProvider(
//         providers: [
//           BlocProvider<PermissionBloc>(
//             create: (_) => PermissionBloc(),
//           ),
//         ],
//         child: SplashScreen(),
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       initialRoute: '/',
//       getPages: [
//         GetPage(name: '/', page: () => ScreenA()),
//         GetPage(name: '/screenB', page: () => ScreenB()),
//       ],
//     );
//   }
// }
//
// class ScreenA extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Screen A")),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Get.toNamed('/screenB', arguments: {'name': 'shreya', 'age': 20});
//           },
//           child: Text("Go to Screen B"),
//         ),
//       ),
//     );
//   }
// }
//
// class ScreenB extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     var arguments = Get.arguments;
//     var name = arguments['name'];
//     var age = arguments['age'];
//
//     return Scaffold(
//       appBar: AppBar(title: Text("Screen B")),
//       body: Center(
//         child: Text("Name: $name, Age: $age"),
//       ),
//     );
//   }
// }
