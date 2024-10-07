import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projek_uts_mobile_progamming/screens/post_thread_screen.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg

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
  List<Map<String, dynamic>> comments;

  Thread({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.imageUrl,
    required this.likes,
    required this.retweets,
    this.likedBy = const [],
    this.retweetedBy = const [],
    this.comments = const [],
  });

  factory Thread.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Thread(
      id: doc.id,
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'],
      likes: (data['likes'] is int) ? data['likes'] : 0,
      retweets: (data['retweets'] is int) ? data['retweets'] : 0,
      likedBy: List<String>.from(data['likedBy'] ?? []),
      retweetedBy: List<String>.from(data['retweetedBy'] ?? []),
      comments: List<Map<String, dynamic>>.from(data['comments'] ?? []),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<Map<String, String>> getUserInfo(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

    return {
      'username': userData['username'] ?? 'Unknown User',
      'profileImage':
          userData['profile_picture'] ?? 'assets/images/default_pfp.svg',
    };
  }

  String formatTimestamp(DateTime timestamp) {
    return DateFormat('dd MMMM yyyy, HH:mm').format(timestamp);
  }

  Future<void> _handleLike(Thread thread) async {
    if (currentUser == null) return;

    final bool isLiked = thread.likedBy.contains(currentUser!.uid);
    final int newLikesCount = isLiked ? thread.likes - 1 : thread.likes + 1;
    final FieldValue likedByUpdate = isLiked
        ? FieldValue.arrayRemove([currentUser!.uid])
        : FieldValue.arrayUnion([currentUser!.uid]);

    setState(() {
      thread.likes = newLikesCount;
      isLiked
          ? thread.likedBy.remove(currentUser!.uid)
          : thread.likedBy.add(currentUser!.uid);
    });

    await FirebaseFirestore.instance
        .collection('threads')
        .doc(thread.id)
        .update({
      'likes': newLikesCount,
      'likedBy': likedByUpdate,
    });
  }

  Future<void> _handleComment(Thread thread, String commentContent) async {
    if (currentUser == null || commentContent.isEmpty) return;

    final comment = {
      'userId': currentUser!.uid,
      'comment': commentContent,
    };

    setState(() {
      thread.comments.add(comment);
    });

    await FirebaseFirestore.instance
        .collection('threads')
        .doc(thread.id)
        .update({
      'comments': FieldValue.arrayUnion([comment]),
    });
  }

  Future<void> _handleRetweet(Thread thread) async {
    if (currentUser == null) return;

    final bool isRetweeted = thread.retweetedBy.contains(currentUser!.uid);
    final int newRetweetCount =
        isRetweeted ? thread.retweets - 1 : thread.retweets + 1;
    final FieldValue retweetedByUpdate = isRetweeted
        ? FieldValue.arrayRemove([currentUser!.uid])
        : FieldValue.arrayUnion([currentUser!.uid]);

    setState(() {
      thread.retweets = newRetweetCount;
      isRetweeted
          ? thread.retweetedBy.remove(currentUser!.uid)
          : thread.retweetedBy.add(currentUser!.uid);
    });

    await FirebaseFirestore.instance
        .collection('threads')
        .doc(thread.id)
        .update({
      'retweets': newRetweetCount,
      'retweetedBy': retweetedByUpdate,
    });
  }

  void _showCommentDialog(Thread thread) {
    String commentContent = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a Comment'),
        content: TextField(
          onChanged: (value) => commentContent = value,
          decoration: const InputDecoration(hintText: "Type your comment here"),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Post'),
            onPressed: () async {
              await _handleComment(thread, commentContent);
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showAllCommentsDialog(BuildContext context, Thread thread) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Semua Komentar'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: thread.comments.length,
            itemBuilder: (context, index) {
              var comment = thread.comments[index];
              return FutureBuilder<Map<String, String>>(
                future: getUserInfo(comment['userId']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final userInfo = snapshot.data ??
                      {
                        'username': 'Unknown User',
                        'profileImage': 'assets/images/default_pfp.svg',
                      };
                  return ListTile(
                    leading: userInfo['profileImage']!.isNotEmpty
                        ? CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                NetworkImage(userInfo['profileImage']!),
                          )
                        : CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.transparent,
                            child: SvgPicture.asset(
                              'assets/images/default_pfp.svg',
                              width: 40,
                              height: 40,
                            ),
                          ),
                    title: Text(userInfo['username']!,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(comment['comment']),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Tutup'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
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
                        style: TextStyle(color: Colors.white)),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var thread =
                        Thread.fromFirestore(snapshot.data!.docs[index]);
                    return _listItem(thread);
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
        backgroundColor: const Color.fromRGBO(176, 88, 238, 0.98),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _listItem(Thread thread) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 56, 54, 54),
          border: Border.all(color: Colors.grey.shade700, width: 1.0),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, String>>(
              future: getUserInfo(thread.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  );
                }
                final userInfo = snapshot.data ??
                    {
                      'username': 'Unknown User',
                      'profileImage': 'assets/images/default_pfp.svg',
                    };
                return ListTile(
                  leading: userInfo['profileImage']!.isNotEmpty
                      ? CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              NetworkImage(userInfo['profileImage']!),
                        )
                      : CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.transparent,
                          child: SvgPicture.asset(
                            'assets/images/default_pfp.svg',
                            width: 60,
                            height: 60,
                          ),
                        ),
                  title: Text(
                    userInfo['username']!,
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
                );
              },
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 8.0),
                    child: Text(
                      formatTimestamp(thread.createdAt),
                      style:
                          const TextStyle(fontSize: 12.0, color: Colors.grey),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(
                          thread.likedBy.contains(currentUser?.uid)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: thread.likedBy.contains(currentUser?.uid)
                              ? Colors.red
                              : Colors.white,
                        ),
                        onPressed: () => _handleLike(thread),
                      ),
                      Text('${thread.likes}',
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.mode_comment_outlined,
                            color: Colors.white),
                        onPressed: () => _showCommentDialog(thread),
                      ),
                      Text('${thread.comments.length}',
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(
                          thread.retweetedBy.contains(currentUser?.uid)
                              ? Icons.repeat
                              : Icons.repeat_outlined,
                          color: thread.retweetedBy.contains(currentUser?.uid)
                              ? Colors.green
                              : Colors.white,
                        ),
                        onPressed: () => _handleRetweet(thread),
                      ),
                      Text('${thread.retweets}',
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            if (thread.comments.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _showAllCommentsDialog(context, thread),
                      child: Text(
                        'Lihat semua ${thread.comments.length} komentar',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                    ...thread.comments.take(2).map((comment) {
                      return FutureBuilder<Map<String, String>>(
                        future: getUserInfo(comment['userId']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox();
                          }
                          final userInfo = snapshot.data ??
                              {
                                'username': 'Unknown User',
                                'profileImage': 'assets/images/default_pfp.svg',
                              };
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                userInfo['profileImage']!.isNotEmpty
                                    ? CircleAvatar(
                                        radius: 15,
                                        backgroundImage: NetworkImage(
                                            userInfo['profileImage']!),
                                      )
                                    : CircleAvatar(
                                        radius: 15,
                                        backgroundColor: Colors.transparent,
                                        child: SvgPicture.asset(
                                          'assets/images/default_pfp.svg',
                                          width: 30,
                                          height: 30,
                                        ),
                                      ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${userInfo['username']} ',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        TextSpan(
                                          text: comment['comment'] ?? '',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                      // ignore: unnecessary_to_list_in_spreads
                    }).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
