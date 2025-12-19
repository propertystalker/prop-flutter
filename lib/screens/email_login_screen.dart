import 'package:flutter/material.dart';
import 'package:myapp/screens/admin_screen.dart';
import 'package:myapp/screens/company_account_screen.dart';
import 'package:myapp/screens/opening_screen.dart';
import 'package:myapp/screens/person_account_screen.dart';
import 'package:myapp/screens/register_screen.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final supabaseService = context.read<SupabaseService>();
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final response = await supabaseService.signInWithPassword(email, password);

      if (mounted && response.user != null) {
        // After login, check if the user's profile is complete.
        final user = response.user!;
        final company = await supabaseService.getCompany(user.id);
        final person = await supabaseService.getPerson(user.id);

        if (company.name.isEmpty) {
          // If company details are missing, navigate to company account screen.
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const CompanyAccountScreen()),
          );
        } else if (person.fullName.isEmpty) {
          // If person details are missing, navigate to person account screen.
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const PersonAccountScreen()),
          );
        } else {
          // If profile is complete, navigate to the main opening screen.
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const OpeningScreen()),
            (route) => false,
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Auth Error: ${e.message}')),
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
        title: const Text('Sign in with Email'),
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
                onPressed: _login,
                child: const Text('Login'),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Register'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminScreen()),
                    );
                  },
                  child: const Text('Admin'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
