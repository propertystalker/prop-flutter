import 'package:flutter/material.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _companyController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    final supabaseService = context.read<SupabaseService>();
    final email = _emailController.text;
    final password = _passwordController.text;
    final companyName = _companyController.text;

    try {
      // The companyName is passed as user metadata during sign-up.
      // A database trigger will now automatically create the company and profile.
      await supabaseService.signUp(
        email,
        password,
        data: {'company': companyName},
      );

      if (mounted) {
        // After sign up, the user always needs to confirm their email.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please check your email to verify your account.')),
        );
        // Pop the registration screen to go back to the previous screen.
        Navigator.of(context).pop();
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Auth Error: ${e.message}')),
        );
      }
    } on PostgrestException catch (e) {
      // This database error should no longer occur with the trigger handling the insert.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Database Error: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _register,
                child: const Text('Yes, I accept. Register me now'),
              ),
          ],
        ),
      ),
    );
  }
}
