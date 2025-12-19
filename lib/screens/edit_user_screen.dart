import 'package:flutter/material.dart';
import 'package:myapp/controllers/user_controller.dart';
import 'package:myapp/models/user_model.dart';
import 'package:provider/provider.dart';

class EditUserScreen extends StatefulWidget {
  final User user;

  const EditUserScreen({super.key, required this.user});

  @override
  EditUserScreenState createState() => EditUserScreenState();
}

class EditUserScreenState extends State<EditUserScreen> {
  late TextEditingController _emailController;
  late TextEditingController _companyController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.user.email);
    _companyController = TextEditingController(text: widget.user.company);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(labelText: 'Company'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                final userController = context.read<UserController>();
                final updatedUser = User(
                  id: widget.user.id,
                  email: _emailController.text,
                  company: _companyController.text,
                );
                userController.updateUser(updatedUser);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
