// import 'package:flutter/material.dart';
// import 'package:vehiclemanagement/components/roles/roles_page.dart';
// import 'package:vehiclemanagement/components/vehicles/vehicles_page.dart';
// import 'package:vehiclemanagement/components/menus/menu_page.dart';
//
//
// import '../menus/menuswithsubmenu.dart';
//
// class BottomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final BuildContext context;
//
//   const BottomNavBar({
//     Key? key,
//     required this.currentIndex,
//     required this.context,
//   }) : super(key: key);
//
//   void _onItemTapped(int index) {
//     switch (index) {
//       case 0:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => Menuswithsubmenu()),
//         );
//         break;
//       case 1:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => RolesPage()),
//         );
//         break;
//       case 2:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => VehiclesPage()),
//         );
//         break;
//       case 3:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => MenuPage()),
//         );
//         break;
//       default:
//       // Add any additional navigation logic if needed
//         break;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       type: BottomNavigationBarType.fixed,
//       currentIndex: currentIndex,
//       onTap: _onItemTapped,
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.supervised_user_circle_sharp),
//           label: 'Roles',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.car_repair),
//           label: 'Vehicles',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.menu),
//           label: 'Menus',
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:vehiclemanagement/components/permissions/permission_page.dart';
import 'package:vehiclemanagement/components/roles/roles_page.dart';
import 'package:vehiclemanagement/components/vehicles/vehicles_page.dart';
import 'package:vehiclemanagement/components/menus/menu_page.dart';

import '../menus/menuswithsubmenu.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final BuildContext context;
  final Function(int) onItemTapped;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.context,
    required this.onItemTapped,
  }) : super(key: key);

  void _onItemTapped(int index) {
    onItemTapped(index);

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Menuswithsubmenu()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PermissionPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VehiclesPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MenuPage()),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home,size: 30),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.verified_user_rounded,size: 30,),
          label: 'Permissions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.car_repair,size: 30),
          label: 'Vehicles',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu,size: 30),
          label: 'Menus',
        ),
      ],
    );
  }
}
