import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_edit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = 'Profil';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          username =
              (userDoc.data() as Map<String, dynamic>)['username'] ?? 'Profil';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Logout functionality
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          setState(() {
            username = userData['username'] ?? '@tidak dikenal';
            bio = userData['bio'] ?? 'Belum ada bio';
          });
        } else {
          setState(() {
            username = 'Pengguna tidak ditemukan';
            bio = 'Belum ada bio';
          });
        }
      } else {
        setState(() {
          username = 'Pengguna belum masuk';
          bio = 'Belum ada bio';
        });
      }
    } catch (e) {
      print('Error mengambil data pengguna: $e');
      setState(() {
        username = 'Gagal memuat username';
        bio = 'Gagal memuat bio';
      });
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
