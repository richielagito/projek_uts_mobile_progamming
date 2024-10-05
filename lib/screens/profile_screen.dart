import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_edit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                FutureBuilder<String>(
                  future: _getCoverImage(),
                  builder: (context, snapshot) {
                    return Container(
                      height: 150,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: snapshot.connectionState ==
                                  ConnectionState.waiting
                              ? const NetworkImage(
                                  'https://via.placeholder.com/500x150')
                              : snapshot.hasData && snapshot.data != null
                                  ? NetworkImage(snapshot.data!)
                                  : const NetworkImage(
                                      'https://via.placeholder.com/500x150'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 100,
                  left: 16,
                  child: FutureBuilder<String>(
                    future: _getProfileImage(),
                    builder: (context, snapshot) {
                      return CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            snapshot.connectionState == ConnectionState.waiting
                                ? const NetworkImage(
                                    'https://via.placeholder.com/100')
                                : snapshot.hasData && snapshot.data != null
                                    ? NetworkImage(snapshot.data!)
                                    : const NetworkImage(
                                        'https://via.placeholder.com/100'),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 120,
                  right: 16,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(176, 88, 238, 0.98),
                      padding: const EdgeInsets.all(20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileEditScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
<<<<<<< HEAD
=======
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
>>>>>>> 6e42a07695503547e55a3360677953c42741c663
              ],
            ),
            const SizedBox(height: 60),
            const UserInfo(),
          ],
        ),
      ),
    );
  }

  Future<String> _getCoverImage() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      return userDoc['cover_photo'] ?? 'https://via.placeholder.com/500x150';
    }
    return 'https://via.placeholder.com/500x150';
  }

  Future<String> _getProfileImage() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      return userDoc['profile_picture'] ?? 'https://via.placeholder.com/100';
    }
    return 'https://via.placeholder.com/100';
  }
}

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  String username = 'Loading...';
  String bio = 'Loading...';

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String userId = currentUser.uid;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          setState(() {
            username = userDoc['username'] ?? '@unknown';
            bio = userDoc['bio'] ?? 'No bio available';
          });
        } else {
          setState(() {
            username = 'No user found';
            bio = 'No bio available';
          });
        }
      } else {
        setState(() {
          username = 'User not logged in';
          bio = 'No bio available';
        });
      }
    } catch (e) {
      setState(() {
        username = 'Error loading username';
        bio = 'Error loading bio';
      });
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align all text to the left
        children: [
          const SizedBox(height: 8),
          Text(
            username,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bio,
            style: const TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
