import 'package:flutter/material.dart';
import 'package:vehiclemanagement/components/splash_screen/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vehicle Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// /// The application that contains datagrid on it.
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Syncfusion DataGrid Demo',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: MyHomePage(),
//     );
//   }
// }
//
// /// The home page of the application which hosts the datagrid.
// class MyHomePage extends StatefulWidget {
//   /// Creates the home page.
//   MyHomePage({Key? key}) : super(key: key);
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   List<Employee> employees = <Employee>[];
//   late EmployeeDataSource employeeDataSource;
//
//   @override
//   void initState() {
//     super.initState();
//     employees = getEmployeeData();
//     employeeDataSource = EmployeeDataSource(employeeData: employees);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Syncfusion Flutter DataGrid'),
//       ),
//       body: SfDataGrid(
//
//         source: employeeDataSource,
//         columnWidthMode: ColumnWidthMode.fill,
//         columns: <GridColumn>[
//           GridColumn(
//               columnName: 'id',
//               label: Container(
//                   padding: EdgeInsets.all(16.0),
//                   alignment: Alignment.center,
//                   child: Text(
//                     'ID',
//                   ))),
//           GridColumn(
//               columnName: 'name',
//               label: Container(
//                   padding: EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: Text('Name'))),
//           GridColumn(
//               columnName: 'designation',
//               label: Container(
//                   padding: EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: Text(
//                     'Designation',
//                     overflow: TextOverflow.ellipsis,
//                   ))),
//           GridColumn(
//               columnName: 'salary',
//               label: Container(
//                   padding: EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: Text('Salary'))),
//           GridColumn(
//               columnName: 'company',
//               label: Container(
//                   padding: EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: Text('company'))),
//         ],
//       ),
//     );
//   }
//
//   List<Employee> getEmployeeData() {
//     return [
//       Employee(10001, 'James', 'Project Lead', 20000, "lkkkk"),
//       Employee(10002, 'Kathryn', 'Manager', 30000, "lkkk"),
//       Employee(10003, 'Lara', 'Developer', 15000, "lkkk"),
//       Employee(10004, 'Michael', 'Designer', 15000, "lkkk"),
//       Employee(10005, 'Martin', 'Developer', 15000, "lkkk"),
//       Employee(10006, 'Newberry', 'Developer', 15000, "lkkk"),
//       Employee(10007, 'Balnc', 'Developer', 15000, "lkkk"),
//       Employee(10008, 'Perry', 'Developer', 15000, "lkkk"),
//       Employee(10009, 'Gable', 'Developer', 15000, "lkkk"),
//       Employee(10010, 'Grimes', 'Developer', 15000, "lkkk"),
//       Employee(10008, 'Perry', 'Developer', 15000, "lkkk"),
//       Employee(10008, 'Perry', 'Developer', 15000, "lkkk"),
//       Employee(10008, 'Perry', 'Developer', 15000, "lkkk"),
//       Employee(10008, 'Perry', 'Developer', 15000, "lkkk"),
//       Employee(10008, 'Perry', 'Developer', 15000, "lkkk"),
//       Employee(10008, 'Perry', 'Developer', 15000, "lkkk"),
//       Employee(10008, 'Perry', 'Developer', 15000, "lkkk"),
//       Employee(10008, 'Perry', 'Developer', 15000, "lkkk"),
//       Employee(10008, 'Perry', 'Developer', 15000, "lkkk"),
//       Employee(10008, 'Perry', 'Developer', 15000, "lkkk"),
//       Employee(10008, 'Perry', 'Developer', 15000, "lkkk"),
//       Employee(10008, 'Perry', 'Developer', 15000, "lkkk"),
//       Employee(10008, 'Perry', 'Developer', 15000, "lkkk"),
//       Employee(10008, 'Perry', 'Developer', 15000, "lkkk"),
//
//
//     ];
//   }
// }
//
// /// Custom business object class which contains properties to hold the detailed
// /// information about the employee which will be rendered in datagrid.
// class Employee {
//   /// Creates the employee class with required details.
//   Employee(this.id, this.name, this.designation, this.salary , this.company);
//
//   /// Id of an employee.
//   final int id;
//
//   /// Name of an employee.
//   final String name;
//
//   /// Designation of an employee.
//   final String designation;
//
//   /// Salary of an employee.
//   final int salary;
//   final String company;
//
// }
//
// /// An object to set the employee collection data source to the datagrid. This
// /// is used to map the employee data to the datagrid widget.
// class EmployeeDataSource extends DataGridSource {
//   /// Creates the employee data source class with required details.
//   EmployeeDataSource({required List<Employee> employeeData}) {
//     _employeeData = employeeData
//         .map<DataGridRow>((e) => DataGridRow(cells: [
//       DataGridCell<int>(columnName: 'id', value: e.id),
//       DataGridCell<String>(columnName: 'name', value: e.name),
//       DataGridCell<String>(
//           columnName: 'designation', value: e.designation),
//       DataGridCell<int>(columnName: 'salary', value: e.salary),
//       DataGridCell<String>(columnName: 'company', value: e.company),
//
//     ]))
//         .toList();
//   }
//
//   List<DataGridRow> _employeeData = [];
//
//   @override
//   List<DataGridRow> get rows => _employeeData;
//
//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     return DataGridRowAdapter(
//         cells: row.getCells().map<Widget>((e) {
//           return Container(
//             alignment: Alignment.center,
//             padding: EdgeInsets.all(8.0),
//             child: Text(e.value.toString()),
//           );
//         }).toList());
//   }
// }