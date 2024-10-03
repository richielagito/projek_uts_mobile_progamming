// profile_edit.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  String profilePictureUrl = ''; // URL to store profile picture
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> uploadProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return; // User canceled the picker

    // Get a reference to Firebase Storage
    final Reference storageRef =
        FirebaseStorage.instance.ref().child('profile_pictures/${image.name}');

    // Upload the image
    await storageRef.putFile(File(image.path));

    // Get the download URL
    String downloadUrl = await storageRef.getDownloadURL();

    // Save the URL in Firestore
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({
        'profile_picture': downloadUrl, // Store the URL in Firestore
      });
    }

    setState(() {
      profilePictureUrl = downloadUrl; // Update local state with the URL
    });
  }

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
            // Profile Picture Upload Section
            GestureDetector(
              onTap: uploadProfilePicture,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: profilePictureUrl.isNotEmpty
                    ? NetworkImage(profilePictureUrl)
                    : null,
                child: profilePictureUrl.isEmpty
                    ? const Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Nama Pengguna', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Enter your name'),
            ),
            const SizedBox(height: 16),
            const Text('Username', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _usernameController,
              decoration:
                  const InputDecoration(hintText: 'Enter your username'),
            ),
            const SizedBox(height: 16),
            const Text('Location', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _locationController,
              decoration:
                  const InputDecoration(hintText: 'Enter your location'),
            ),
            const SizedBox(height: 16),
            const Text('Website', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _websiteController,
              decoration: const InputDecoration(hintText: 'Enter your website'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Handle save action and store other profile data
                User? currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser.uid)
                      .update({
                    'name': _nameController.text,
                    'username': _usernameController.text,
                    'location': _locationController.text,
                    'website': _websiteController.text,
                  });
                }
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
