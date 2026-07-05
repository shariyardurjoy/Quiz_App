import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String? id;
  final String title;
  final String description;
  final String category;

  Note({
    this.id,
    required this.title,
    required this.description,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
    };
  }

  factory Note.fromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'General',
    );
  }
}
