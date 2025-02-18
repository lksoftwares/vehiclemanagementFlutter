//working code

// import 'package:flutter/material.dart';
//
// Future<void> showCustomAlertDialog(
//     BuildContext context, {
//       String title = "Title",
//       Widget content = const Text("content here."),
//       required List<Widget> actions,
//       InputDecoration? inputDecoration,
//       double titleFontSize = 25.0,
//       FontWeight titleFontWeight = FontWeight.bold,
//       bool showYesButton = false,
//       bool showNoButton = false,
//       bool showCancelButton = false,
//       Function? onYesPressed,
//       Function? onNoPressed,
//       Function? onCancelPressed,
//       String yesButtonText = "Yes",
//       String noButtonText = "No",
//       String cancelButtonText = "Cancel",
//       IconData? yesIcon,
//       IconData? noIcon,
//       IconData? cancelIcon,
//     }) async {
//   List<Widget> dialogActions = [];
//
//   Widget _buildTextButton(String buttonText, Function? onPressedCallback, BuildContext context) {
//     return TextButton(
//       onPressed: () {
//         if (onPressedCallback != null) {
//           onPressedCallback();
//         }
//       },
//       child: Text(buttonText),
//     );
//   }
//
//   Widget _buildIconButton(IconData icon, Function? onPressedCallback, BuildContext context) {
//     return IconButton(
//       onPressed: () {
//         if (onPressedCallback != null) {
//           onPressedCallback();
//         }
//       },
//       icon: Icon(icon),
//     );
//   }
//
//   // Add cancel button with IconButton or TextButton
//   if (showCancelButton) {
//     if (cancelIcon != null) {
//       dialogActions.add(_buildIconButton(cancelIcon, onCancelPressed, context));
//     } else {
//       dialogActions.add(_buildTextButton(cancelButtonText, onCancelPressed, context));
//     }
//   }
//
//   if (showNoButton) {
//     if (noIcon != null) {
//       dialogActions.add(_buildIconButton(noIcon, onNoPressed, context));
//     } else {
//       dialogActions.add(_buildTextButton(noButtonText, onNoPressed, context));
//     }
//   }
//
//   if (showYesButton) {
//     if (yesIcon != null) {
//       dialogActions.add(_buildIconButton(yesIcon, onYesPressed, context));
//     } else {
//       dialogActions.add(_buildTextButton(yesButtonText, onYesPressed, context));
//     }
//   }
//
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
//         actions: dialogActions,
//       );
//     },
//   );
// }
//
// void showMyCustomDialog(
//     BuildContext context, {
//       String? title,
//       Widget? content,
//       bool showYesButton = false,
//       bool showNoButton = false,
//       bool showCancelButton = false,
//       Function? onYesPressed,
//       Function? onNoPressed,
//       Function? onCancelPressed,
//       String yesButtonText = "Yes",
//       String noButtonText = "No",
//       String cancelButtonText = "Cancel",
//       IconData? yesIcon,
//       IconData? noIcon,
//       IconData? cancelIcon,
//     }) {
//   showCustomAlertDialog(
//     context,
//     actions: [],
//     showYesButton: showYesButton,
//     showNoButton: showNoButton,
//     showCancelButton: showCancelButton,
//     onYesPressed: onYesPressed,
//     onNoPressed: onNoPressed,
//     onCancelPressed: onCancelPressed,
//     yesButtonText: yesButtonText,
//     noButtonText: noButtonText,
//     cancelButtonText: cancelButtonText,
//     yesIcon: yesIcon,
//     noIcon: noIcon,
//     cancelIcon: cancelIcon,
//   );
// }
//
// class Shreya extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Alert Dialog")),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             showMyCustomDialog(
//               context,
//               title: "Shreya",
//               content: Text("Hey, good morning"),
//               showYesButton: true,
//               showNoButton: true,
//               showCancelButton: true,
//               yesButtonText: "Agree",
//               noButtonText: "Disagree",
//               cancelButtonText: "Close",
//
//               onYesPressed: () {
//                 print("Agree button pressed");
//               },
//               onNoPressed: () {
//                 print("Disagree button pressed");
//               },
//               onCancelPressed: () {
//                 print("Close button pressed");
//               },
//             );
//           },
//           child: Text("Show Dialog"),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
//
// Future<void> showCustomAlertDialog(
//     BuildContext context, {
//       String title = "Title",
//       Widget content = const Text("content here."),
//       required List<Widget> actions,
//       InputDecoration? inputDecoration,
//       double titleFontSize = 25.0,
//       FontWeight titleFontWeight = FontWeight.bold,
//       bool showYesButton = false,
//       bool showNoButton = false,
//       bool showCancelButton = false,
//       Function? onYesPressed,
//       Function? onNoPressed,
//       Function? onCancelPressed,
//     }) async {
//
//   List<Widget> dialogActions = [];
//
//   Widget _buildDialogButton(
//       String buttonText,
//       Function? onPressedCallback,
//       BuildContext context,
//       ) {
//     return TextButton(
//       onPressed: () {
//         if (onPressedCallback != null) {
//           onPressedCallback();
//         }
//       },
//       child: Text(buttonText),
//     );
//   }
//   if (showCancelButton) {
//     dialogActions.add(
//       _buildDialogButton("Cancel", onCancelPressed, context),
//     );
//   }
//   if (showNoButton) {
//     dialogActions.add(
//       _buildDialogButton("No", onNoPressed, context),
//     );
//   }
//   if (showYesButton) {
//     dialogActions.add(
//       _buildDialogButton("Yes", onYesPressed, context),
//     );
//   }
//
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
//         actions: dialogActions,
//       );
//     },
//   );
// }
//
//
//
// void showMyCustomDialog(BuildContext context, {
//   String? title,
//   Widget? content,
//   bool showYesButton = false,
//   bool showNoButton = false,
//   bool showCancelButton = false,
//   Function? onYesPressed,
//   Function? onNoPressed,
//   Function? onCancelPressed,
// }) {
//   showCustomAlertDialog(
//     context,
//     actions: [],
//     showYesButton: showYesButton,
//     showNoButton: showNoButton,
//     showCancelButton: showCancelButton,
//     onYesPressed: onYesPressed,
//     onNoPressed: onNoPressed,
//     onCancelPressed: onCancelPressed,
//   );
// }
//
// class Shreya extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Alert Dialog")),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             showMyCustomDialog(
//               context,
//               title: "Shreya",
//               content: Text("Hey, good morning"),
//               showYesButton: true,
//               showNoButton: true,
//               showCancelButton: true,
//               onYesPressed: () {
//                 print("Yes button pressed");
//               },
//               onNoPressed: () {
//                 print("No button pressed");
//               },
//               onCancelPressed: () {
//                 print("Cancel button pressed");
//               },
//             );
//           },
//           child: Text("Show Dialog"),
//         ),
//       ),
//     );
//   }
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