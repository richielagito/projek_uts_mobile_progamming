// profile_edit.dart
import 'package:flutter/material.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nama Pengguna', style: TextStyle(fontSize: 18)),
            TextField(
              decoration: const InputDecoration(hintText: 'Enter your name'),
            ),
            const SizedBox(height: 16),
            const Text('Username', style: TextStyle(fontSize: 18)),
            TextField(
              decoration:
                  const InputDecoration(hintText: 'Enter your username'),
            ),
            const SizedBox(height: 16),
            const Text('Location', style: TextStyle(fontSize: 18)),
            TextField(
              decoration:
                  const InputDecoration(hintText: 'Enter your location'),
            ),
            const SizedBox(height: 16),
            const Text('Website', style: TextStyle(fontSize: 18)),
            TextField(
              decoration: const InputDecoration(hintText: 'Enter your website'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Handle save action
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
