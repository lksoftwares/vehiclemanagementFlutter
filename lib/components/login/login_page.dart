import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehiclemanagement/components/widgetmethods/textfield_widget.dart';
import '../../menurole.dart';
import '../widgetmethods/appbar_method.dart';
import '../menus/menuswithsubmenu.dart';
import '../register/register_page.dart';
import 'package:vehiclemanagement/config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  String _emailError = '';
  List<dynamic> roles = [];
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _fetchRoles();
  }

  Future<void> _fetchRoles() async {
    try {
      final response = await http.get(Uri.parse('${Config.apiUrl}Role/GetAllRole'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['statusCode'] == 200 && data['apiResponse'] != null) {
          setState(() {
            roles = data['apiResponse'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load roles: Invalid response format'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check your API'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final roleId = _selectedRole;

    if (username.isEmpty || password.isEmpty || roleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Map<String, String> loginData = {
      'User_Email': username,
      'User_Password': password,
      'Role_Id': roleId,
    };

    try {
      final response = await http.post(
        Uri.parse('${Config.apiUrl}Users/Login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: loginData,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
print(response.body);
        if (data['statusCode'] == 200 && data['apiResponse'] != null) {
          final apiResponse = data['apiResponse'];
          final token = apiResponse['token'];

          if (token != null) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', token);
            await prefs.setInt('user_Id', apiResponse['user_Id']);
            await prefs.setInt('role_Id', apiResponse['role_Id']);
            await prefs.setString('role_Name', apiResponse['role_Name']);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Menuswithsubmenu()),
            );
          } else {
            var responseBody = jsonDecode(response.body);
            String successMessage = responseBody['message'] ?? 'Failed';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(successMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {

          var responseBody = jsonDecode(response.body);
          String successMessage = responseBody['message'] ?? 'Failed';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.red,
            ),
          );

        }
      } else {
        var responseBody = jsonDecode(response.body);
        String successMessage = responseBody['message'] ?? 'Failed';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Check Your API'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Login Now',
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 10),
                Image.asset(
                  'images/truckk.png',
                  width: 200,
                  height: 200,
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  hint: Text('Select Role'),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a role';
                    }
                    return null;
                  },
                  items: roles.map<DropdownMenuItem<String>>((role) {
                    return DropdownMenuItem<String>(
                      value: role['roleId'].toString(),
                      child: Text(role['roleName']),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: Icon(Icons.group),
                  ),
                ),
                SizedBox(height: 20),
                UsernameTextField(
                  controller: _usernameController,
                  errorText: _emailError,
                  onChanged: (email) {
                    _validateEmail(email);
                  },
                  validator: emailValidator,
                ),
                SizedBox(height: 20),
                PasswordTextField(
                  controller: _passwordController,
                  isPasswordVisible: _isPasswordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _login();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill the required fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text(
                    "Don't have an account? Register Now",
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter the valid email with @gmail.com';
    }
    return null;
  }

  void _validateEmail(String email) {
    if (!email.endsWith('@gmail.com')) {
      setState(() {
        _emailError = 'Please enter the valid email with @gmail.com';
      });
    } else {
      setState(() {
        _emailError = '';
      });
    }
  }
}
