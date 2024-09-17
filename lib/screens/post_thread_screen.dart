import 'package:flutter/material.dart';
import 'package:projek_uts_mobile_progamming/screens/main_screen.dart';

class PostThreadScreen extends StatefulWidget {
  @override
  _PostThreadScreenState createState() => _PostThreadScreenState();
}

class _PostThreadScreenState extends State<PostThreadScreen> {
  final TextEditingController _postController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ),
          ),
        ),
        title: const Text('New Thread', style: TextStyle(color: Colors.white)),
        actions: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ElevatedButton(
              onPressed: _postController.text.isNotEmpty
                  ? () {
                      // Implementasi logika posting di sini
                      print('Posting: ${_postController.text}');
                      Navigator.of(context).pop();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _postController.text.isNotEmpty
                    ? Colors.blue
                    : Colors.grey.withOpacity(0.5),
                foregroundColor: _postController.text.isNotEmpty
                    ? Colors.white
                    : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Post'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _postController,
              maxLines: null,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'What is happening?',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              onChanged: (text) {
                setState(() {}); // Memicu rebuild untuk mengupdate tombol Post
              },
            ),
          ),
          Divider(height: 1, color: Colors.grey[800]),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.image, color: Colors.blue),
                SizedBox(width: 16),
                Icon(Icons.gif_box, color: Colors.blue),
                SizedBox(width: 16),
                Icon(Icons.list_alt, color: Colors.blue),
                SizedBox(width: 16),
                Icon(Icons.location_on, color: Colors.blue),
                Spacer(),
                Text('Everyone can reply',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }
}
