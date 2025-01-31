import 'package:flutter/material.dart';

Widget buildUserCard({
  String name = '',
  String email = '',
  String role = '',
  String password = '',
  Function? onEdit,
  Function? onDelete,
}) {
  return Card(
    margin: EdgeInsets.symmetric(vertical: 8),
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    color: Colors.white,
    shadowColor: Colors.black.withOpacity(0.3),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Name :',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 5,),
                Text(
                  name,
                  style: TextStyle(fontSize: 18, color: Colors.black87),
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
            SizedBox(height: 10),
            // Email Row
            Row(
              children: [
                Text(
                  'Email:',
                  style: TextStyle(fontSize: 15, color: Colors.grey[900]),
                ),
                Spacer(),
                Text(
                  email,
                  style: TextStyle(fontSize: 15, color: Colors.grey[900]),
                ),
              ],
            ),
            SizedBox(height: 5),
            // Role Row
            Row(
              children: [
                Text(
                  'Role:',
                  style: TextStyle(fontSize: 15, color: Colors.grey[900]),
                ),
                Spacer(),
                Text(
                  role,
                  style: TextStyle(fontSize: 15, color: Colors.grey[900]),
                ),
              ],
            ),
            SizedBox(height: 5),
            // Password Row (Masked)
            Row(
              children: [
                Text(
                  'Password:',
                  style: TextStyle(fontSize: 15, color: Colors.grey[900]),
                ),
                Spacer(),
                Text(
                  '*' * password.length,
                  style: TextStyle(fontSize: 15, color: Colors.grey[900]),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(thickness: 1, color: Colors.grey[400]),
          ],
        ),
      ),
    ),
  );
}
