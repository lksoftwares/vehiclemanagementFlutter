import 'package:flutter/material.dart';
class UsernameTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final Function(String) onChanged;
  final String? Function(String?) validator;

  const UsernameTextField({
    Key? key,
    required this.controller,
    required this.errorText,
    required this.onChanged,
    required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Username',
        prefixIcon: Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        errorText: errorText?.isNotEmpty == true ? errorText : null,
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}


// Password TextField
class PasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool isPasswordVisible;
  final Function() toggleVisibility;
  final String? Function(String?) validator;

  const PasswordTextField({
    Key? key,
    required this.controller,
    required this.isPasswordVisible,
    required this.toggleVisibility,
    required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: toggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
    );
  }
}
