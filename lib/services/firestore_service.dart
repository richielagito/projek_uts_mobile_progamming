import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/thread_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addThread(Thread thread) async {
    await _firestore.collection('threads').add(thread.toMap());
  }

  Stream<List<Thread>> getThreads() {
    return _firestore
        .collection('threads')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Thread.fromFirestore(doc)).toList();
    });
  }

  Future<String?> uploadImage(File image) async {
    try {
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference ref = _storage.ref().child('thread_images/$fileName');
      final UploadTask uploadTask = ref.putFile(image);
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> addThreadWithImage(
      String content, String userId, File? image) async {
    String? imageUrl;
    if (image != null) {
      imageUrl = await uploadImage(image);
    }
    final thread = Thread(
      id: '',
      content: content,
      createdAt: DateTime.now(),
      userId: userId,
      imageUrl: imageUrl,
    );
    await addThread(thread);
  }
}
