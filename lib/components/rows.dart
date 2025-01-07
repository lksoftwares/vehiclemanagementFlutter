import 'package:flutter/material.dart';

class DynamicRowPage extends StatefulWidget {
  @override
  _DynamicRowPageState createState() => _DynamicRowPageState();
}

class _DynamicRowPageState extends State<DynamicRowPage> {
  List<TextEditingController> controllers = [];

  List<String> rowTexts = [];

  List<String> dropdownValues = [];

  bool showPrintedValues = false;

  List<FocusNode> dropdownFocusNodes = [];
  List<FocusNode> textFieldFocusNodes = [];

  List<Map<String, String>> dropdownOptions = [
    {"id": "1", "label": "value 1"},
    {"id": "2", "label": "value 2"},
    {"id": "3", "label": "value 3"},
  ];

  @override
  void initState() {
    super.initState();
    controllers.add(TextEditingController());
    rowTexts.add('');
    dropdownValues.add('');

    dropdownFocusNodes.add(FocusNode());
    textFieldFocusNodes.add(FocusNode());
  }

  void addNewRow(int index) {
    if (index == 0) {
      if (dropdownValues[index].isEmpty || controllers[index].text.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Alert"),
            content: Text("Please fill the fields before adding a new row."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          controllers.add(TextEditingController());
          rowTexts.add('');
          dropdownValues.add('');
          dropdownFocusNodes.add(FocusNode());
          textFieldFocusNodes.add(FocusNode());
        });

        FocusScope.of(context).requestFocus(dropdownFocusNodes[index + 1]);
      }
    } else {
      if (controllers[index].text.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Alert"),
            content: Text("Please enter a value in the current row before adding a new one."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          controllers.add(TextEditingController());
          rowTexts.add('');
          dropdownValues.add('');
          dropdownFocusNodes.add(FocusNode());
          textFieldFocusNodes.add(FocusNode());
        });

        FocusScope.of(context).requestFocus(dropdownFocusNodes[index + 1]);
      }
    }
  }

  void deleteRow(int index) {
    if (controllers.length > 1) {
      setState(() {
        controllers.removeAt(index);
        rowTexts.removeAt(index);
        dropdownValues.removeAt(index);
        dropdownFocusNodes.removeAt(index);
        textFieldFocusNodes.removeAt(index);
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Alert"),
          content: Text("You cannot delete the last row."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void updateRowText(int index, String value) {
    setState(() {
      rowTexts[index] = value;
    });
  }

  void updateDropdownValue(int index, String value) {
    setState(() {
      dropdownValues[index] = value;
    });

    dropdownFocusNodes[index].unfocus();
    FocusScope.of(context).requestFocus(textFieldFocusNodes[index]);
  }

  @override
  void dispose() {
    for (var node in dropdownFocusNodes) {
      node.dispose();
    }
    for (var node in textFieldFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Row Input")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            if (!showPrintedValues)
              Expanded(
                child: ListView.builder(
                  itemCount: controllers.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: i == 0
                                ? Row(
                              children: [
                                Expanded(
                                  child: Focus(
                                    focusNode: dropdownFocusNodes[i],
                                    onFocusChange: (hasFocus) {
                                      setState(() {});
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: dropdownFocusNodes[i].hasFocus
                                              ? Colors.deepPurple
                                              : Colors.grey,
                                          width: dropdownFocusNodes[i].hasFocus
                                              ? 2.0
                                              : 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: DropdownButton<String>(
                                        value: dropdownValues[i].isEmpty
                                            ? null
                                            : dropdownValues[i],
                                        hint: Text('Select'),
                                        onChanged: (String? newValue) {
                                          updateDropdownValue(i, newValue ?? '');
                                        },
                                        isExpanded: true,
                                        underline: SizedBox(),
                                        items: dropdownOptions
                                            .map<DropdownMenuItem<String>>(
                                                (Map<String, String> option) {
                                              return DropdownMenuItem<String>(
                                                value: option['id'],
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets.symmetric(horizontal: 10.0),
                                                  child: Text(option['label']!),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: controllers[i],
                                    focusNode: textFieldFocusNodes[i],
                                    decoration: InputDecoration(
                                      labelText: 'Enter Text',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      updateRowText(i, value);
                                    },
                                  ),
                                ),
                              ],
                            )
                                : Row(
                              children: [
                                Expanded(
                                  child: Focus(
                                    focusNode: dropdownFocusNodes[i],
                                    onFocusChange: (hasFocus) {
                                      setState(() {});
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: dropdownFocusNodes[i].hasFocus
                                              ? Colors.deepPurple
                                              : Colors.grey,
                                          width: dropdownFocusNodes[i].hasFocus
                                              ? 2.0
                                              : 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: DropdownButton<String>(
                                        value: dropdownValues[i].isEmpty
                                            ? null
                                            : dropdownValues[i],
                                        hint: Text('Select'),
                                        onChanged: (String? newValue) {
                                          updateDropdownValue(i, newValue ?? '');
                                        },
                                        isExpanded: true,
                                        underline: SizedBox(),
                                        items: dropdownOptions
                                            .map<DropdownMenuItem<String>>(
                                                (Map<String, String> option) {
                                              return DropdownMenuItem<String>(
                                                value: option['id'],
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets.symmetric(horizontal: 10.0),
                                                  child: Text(option['label']!),
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: controllers[i],
                                    focusNode: textFieldFocusNodes[i],
                                    decoration: InputDecoration(
                                      labelText: 'Enter Text',
                                      border: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      updateRowText(i, value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (i == controllers.length - 1)
                            IconButton(
                              icon: Icon(Icons.navigate_next),
                              onPressed: () {
                                addNewRow(i);
                              },
                            ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              deleteRow(i);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            if (showPrintedValues)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(rowTexts.length, (index) {
                  return Text('Row ${index + 1}: ${rowTexts[index]}');
                }),
              ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showPrintedValues = !showPrintedValues;
                });
              },
              child: Text(showPrintedValues ? "Edit Rows" : "Print Rows"),
            ),
          ],
        ),
      ),
    );
  }
}
