import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projek_uts_mobile_progamming/screens/searchprofile_screen.dart'; // Pastikan untuk mengimpor SearchProfileScreen

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _isSearching = false;
  String searchQuery = "";
  List<String> filteredUsernames = [];

  Future<void> searchUsernames(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredUsernames.clear();
      });
      return;
    }

    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      final allUsernames =
          querySnapshot.docs.map((doc) => doc['username'].toString()).toList();

      final lowerQuery = query.toLowerCase();
      final List<String> exactMatches = [];
      final List<String> startsWithMatches = [];
      final List<String> containsMatches = [];

      for (final username in allUsernames) {
        final lowerUsername = username.toLowerCase();
        if (lowerUsername == lowerQuery || username == query) {
          exactMatches.add(username);
        } else if (lowerUsername.startsWith(lowerQuery) ||
            username.startsWith(query)) {
          startsWithMatches.add(username);
        } else if (lowerUsername.contains(lowerQuery) ||
            username.contains(query)) {
          containsMatches.add(username);
        }
      }

      // Urutkan hasil berdasarkan prioritas
      startsWithMatches.sort((a, b) {
        final aLower = a.toLowerCase();
        final bLower = b.toLowerCase();
        if (aLower[0] != bLower[0]) {
          return aLower.compareTo(bLower);
        }
        if (a.length > 1 && b.length > 1) {
          if (a[1].toLowerCase() != b[1].toLowerCase()) {
            return a[1].toLowerCase().compareTo(b[1].toLowerCase());
          }
          if (a[1] != b[1]) {
            return a[1].compareTo(b[1]);
          }
        }
        return a.compareTo(b);
      });

      setState(() {
        filteredUsernames = [
          ...exactMatches,
          ...startsWithMatches,
          ...containsMatches,
        ];
      });
    } catch (e) {
      // ignore: avoid_print
      print("Error searching usernames: $e");
    }
  }

  void _navigateToSearchProfileScreen(String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchProfileScreen(username: username),
      ),
    );
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
            color: Colors.white,
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
                          onTap: () => _navigateToSearchProfileScreen(
                              filteredUsernames[index]),
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
