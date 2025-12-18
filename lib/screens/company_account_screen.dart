import 'package:flutter/material.dart';
import 'package:myapp/widgets/company_account.dart';

class CompanyAccountScreen extends StatelessWidget {
  const CompanyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Company Profile'),
      ),
      body: const SingleChildScrollView(
        child: CompanyAccount(),
      ),
    );
  }
}
