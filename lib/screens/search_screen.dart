import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool _isSearching = false;

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
                onTap: () {
                  setState(() {
                    _isSearching = true;
                  });
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
                      color: Colors.blue, // Changed to blue
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            // Search Button with shadow effect
            ElevatedButton(
              onPressed: () {
                // Handle search button press
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Changed to blue
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 60.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 12,
                shadowColor: Colors.blueAccent, // Changed to blueAccent
              ),
              child: const Text(
                'Search',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            // A little fading message or instruction
            AnimatedOpacity(
              opacity: _isSearching ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 500),
              child: const Text(
                'Type something to search...',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
