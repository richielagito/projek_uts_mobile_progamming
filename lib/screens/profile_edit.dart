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
  String coverPhotoUrl = ''; // URL to store cover photo
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData(); // Load current user data on screen load
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Fetch the current user's data to populate fields
  Future<void> _loadCurrentUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          profilePictureUrl = userDoc['profile_picture'] ??
              'https://via.placeholder.com/100'; // Default profile image
          coverPhotoUrl = userDoc['cover_photo'] ??
              'https://via.placeholder.com/500x150'; // Default cover image
          _nameController.text = userDoc['name'] ?? '';
          _usernameController.text = userDoc['username'] ?? '';
          _bioController.text = userDoc['bio'] ?? '';
        });
      }
    }
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

  Future<void> uploadCoverPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return; // User canceled the picker

    // Get a reference to Firebase Storage
    final Reference storageRef =
        FirebaseStorage.instance.ref().child('cover_photos/${image.name}');

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
        'cover_photo': downloadUrl, // Store the URL in Firestore
      });
    }

    setState(() {
      coverPhotoUrl = downloadUrl; // Update local state with the URL
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Photo Upload Section
              GestureDetector(
                onTap: uploadCoverPhoto,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(coverPhotoUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Tap to change cover photo',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
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

              const SizedBox(height: 16),
              const Text('Username', style: TextStyle(fontSize: 18)),
              TextField(
                controller: _usernameController,
                decoration:
                    const InputDecoration(hintText: 'Enter your username'),
              ),
              const SizedBox(height: 16),
              const Text('Bio', style: TextStyle(fontSize: 18)),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(hintText: 'Enter your bio'),
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
                      'bio': _bioController.text,
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
