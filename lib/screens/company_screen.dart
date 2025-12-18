import 'package:flutter/material.dart';
import 'package:myapp/widgets/company_account.dart';

class CompanyScreen extends StatelessWidget {
  const CompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Profile'),
      ),
      body: const CompanyAccount(),
    );
  }
}
