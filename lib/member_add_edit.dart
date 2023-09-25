import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rebels_motorcycle/main.dart';

class MemberAddEditScreen extends StatefulWidget {
  final Member? member; // Pass a member if editing, null if adding

  MemberAddEditScreen({this.member});

  @override
  _MemberAddEditScreenState createState() => _MemberAddEditScreenState();
}

class _MemberAddEditScreenState extends State<MemberAddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bikeModelController = TextEditingController();
  final _registrationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      // If editing, populate the fields with existing data
      _nameController.text = widget.member!.name;
      _bikeModelController.text = widget.member!.bikeModel;
      _registrationController.text = widget.member!.registration;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bikeModelController.dispose();
    _registrationController.dispose();
    super.dispose();
  }

  void _saveMember() {
    if (_formKey.currentState!.validate()) {
      final memberBox = Hive.box<Member>('members');

      if (widget.member == null) {
        // Adding a new member
        final newMember = Member()
          ..name = _nameController.text
          ..bikeModel = _bikeModelController.text
          ..registration = _registrationController.text;
        memberBox.add(newMember);
      } else {
        // Editing an existing member
        widget.member!.name = _nameController.text;
        widget.member!.bikeModel = _bikeModelController.text;
        widget.member!.registration = _registrationController.text;
        widget.member!.save();
      }

      Navigator.pop(context); // Go back to the previous screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.member != null;
    final appBarTitle = isEditing ? 'Edit Member' : 'Add Member';

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _bikeModelController,
                decoration: InputDecoration(labelText: 'Motorcycle Model'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the motorcycle model';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _registrationController,
                decoration: InputDecoration(labelText: 'Registration Number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the registration number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveMember,
                child: Text(isEditing ? 'Update' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
