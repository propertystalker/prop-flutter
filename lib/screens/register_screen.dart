import 'package:flutter/material.dart';
import 'package:myapp/controllers/user_controller.dart';
import 'package:myapp/models/person.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _companyController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Company',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final userController = context.read<UserController>();
                final newUser = Person(
                  email: _emailController.text,
                  company: _companyController.text,
                  password: _passwordController.text,
                );
                userController.addUser(newUser);
                Navigator.of(context)
                    .popUntil((route) => route.isFirst);
              },
              child: const Text('Yes, I accept. Register me now'),
            ),
          ],
        ),
      ),
    );
  }
}
