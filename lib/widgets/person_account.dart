import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/models/company.dart';
import 'package:myapp/models/person.dart';
import 'package:myapp/screens/company_screen.dart';
import 'package:myapp/services/person_service.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersonAccount extends StatefulWidget {
  const PersonAccount({super.key});

  @override
  State<PersonAccount> createState() => _PersonAccountState();
}

class _PersonAccountState extends State<PersonAccount> {
  final _formKey = GlobalKey<FormState>();
  late final PersonService _personService;
  late final SupabaseClient _client;
  late final StreamSubscription<AuthState> _authStateSubscription;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _linkedinController = TextEditingController();

  XFile? _avatar;
  String? _avatarUrl;
  Company? _company;

  @override
  void initState() {
    super.initState();
    debugPrint("[DEBUG] PersonAccount: initState CALLED");

    final supabaseService = Provider.of<SupabaseService>(context, listen: false);
    _client = supabaseService.client;
    _personService = PersonService(_client);

    _authStateSubscription = _client.auth.onAuthStateChange.listen((data) {
      debugPrint("[DEBUG] PersonAccount: onAuthStateChange TRIGGERED");
      final Session? session = data.session;
      final AuthChangeEvent event = data.event;
      debugPrint("[DEBUG] PersonAccount: AuthChangeEvent - ${event.toString()}");
      debugPrint("[DEBUG] PersonAccount: Session is ${session != null ? 'NOT NULL' : 'NULL'}");

      if (session != null) {
        debugPrint("[DEBUG] PersonAccount: Session is active, calling _getProfile()");
        setState(() {
          _getProfile();
        });
      } else {
        debugPrint("[DEBUG] PersonAccount: Session is null, clearing fields.");
        setState(() {
          _fullNameController.clear();
          _emailController.clear();
          _mobileController.clear();
          _linkedinController.clear();
          _avatar = null;
          _avatarUrl = null;
          _company = null;
        });
      }
    });

    final initialSession = _client.auth.currentSession;
    debugPrint("[DEBUG] PersonAccount: Initial session check is ${initialSession != null ? 'NOT NULL' : 'NULL'}");
    if (initialSession != null) {
      debugPrint("[DEBUG] PersonAccount: Initial session is active, calling _getProfile()");
      _getProfile();
    }
  }

  @override
  void dispose() {
    debugPrint("[DEBUG] PersonAccount: dispose CALLED");
    _fullNameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _linkedinController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  Future<void> _getProfile() async {
    debugPrint("[DEBUG] PersonAccount: _getProfile CALLED");
    if (!mounted) {
      debugPrint("[DEBUG] PersonAccount: _getProfile CANCELED - widget is not mounted.");
      return;
    }

    final user = _client.auth.currentUser;
    if (user != null) {
      debugPrint("[DEBUG] PersonAccount: currentUser is NOT NULL. Email: ${user.email}");
      setState(() {
        _emailController.text = user.email ?? 'Error: Email is null';
      });

      try {
        debugPrint("[DEBUG] PersonAccount: Fetching profile from Supabase for user ID: ${user.id}");
        final person = await _personService.getPerson(user.id);

        if (mounted) {
          debugPrint("[DEBUG] PersonAccount: Profile data FOUND. Full Name: ${person.fullName}");
          setState(() {
            _fullNameController.text = person.fullName;
            _mobileController.text = person.mobile ?? '';
            _linkedinController.text = person.linkedin ?? '';
            _avatarUrl = person.avatarUrl;
            _company = person.company;
          });
        } else {
          debugPrint("[DEBUG] PersonAccount: Profile data is NULL or widget is not mounted.");
        }
      } catch (error) {
        debugPrint("[DEBUG] PersonAccount: ERROR fetching profile: $error");
      }
    }
  }

  Future<void> _onSave() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final user = _client.auth.currentUser;
      if (user != null) {
        final companyToSave = _company ?? Company.empty();
        final person = Person(
          id: user.id,
          fullName: _fullNameController.text,
          email: _emailController.text,
          mobile: _mobileController.text,
          linkedin: _linkedinController.text,
          company: companyToSave,
        );

        await _personService.updatePerson(person);
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CompanyScreen(),
            ),
          );
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatar = pickedFile;
      });
    }
  }

  void _deleteImage() {
    setState(() {
      _avatar = null;
      _avatarUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("[DEBUG] PersonAccount: build CALLED");
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        color: const Color(0xFFC9B7A6),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                readOnly: true,
              ),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(labelText: 'Mobile'),
              ),
              TextFormField(
                controller: _linkedinController,
                decoration: const InputDecoration(labelText: 'LinkedIn'),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  const Text('Avatar', style: TextStyle(fontSize: 16)),
                  const Spacer(),
                  if (_avatar != null)
                    Row(
                      children: [
                        kIsWeb
                            ? Image.network(_avatar!.path, width: 40, height: 40)
                            : Image.file(File(_avatar!.path), width: 40, height: 40),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: _deleteImage,
                        ),
                      ],
                    )
                  else if (_avatarUrl != null)
                    Row(
                      children: [
                        Image.network(_avatarUrl!, width: 40, height: 40),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: _deleteImage,
                        ),
                      ],
                    )
                  else
                    TextButton.icon(
                      icon: const Icon(Icons.add_a_photo),
                      label: const Text('Add'),
                      onPressed: _pickImage,
                    ),
                ],
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _onSave,
                child: const Text('Save'),
              ),
              const SizedBox(height: 16.0),
              InkWell(
                onTap: () async {
                  await _client.auth.signOut();
                },
                child: const Text(
                  'log out',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
