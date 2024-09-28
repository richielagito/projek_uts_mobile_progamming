import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, String>> tweets = const [
    {
      "username": "Geda.Gedi",
      "tweet": "Hello this is Geda Gedi.",
      "profilepic": "assets/profile.png"
    },
    {
      "username": "John",
      "tweet": "having fun right now!",
      "profilepic": "assets/profile.png"
    },
    {
      "username": "flutterrr",
      "tweet": "just discovered a cool thing!",
      "profilepic": "assets/profile.png"
    }
  ];

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
            child: ListView.builder(
              itemCount: tweets.length,
              itemBuilder: (context, index) {
                return _listItem(index, tweets[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _listItem(int index, Map<String, String> tweet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        color: Colors.black,
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(tweet['profilepic']!),
            radius: 30, // Profile size
          ),
          title: Text(
            tweet['Geda.Gedi']!, //simulated username
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            tweet['Hello, this is geda gedi']!,
            overflow: TextOverflow.clip,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
