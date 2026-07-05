import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/note.dart';

class FirestoreService {
  final CollectionReference notesCollection =
      FirebaseFirestore.instance.collection('notes');

  Future<void> createNote(Note note) async {
    final data = note.toMap();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await notesCollection.add(data);
  }

  Stream<List<Note>> getNotes() {
    return notesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Note.fromMap(doc);
      }).toList();
    });
  }

  Stream<Note> getNote(String id) {
    return notesCollection.doc(id).snapshots().map((doc) {
      if (!doc.exists) {
        throw StateError('Note $id does not exist.');
      }
      return Note.fromMap(doc);
    });
  }

  Future<void> updateNote(Note note) async {
    final data = note.toMap();
    data.remove('createdAt');
    data['updatedAt'] = FieldValue.serverTimestamp();
    await notesCollection.doc(note.id).update(data);
  }

  Future<void> deleteNote(String id) async {
    await notesCollection.doc(id).delete();
  }
}
