import 'package:cloud_firestore/cloud_firestore.dart';

class Thread {
  final String id;
  final String content;
  final DateTime createdAt;
  final String userId;
  final String? imageUrl;

  Thread({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.userId,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
      'imageUrl': imageUrl,
    };
  }

  factory Thread.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Thread(
      id: doc.id,
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }
}
