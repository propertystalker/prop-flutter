import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/property.dart';

class CreateReportScreen extends StatefulWidget {
  final Property property;

  const CreateReportScreen({super.key, required this.property});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _fromController = TextEditingController(text: 'mike@belvoragency.com');
  final _toController = TextEditingController(text: 'mrslad@gmail.com');
  final _ccController = TextEditingController(text: 'chris@goldentrustcapital.co.uk');
  bool _inviteToSetup = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create & Send Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('31 BEECH ROAD, CAMBRIDGE, CB1 3AZ', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Center(child: Text('£373k', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.blue))),
            const SizedBox(height: 24),
            const Text('Create & Send Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _fromController,
              decoration: const InputDecoration(
                labelText: 'From',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _toController,
              decoration: const InputDecoration(
                labelText: 'To',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ccController,
              decoration: const InputDecoration(
                labelText: 'CC',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _inviteToSetup,
                  onChanged: (value) {
                    setState(() {
                      _inviteToSetup = value ?? false;
                    });
                  },
                ),
                const Text('Also invite to set up account'),
              ],
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  context.push('/report_sent');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
                child: const Text('Send'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
