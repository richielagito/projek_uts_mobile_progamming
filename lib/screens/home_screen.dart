import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projek_uts_mobile_progamming/screens/post_thread_screen.dart';
// ignore: unused_import
import 'package:projek_uts_mobile_progamming/models/thread_model.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Thread {
  String id;
  String userId;
  String content;
  DateTime createdAt;
  String? imageUrl;
  int likes;
  int retweets;
  List<String> likedBy;
  List<String> retweetedBy;

  Thread({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.imageUrl,
    required this.likes, // Tambahkan ini
    required this.retweets, // Tambahkan ini
    this.likedBy = const [],
    this.retweetedBy = const [],
  });

  factory Thread.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Thread(
      id: doc.id,
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      likes: (data['likes'] is int) ? data['likes'] : 0, // Handle type mismatch
      retweets: (data['retweets'] is int) ? data['retweets'] : 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      retweetedBy:
          List<String>.from(data['retweetedBy'] ?? []), // Handle type mismatch
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<String> getUsername(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userDoc['username'] as String;
    } catch (e) {
      print('Error fetching username: $e');
      return 'Unknown User';
    }
  }

  String formatTimestamp(DateTime timestamp) {
    return DateFormat('dd MMMM yyyy, HH:mm').format(timestamp);
  }

  Future<void> _handleLike(Thread thread) async {
    if (currentUser == null) return;

    if (thread.likedBy.contains(currentUser!.uid)) {
      // Unlike the post
      setState(() {
        thread.likes -= 1;
        thread.likedBy.remove(currentUser!.uid);
      });

      await FirebaseFirestore.instance
          .collection('threads')
          .doc(thread.id)
          .update({
        'likes': thread.likes,
        'likedBy': FieldValue.arrayRemove([currentUser!.uid]), // Remove user ID
      });
    } else {
      // Like the post
      setState(() {
        thread.likes += 1;
        thread.likedBy.add(currentUser!.uid);
      });

      await FirebaseFirestore.instance
          .collection('threads')
          .doc(thread.id)
          .update({
        'likes': thread.likes,
        'likedBy': FieldValue.arrayUnion([currentUser!.uid]), // Add user ID
      });
    }
  }

  Future<void> _handleRetweet(Thread thread) async {
    if (currentUser == null) return;

    if (thread.retweetedBy.contains(currentUser!.uid)) {
      // Unretweet the post
      setState(() {
        thread.retweets -= 1;
        thread.retweetedBy.remove(currentUser!.uid);
      });

      await FirebaseFirestore.instance
          .collection('threads')
          .doc(thread.id)
          .update({
        'retweets': thread.retweets,
        'retweetedBy':
            FieldValue.arrayRemove([currentUser!.uid]), // Remove user ID
      });
    } else {
      // Retweet the post
      setState(() {
        thread.retweets += 1;
        thread.retweetedBy.add(currentUser!.uid);
      });

      await FirebaseFirestore.instance
          .collection('threads')
          .doc(thread.id)
          .update({
        'retweets': thread.retweets,
        'retweetedBy': FieldValue.arrayUnion([currentUser!.uid]), // Add user ID
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.black,
        title: const SizedBox(
          height: 50,
          width: 120,
          child: Image(image: AssetImage('assets/images/img1.png')),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey.shade700,
            height: 1,
            width: MediaQuery.of(context).size.width,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('threads')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text('No threads yet',
                          style: TextStyle(color: Colors.white)));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var thread =
                        Thread.fromFirestore(snapshot.data!.docs[index]);
                    return FutureBuilder<String>(
                      future: getUsername(thread.userId),
                      builder: (context, usernameSnapshot) {
                        if (usernameSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        return _listItem(
                            thread, usernameSnapshot.data ?? 'Unknown User');
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const PostThreadScreen(),
          ));
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _listItem(Thread thread, String username) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage('assets/profile.png'),
                radius: 30,
              ),
              title: Text(
                username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                thread.content,
                overflow: TextOverflow.clip,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            if (thread.imageUrl != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  thread.imageUrl!,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                formatTimestamp(thread.createdAt),
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                //tombol untuk like
                IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: thread.likes > 0 ? Colors.red : Colors.white,
                  ),
                  onPressed: () async {
                    await _handleLike(
                        thread); // Call the existing _handleLike method
                  },
                ),
                Text(
                  '${thread.likes} Likes',
                  style: TextStyle(color: Colors.white),
                ),

                // Tombol untuk Retweet
                IconButton(
                  icon: Icon(
                    Icons.repeat,
                    color: thread.retweets > 0 ? Colors.green : Colors.white,
                  ),
                  onPressed: () async {
                    await _handleRetweet(
                        thread); // Call the async function properly
                  },
                ),
                Text(
                  '${thread.retweets} Retweets',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  '${thread.retweets} Retweets',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
