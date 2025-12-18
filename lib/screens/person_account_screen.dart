import 'package:flutter/material.dart';
import 'package:myapp/widgets/person_account.dart';

class PersonAccountScreen extends StatelessWidget {
  const PersonAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Personal Profile'),
      ),
      body: const SingleChildScrollView(
        child: PersonAccount(),
      ),
    );
  }
}
