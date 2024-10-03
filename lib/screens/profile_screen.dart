import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth for getting the current user
import 'profile_edit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 150,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/500x150'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const UserInfo(),
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
  String name = 'Loading...';
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
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage('https://via.placeholder.com/100'),
          ),
          const SizedBox(height: 16),
          Text(
            username,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(location,
                  style: const TextStyle(
                      color: Colors.grey)), // Displaying the location
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
                  color: Color.fromARGB(255, 34, 38, 243),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileEditScreen(),
                ),
              );
            },
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }
}
