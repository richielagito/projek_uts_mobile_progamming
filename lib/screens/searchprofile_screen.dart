import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchProfileScreen extends StatelessWidget {
  final String username;

  const SearchProfileScreen({Key? key, required this.username})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                FutureBuilder<String>(
                  future: _getCoverImage(username),
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
                    future: _getProfileImage(username),
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
              ],
            ),
            const SizedBox(height: 60),
            UserInfo(username: username),
          ],
        ),
      ),
    );
  }

  Future<String> _getCoverImage(String username) async {
    try {
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userQuery.docs.first;
        return userDoc['cover_photo'] ?? 'https://via.placeholder.com/500x150';
      }
    } catch (e) {
      print('Error fetching cover image: $e');
    }
    return 'https://via.placeholder.com/500x150';
  }

  Future<String> _getProfileImage(String username) async {
    try {
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userQuery.docs.first;
        return userDoc['profile_picture'] ?? 'https://via.placeholder.com/100';
      }
    } catch (e) {
      print('Error fetching profile image: $e');
    }
    return 'https://via.placeholder.com/100';
  }
}

class UserInfo extends StatefulWidget {
  final String username;
  const UserInfo({Key? key, required this.username}) : super(key: key);

  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  String bio = 'Loading...';

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    try {
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: widget.username)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        DocumentSnapshot userDoc = userQuery.docs.first;
        setState(() {
          bio = userDoc['bio'] ?? 'No bio available';
        });
      } else {
        setState(() {
          bio = 'No bio available';
        });
      }
    } catch (e) {
      setState(() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            widget.username,
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
