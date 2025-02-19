import 'package:geolocator/geolocator.dart';

import '../../all_files.dart';
import 'locationaccess_method.dart';

class LocationScreen extends StatelessWidget {
  final LocationService locationService = LocationService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Location Permission ")),
        body: Center(
          child: FutureBuilder<Position?>(
            future: locationService.getCurrentLocation(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                return Text(
                    'Location: ${snapshot.data!.latitude}, ${snapshot.data!.longitude}');
              } else {
                return Text('No location data available.');
              }
            },
          ),
        ),
      ),
    );
  }
}