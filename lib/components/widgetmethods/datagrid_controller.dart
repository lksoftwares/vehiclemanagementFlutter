//
// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
//
// class DynamicDataGrid<T> extends StatelessWidget {
//   final List<Map<String, dynamic>> data;
//   final List<GridColumn> columns;
//   final Function(Map<String, dynamic> row)? onEdit;
//   final Function(Map<String, dynamic> row)? onDelete;
//
//   DynamicDataGrid({
//     required this.data,
//     required this.columns,
//     this.onEdit,
//     this.onDelete,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SfDataGrid(
//       headerGridLinesVisibility: GridLinesVisibility.both,
//       gridLinesVisibility: GridLinesVisibility.both,
//       columnWidthMode: ColumnWidthMode.fitByColumnName,
//       allowSorting: true,
//       frozenColumnsCount: 1,
//       source: DynamicDataSource(
//         data: data,
//         onEdit: onEdit,
//         onDelete: onDelete,
//       ),
//       allowFiltering: true,
//       columns: columns,
//     );
//   }
// }
//
// class DynamicDataSource extends DataGridSource {
//   final List<Map<String, dynamic>> data;
//   final Function(Map<String, dynamic> row)? onEdit;
//   final Function(Map<String, dynamic> row)? onDelete;
//
//   DynamicDataSource({required this.data, this.onEdit, this.onDelete});
//
//   @override
//   List<DataGridRow> get rows => data
//       .map<DataGridRow>((row) => DataGridRow(cells: row.entries.map((entry) {
//     return DataGridCell<String>(
//       columnName: entry.key,
//       value: entry.value.toString(),
//     );
//   }).toList()))
//       .toList();
//
//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     return DataGridRowAdapter(
//       cells: row.getCells().map<Widget>((cell) {
//         if (cell.columnName == 'edit' || cell.columnName == 'delete') {
//           return Container(
//             alignment: Alignment.center,
//             child: IconButton(
//               icon: Icon(
//                 cell.columnName == 'edit' ? Icons.edit : Icons.delete,
//                 color: cell.columnName == 'edit' ? Colors.green : Colors.red,
//               ),
//               onPressed: () {
//                 final rowData = {
//                   for (var cell in row.getCells()) cell.columnName: cell.value,
//                 };
//                 if (cell.columnName == 'edit' && onEdit != null) {
//                   onEdit!(rowData);
//                 } else if (cell.columnName == 'delete' && onDelete != null) {
//                   onDelete!(rowData);
//                 }
//               },
//             ),
//           );
//         } else {
//           return Container(
//             padding: EdgeInsets.all(8.0),
//             alignment: Alignment.centerLeft,
//             child: Text(cell.value.toString()),
//           );
//         }
//       }).toList(),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
//
// List<GridColumn> buildColumns(List<String> columnNames) {
//   return columnNames.map((columnName) {
//     return GridColumn(
//       columnName: columnName,
//       allowSorting: columnName != 'edit' && columnName != 'delete',
//       allowFiltering: columnName != 'edit' && columnName != 'delete',
//       label: Container(
//         alignment: Alignment.center,
//         padding: EdgeInsets.all(8.0),
//         child: Text(columnName),
//       ),
//     );
//   }).toList();
// }
//
// class GenericDataSource extends DataGridSource {
//   final List<Map<String, dynamic>> data;
//   final List<String> columnNames;
//   final Function(Map<String, dynamic>) onEdit;
//   final Function(Map<String, dynamic>) onDelete;
//
//   GenericDataSource({
//     required this.data,
//     required this.columnNames,
//     required this.onEdit,
//     required this.onDelete,
//   });
//
//   @override
//   List<DataGridRow> get rows => data.map<DataGridRow>((item) {
//     return DataGridRow(
//       cells: columnNames.map<DataGridCell>((column) {
//         return DataGridCell<String>(
//           columnName: column,
//           value: item[column] ?? '',
//         );
//       }).toList(),
//     );
//   }).toList();
//
//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     return DataGridRowAdapter(
//       cells: row.getCells().map<Widget>((cell) {
//         if (cell.columnName == 'edit') {
//           return Container(
//             alignment: Alignment.center,
//             child: IconButton(
//               icon: Icon(Icons.edit, color: Colors.green),
//               onPressed: () {
//                 final item = row.getCells().asMap();
//                 final name = item[1]?.value;
//                 onEdit(name);
//               },
//             ),
//           );
//         } else if (cell.columnName == 'delete') {
//           return Container(
//             alignment: Alignment.center,
//             child: IconButton(
//               icon: Icon(Icons.delete, color: Colors.red),
//               onPressed: () {
//                 final item = row.getCells().asMap();
//                 final name = item[1]?.value;
//                 onDelete(name);
//               },
//             ),
//           );
//         }
//         return Container(
//           padding: EdgeInsets.all(8.0),
//           alignment: Alignment.centerLeft,
//           child: Text(cell.value as String),
//         );
//       }).toList(),
//     );
//   }
// }
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

List<GridColumn> buildDataGridColumns(List<Map<String, dynamic>> columnsConfig) {
  List<GridColumn> columns = [];

  for (var config in columnsConfig) {
    final columnName = config['columnName'];
    final labelText = config['labelText'];

    columns.add(
      GridColumn(
        columnName: columnName,
        allowSorting: true,
        allowFiltering: true,
        label: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8.0),
          child: Text(labelText),
        ),
      ),
    );
    columns.add(
      GridColumn(
        columnName: columnName,
        allowSorting: true,
        allowFiltering: true,
        label: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(8.0),
          child: Text(labelText),
        ),
      ),
    );
    columns.add(GridColumn(
      columnName: 'edit_$columnName',
      allowSorting: false,
      allowFiltering: false,
      label: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text('Edit'),
      ),
    ));

    columns.add(GridColumn(
      columnName: 'delete_$columnName',
      allowSorting: false,
      allowFiltering: false,
      label: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text('Delete'),
      ),
    ));
    columns.add(GridColumn(
      columnName: 'delete_$columnName',
      allowSorting: false,
      allowFiltering: false,
      label: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text('Delete'),
      ),
    ));
  }
  return columns;
}
