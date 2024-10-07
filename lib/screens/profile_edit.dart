import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  String profilePictureUrl = ''; // URL to store profile picture
  String coverPhotoUrl = ''; // URL to store cover photo
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  bool isPicking = false; // Flag to prevent multiple image picking actions

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData(); // Load current user data on screen load
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // Fetch the current user's data to populate fields
  Future<void> _loadCurrentUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            profilePictureUrl =
                (userDoc.data() as Map<String, dynamic>)['profile_picture'] ??
                    '';
            coverPhotoUrl =
                (userDoc.data() as Map<String, dynamic>)['cover_photo'] ?? '';
            _usernameController.text = userDoc['username'] ?? '';
            _bioController.text = userDoc['bio'] ?? '';
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error loading user data: $e');
        }
      }
    }
  }

  Future<void> uploadProfilePicture() async {
    if (isPicking) return; // Prevent picker from being opened multiple times
    setState(() {
      isPicking = true;
    });

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      setState(() {
        isPicking = false; // Reset flag if user cancels
      });
      return; // User canceled the picker
    }

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
      isPicking = false; // Reset flag
    });
  }

  Future<void> uploadCoverPhoto() async {
    if (isPicking) return; // Prevent picker from being opened multiple times
    setState(() {
      isPicking = true;
    });

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      setState(() {
        isPicking = false; // Reset flag if user cancels
      });
      return; // User canceled the picker
    }

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
      isPicking = false; // Reset flag
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white, // Set title color to white
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white, // Set back icon color to white
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.black, // Set background color to black
      body: SingleChildScrollView(
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
                    color: coverPhotoUrl.isEmpty
                        ? const Color.fromARGB(
                            255, 255, 253, 253) // Placeholder color
                        : null,
                    image: coverPhotoUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(coverPhotoUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: coverPhotoUrl.isEmpty
                      ? const Center(
                          child: Text(
                            'Tap to change cover photo',
                            style:
                                TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              // Profile Picture Upload Section
              GestureDetector(
                onTap: uploadProfilePicture,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: profilePictureUrl.isEmpty
                      ? const Color.fromARGB(
                          255, 195, 112, 255) // Placeholder color
                      : null,
                  backgroundImage: profilePictureUrl.isNotEmpty
                      ? NetworkImage(profilePictureUrl)
                      : null,
                  child: profilePictureUrl.isEmpty
                      ? const Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.white, // Icon color for placeholder
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Username',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Enter your username',
                  hintStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bio',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              TextField(
                controller: _bioController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Enter your bio',
                  hintStyle:
                      TextStyle(color: Color.fromARGB(137, 226, 224, 224)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
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
                      'username': _usernameController.text,
                      'bio': _bioController.text,
                    });
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                    255,
                    195,
                    112,
                    255,
                  ),
                  foregroundColor: Colors.white, // Button text color
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
