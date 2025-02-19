import 'package:flutter_contacts/contact.dart';
import 'package:flutter/material.dart';
import '../all_files.dart';
import 'contactaccess_method.dart';

class ContactsScreen extends StatefulWidget {
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void _loadContacts() async {
    List<Contact> contacts = await ContactAccess.getContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: _contacts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          final phoneNumber = contact.phones.isNotEmpty ? contact.phones[0].number : '';

          return ListTile(
            leading: contact.thumbnail != null
                ? CircleAvatar(backgroundImage: MemoryImage(contact.thumbnail!))
                : null,
            title: Text(contact.displayName ?? 'No Name'),
            subtitle: Text(phoneNumber),
            onTap: () {
              if (phoneNumber.isNotEmpty) {
                ContactAccess.openDialer(phoneNumber);
              }
            },
          );
        },
      ),
    );
  }
}
