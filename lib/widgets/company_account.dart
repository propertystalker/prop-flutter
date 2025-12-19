import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/models/company.dart';
import 'package:myapp/services/supabase_service.dart';
import 'package:provider/provider.dart';

class CompanyAccount extends StatefulWidget {
  const CompanyAccount({super.key});

  @override
  State<CompanyAccount> createState() => _CompanyAccountState();
}

class _CompanyAccountState extends State<CompanyAccount> {
  final _formKey = GlobalKey<FormState>();
  late final SupabaseService _supabaseService;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _twitterController = TextEditingController();
  XFile? _companyLogo;

  @override
  void initState() {
    super.initState();
    _supabaseService = Provider.of<SupabaseService>(context, listen: false);
    // Removed the problematic call to _getCompanyProfile()
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _twitterController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final user = _supabaseService.client.auth.currentUser;
      if (user != null) {
        final company = Company(
          id: user.id,
          name: _nameController.text,
          email: _emailController.text,
        );

        try {
          await _supabaseService.updateCompany(company);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Company profile saved!')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving company profile: $e')),
            );
          }
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _companyLogo = pickedFile;
      });
    }
  }

  void _deleteImage() {
    setState(() {
      _companyLogo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: const Color(0xFFF0F4F8),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Company Name'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Enquiry Email'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Company Phone Number'),
              ),
              TextFormField(
                controller: _twitterController,
                decoration: const InputDecoration(labelText: 'Company X Page'),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  const Text('Company Logo', style: TextStyle(fontSize: 16)),
                  const Spacer(),
                  if (_companyLogo != null)
                    Row(
                      children: [
                        kIsWeb
                            ? Image.network(_companyLogo!.path, width: 40, height: 40)
                            : Image.file(File(_companyLogo!.path), width: 40, height: 40),
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
              Center(
                child: ElevatedButton(
                  onPressed: _onSave,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
