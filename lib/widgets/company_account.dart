import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/controllers/company_controller.dart';

class CompanyAccount extends StatefulWidget {
  const CompanyAccount({super.key});

  @override
  State<CompanyAccount> createState() => _CompanyAccountState();
}

class _CompanyAccountState extends State<CompanyAccount> {
  final _formKey = GlobalKey<FormState>();
  late final CompanyController _companyController;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _twitterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _companyController = Provider.of<CompanyController>(context, listen: false);
    _getCompanyProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _twitterController.dispose();
    super.dispose();
  }

  Future<void> _getCompanyProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Assuming a company profile is linked to a user
      final data = await Supabase.instance.client
          .from('companies')
          .select()
          .eq('user_id', user.id)
          .single();

      if (data != null) {
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _twitterController.text = data['twitter'] ?? '';
        // TODO: Load logo URL and update controller
      }
    }
  }

  Future<void> _onSave() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final updates = {
          'user_id': user.id,
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'twitter': _twitterController.text,
          'updated_at': DateTime.now().toIso8601String(),
        };

        await Supabase.instance.client.from('companies').upsert(updates);

        if (mounted) {
          _companyController.setCompanyName(_nameController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Company profile saved!')),
          );
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _companyController.setCompanyLogo(pickedFile);
      // TODO: Upload to Supabase Storage and save URL
    }
  }

  void _deleteImage() {
    // TODO: Delete from Supabase Storage
    _companyController.deleteCompanyLogo();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: const Color(0xFFF0F4F8), // A light grey background
      child: Form(
        key: _formKey,
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
                if (_companyController.companyLogo != null)
                  Row(
                    children: [
                      kIsWeb
                          ? Image.network(_companyController.companyLogo!.path,
                              width: 40, height: 40)
                          : Image.file(File(_companyController.companyLogo!.path),
                              width: 40, height: 40),
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
    );
  }
}
