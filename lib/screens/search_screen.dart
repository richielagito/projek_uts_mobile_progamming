import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _isSearching = false;
  String searchQuery = "";
  List<String> filteredUsernames = [];

  // Real-time search of usernames in Firestore
  Future<void> searchUsernames(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredUsernames.clear();
      });
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username',
              isLessThanOrEqualTo:
                  query + '\uf8ff') // for case-insensitive filtering
          .get();

      final userNamesList =
          querySnapshot.docs.map((doc) => doc['username'].toString()).toList();

      setState(() {
        filteredUsernames = userNamesList;
      });
    } catch (e) {
      print("Error searching usernames: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Search TextField
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: _isSearching
                    ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [],
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    _isSearching = true;
                  });
                  searchUsernames(value); // Trigger real-time search
                },
                onEditingComplete: () {
                  setState(() {
                    _isSearching = false;
                  });
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  hintText: 'Search here...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            // Display filtered usernames
            Expanded(
              child: filteredUsernames.isNotEmpty
                  ? ListView.builder(
                      itemCount: filteredUsernames.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            filteredUsernames[index],
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        searchQuery.isEmpty
                            ? 'Start typing to search...'
                            : 'No users found',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
