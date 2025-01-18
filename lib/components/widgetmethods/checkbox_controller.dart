import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;

  const CustomCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class CheckboxForm extends StatefulWidget {
  @override
  _CheckboxFormState createState() => _CheckboxFormState();
}

class _CheckboxFormState extends State<CheckboxForm> {
  // Track the state of each checkbox
  bool isChecked1 = false;
  bool isChecked2 = false;
  bool isChecked3 = false;

  // Method to print the checkbox values
  void printCheckboxValues() {
    print('Checkbox 1: $isChecked1');
    print('Checkbox 2: $isChecked2');
    print('Checkbox 3: $isChecked3');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiple Checkboxes Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCheckbox(
              value: isChecked1,
              onChanged: (value) {
                setState(() {
                  isChecked1 = value ?? false;
                });
              },
              label: 'Checkbox 1',
            ),
            CustomCheckbox(
              value: isChecked2,
              onChanged: (value) {
                setState(() {
                  isChecked2 = value ?? false;
                });
              },
              label: 'Checkbox 2',
            ),
            CustomCheckbox(
              value: isChecked3,
              onChanged: (value) {
                setState(() {
                  isChecked3 = value ?? false;
                });
              },
              label: 'Checkbox 3',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: printCheckboxValues,
              child: const Text('Print Checkbox Values'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CheckboxForm(),
  ));
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reusable Checkbox Example'),
      ),
      body: Center(
        child: CustomCheckbox(
          value: _isChecked,
          onChanged: (bool? newValue) {
            setState(() {
              _isChecked = newValue ?? false;
            });
          },
          label: 'Agree to terms and conditions',
        ),
      ),
    );
  }
}