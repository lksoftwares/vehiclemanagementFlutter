import 'package:flutter/material.dart';
import '../widgetmethods/appbar_method.dart';

import '../login/logout _method.dart';
import '../../sidebar/navbar.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: CustomAppBar(
        title: 'Home',
        onLogout: () => AuthService.logout(context),
      ),
    );
  }
}
