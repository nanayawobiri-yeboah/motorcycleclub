import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rebels_motorcycle/models/member.dart';
import 'package:rebels_motorcycle/models/bike.dart';
import 'package:rebels_motorcycle/member_add_edit.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(MemberAdapter()); // Register the adapter
  await Hive.openBox<Member>('members');
  await Hive.openBox<Bike>('bikes');
  runApp(MyApp());
}

class Member extends HiveObject {
  late String name;
  late String bikeModel;
  late String registration;
}

/////////

class MemberAdapter extends TypeAdapter<Member> {
  @override
  final typeId = 0; // Unique type ID for the Member class

  @override
  Member read(BinaryReader reader) {
    // Implement how to deserialize a Member instance from binary data
    final member = Member();
    member.name = reader.readString();
    member.bikeModel = reader.readString();
    member.registration = reader.readString();
    return member;
  }

  @override
  void write(BinaryWriter writer, Member member) {
    // Implement how to serialize a Member instance to binary data
    writer.writeString(member.name);
    writer.writeString(member.bikeModel);
    writer.writeString(member.registration);
  }
}
//////////

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MemberListScreen(),
    );
  }
}

class MemberListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final memberBox = Hive.box<Member>('members');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rebels Motorcycle Club Members'),
      ),
      body: ValueListenableBuilder(
        valueListenable: memberBox.listenable(),
        builder: (context, Box<Member> box, _) {
          print('UI Updated');
          if (box.isEmpty) {
            return const Center(
              child: Text('No club members yet.'),
            );
          } else {
            return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                final member = box.getAt(index);
                return Dismissible(
                  key: Key(member!.key.toString()),
                  onDismissed: (direction) {
                    box.deleteAt(index);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: Text(member.name),
                    subtitle:
                        Text('${member.registration} ${member.bikeModel}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MemberAddEditScreen(member: member),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MemberAddEditScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MemberEditScreen extends StatefulWidget {
  final Member member;

  MemberEditScreen({required this.member});

  @override
  _MemberEditScreenState createState() => _MemberEditScreenState();
}

class _MemberEditScreenState extends State<MemberEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _modelController;
  late TextEditingController _registrationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.member.name);
    _modelController = TextEditingController(text: widget.member.bikeModel);
    _registrationController =
        TextEditingController(text: widget.member.registration.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _registrationController.dispose();
    super.dispose();
  }

  void _updateMember() {
    final name = _nameController.text;
    final model = _modelController.text;
    final year = int.tryParse(_registrationController.text) ?? 0;

    if (name.isNotEmpty && model.isNotEmpty && year > 0) {
      widget.member.name = name;
      widget.member.bikeModel = model;
      widget.member.registration = year.toString();
      widget.member.save();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Member'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _modelController,
              decoration: InputDecoration(labelText: 'Bike Model'),
            ),
            TextField(
              controller: _registrationController,
              decoration: InputDecoration(labelText: 'Bike Registration'),
            ),
            ElevatedButton(
              onPressed: _updateMember,
              child: const Text('Update Member'),
            ),
          ],
        ),
      ),
    );
  }
}

class MemberAddScreen extends StatefulWidget {
  const MemberAddScreen({super.key});

  @override
  _MemberAddScreenState createState() => _MemberAddScreenState();
}

class _MemberAddScreenState extends State<MemberAddScreen> {
  final _nameController = TextEditingController();
  final _modelController = TextEditingController();
  final _registrationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _modelController.dispose();
    _registrationController.dispose();
    super.dispose();
  }

  void _addMember() {
    final name = _nameController.text;
    final model = _modelController.text;
    final registration = _registrationController.text;

    if (kDebugMode) {
      print('Name: $name');
    }
    if (kDebugMode) {
      print('Model: $model');
    }
    if (kDebugMode) {
      print('Registration: $registration');
    }

    if (name.isNotEmpty && model.isNotEmpty && registration.isNotEmpty) {
      final memberBox = Hive.box<Member>('members');
      final newMember = Member()
        ..name = name
        ..bikeModel = model
        ..registration = registration as String;
      memberBox.add(newMember);

      _nameController.clear();
      _modelController.clear();
      _registrationController.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MemberListScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Member'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              keyboardType: TextInputType.name,
            ),
            TextField(
              controller: _modelController,
              decoration: const InputDecoration(labelText: 'Bike Model'),
              keyboardType: TextInputType.name,
            ),
            TextField(
              controller: _registrationController,
              decoration: const InputDecoration(labelText: 'Bike Registration'),
              keyboardType: TextInputType.name,
            ),
            ElevatedButton(
              onPressed: _addMember,
              child: const Text('Add Member'),
            ),
          ],
        ),
      ),
    );
  }
}
