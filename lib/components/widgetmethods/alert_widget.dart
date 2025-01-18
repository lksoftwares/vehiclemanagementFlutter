// import 'package:flutter/material.dart';
//
// Future<void> showCustomAlertDialog(
//     BuildContext context, {
//       required String title,
//       required Widget content,
//       required List<Widget> actions,
//       InputDecoration? inputDecoration,
//       double titleFontSize = 25.0,
//       FontWeight titleFontWeight = FontWeight.bold,
//     }) async {
//   return showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Align(
//           alignment: Alignment.center,
//           child: Text(
//             title,
//             style: TextStyle(
//               fontSize: titleFontSize,
//               fontWeight: titleFontWeight,
//             ),
//           ),
//         ),
//         content: content,
//         actions: actions,
//       );
//     },
//   );
// }





import 'package:flutter/material.dart';

Future<void> showCustomAlertDialog(
    BuildContext context, {
      required String title,
      required Widget content,
      required List<Widget> actions,
      InputDecoration? inputDecoration,
      double titleFontSize = 25.0,
      FontWeight titleFontWeight = FontWeight.bold,
    }) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Align(
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: titleFontWeight,
            ),
          ),
        ),
        content: content,
        actions: actions,
      );
    },
  );
}

void showMyCustomDialog(BuildContext context) {
  showCustomAlertDialog(
    context,
    title: "Are you sure?",
    content: Text("Do you want to proceed?"),
    actions: [
      // "Cancel" button
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text("Cancel"),
      ),
      TextButton(
        onPressed: () {
          print("User clicked Yes!");
        },
        child: Text("Yes"),
      ),
    ],
  );
}



class shreya extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Custom Alert Dialog Example")),
        body: Center(
          child: ElevatedButton(
            onPressed: () => showMyCustomDialog(context),
            child: Text("Show Dialog"),
          ),
        ),

    );
  }
}
