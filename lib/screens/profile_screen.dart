import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth for getting the current user
import 'profile_edit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Black background for dark mode
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none, // This allows the avatar to overflow
              children: [
                // Cover image
                Container(
                  height: 150,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://via.placeholder.com/500x150'), // Replace with actual cover image URL
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Positioned profile image to overlap with the cover image and bio
                Positioned(
                  top: 100, // Adjust this value to move the avatar up or down
                  left: 16, // Adjust for avatar's horizontal position
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                        'https://via.placeholder.com/100'), // Replace with actual profile image URL
                  ),
                ),
                // Positioned Edit Profile button on the top-right corner
                Positioned(
                    top: 120, // Adjust for vertical positioning
                    right: 16, // Adjust for horizontal positioning
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                            250, 176, 88, 238), // Button color
                        padding: const EdgeInsets.all(20), // Increase hit area
                      ),
                      onPressed: () {
                        print("Edit Profile button pressed");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileEditScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Edit Profile',
                        style: TextStyle(color: Colors.white), // Text color
                      ),
                    )),
              ],
            ),
            const SizedBox(
                height: 60), // To compensate for the overlap of the avatar
            const UserInfo(), // Your user info content below
          ],
        ),
      ),
    );
  }
}

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  String username = 'Loading...';
  String location = 'Loading...'; // Assuming you'll fetch this too
  String website = 'Loading...'; // Assuming you'll fetch this too

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      // Get the current user's ID
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String userId = currentUser.uid; // Get the user's UID

        // Query Firestore collection for the user document
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          setState(() {
            username = userDoc['username'] ?? '@unknown'; // Get username
            // name = userDoc['name'] ?? 'No Name'; // Get name
            // location = userDoc['location'] ?? 'No Location'; // Get location
            // website = userDoc['website'] ?? 'No Website'; // Get website
          });
        } else {
          setState(() {
            username = 'No user found';
            // name = 'No user found';
            // location = 'No Location';
            // website = 'No Website';
          });
        }
      } else {
        setState(() {
          username = 'User not logged in';
          // name = 'User not logged in';
          // location = 'No Location';
          // website = 'No Website';
        });
      }
    } catch (e) {
      setState(() {
        username = 'Error loading username';
        // name = 'Error loading name';
        // location = 'No Location';
        // website = 'No Website';
      });
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            username,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white, // White text for dark mode
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                location,
                style: const TextStyle(
                  color: Colors.grey, // Grey text for location
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.link, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                website,
                style: const TextStyle(
                  color: Color.fromRGBO(176, 101, 255, 1), // Blue for links
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
