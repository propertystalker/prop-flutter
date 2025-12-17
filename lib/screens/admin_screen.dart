import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Future<Map<String, dynamic>?>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _getOrCreateProfile();
  }

  Future<Map<String, dynamic>> _getOrCreateProfile() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw 'You are not logged in.';
    }

    final profileResponse = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (profileResponse != null) {
      return profileResponse;
    }

    final companyName = user.appMetadata?['company'] as String? ?? 'No company set';

    try {
      final createResponse = await supabase.from('profiles').insert({
        'id': user.id,
        'company': companyName,
      }).select().single();

      return createResponse;

    } on PostgrestException catch (e) {
      throw 'Failed to create your profile in the database. Reason: ${e.message}';
    } catch (e) {
      throw 'An unexpected error occurred while creating your profile: $e';
    }
  }

  void _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _profileFuture = _getOrCreateProfile();
              });
            },
            tooltip: 'Refresh Profile',
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('There was an issue loading your profile. Please refresh.'),
            );
          }

          final profile = snapshot.data!;
          final company = profile['company'] ?? 'No company set';

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                if (user != null)
                  Text(
                    'Email: ${user.email}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                const SizedBox(height: 8),
                Text(
                  'Company: $company',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
