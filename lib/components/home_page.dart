import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:vehiclemanagement/components/roles_page.dart';
import 'package:vehiclemanagement/components/users_page.dart';
import 'package:vehiclemanagement/components/usershift_page.dart';
import 'package:vehiclemanagement/components/vehicles_page.dart';
import '../appbar_method.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Admin',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryIcon(
                        context, Icons.home, "Home", Colors.blue),
                    SizedBox(
                      width: 15,
                    ),
                    _buildCategoryIcon(context, Icons.person_add_outlined,
                        "Roles", Colors.orange),
                    SizedBox(
                      width: 15,
                    ),
                    _buildCategoryIcon(
                        context, Icons.people, "Users", Colors.green),
                    SizedBox(
                      width: 15,
                    ),
                    _buildCategoryIcon(
                        context, Icons.car_rental, "Vehicles", Colors.purple),
                    SizedBox(
                      width: 15,
                    ),
                    _buildCategoryIcon(
                        context, Icons.input, "UserShifts", Colors.brown),
                    SizedBox(
                      width: 15,
                    ),
                    _buildCategoryIcon(context, Icons.input, "Out", Colors.red),
                    SizedBox(
                      width: 15,
                    ),
                    _buildCategoryIcon(
                        context, Icons.input, "Timings", Colors.yellow),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recent Orders",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage('images/watch.jpg'),
                      ),
                      title: Text("Daniel Wellington Classic"),
                      subtitle: Text("John Doe - Stripe #51202235"),
                      trailing: Text("\$149.21"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(
      BuildContext context, IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        // Navigate based on the label
        if (label == "Home") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DashboardScreen()),
          );
        } else if (label == "Roles") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RolesPage()),
          );
        } else if (label == "Users") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UsersPage()),
          );
        } else if (label == "Vehicles") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VehiclesPage()),
          );
        } else if (label == "UserShifts") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UsershiftPage()),
          );
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 30),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
