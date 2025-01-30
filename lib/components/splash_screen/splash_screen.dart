import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vehiclemanagement/components/login/login_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF0D47A1),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 60,

                backgroundImage: AssetImage('images/truck.png'),
              ),
              SizedBox(height: 20),
              Text(
                "Vehicle Management",
                style: TextStyle(
                  fontSize:27,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Center(
                child: Text("Real-time Tracking,Maintenance, and Seamless reporting for Vehicles",
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white70
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
