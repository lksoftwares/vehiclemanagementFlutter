import 'package:flutter/material.dart';
import 'card_decoration.dart';

Widget buildUserCard({
  required Map<String, String> userFields,
  Function? onEdit,
  Function? onDelete,
}) {
  List<Widget> fieldRows = [];
  String firstKey = userFields.keys.first;
  String firstValue = userFields[firstKey] ?? '';

  userFields.forEach((key, value) {
    if (key != firstKey) {
      fieldRows.add(
        Padding(
          
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Row(
            children: [
              Text(
                '$key:',
                style: TextStyle(fontSize: 15, color: Colors.grey[900]),
              ),
              Spacer(),
              Text(
                key == 'Password' ? '*' * value.length : value,
                style: TextStyle(fontSize: 15, color: Colors.grey[900]),
              ),
            ],
          ),
        ),
      );
    }
  });

  return buildCardLayout(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Text(
                  '$firstKey: $firstValue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
              ),
              Spacer(),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.green),
                onPressed: onEdit as void Function()?,
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete as void Function()?,
              ),
            ],
          ),

          ...fieldRows,
          Divider(thickness: 1, color: Colors.grey[400]),
        ],
      ),
    ),
  );
}
