import 'dart:async';

import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/firestore_service.dart';
import 'add_edit_note_screen.dart';

const List<String> filterCategories = [
  'All',
  'General',
  'Study',
  'Work',
  'Personal',
  'Ideas',
  'Shopping',
];

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final FirestoreService _service = FirestoreService();
  late final Stream<List<Note>> _notesStream;

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _query = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _notesStream = _service.getNotes();
    _searchController.addListener(() {
      if (_query != _searchController.text) {
        setState(() => _query = _searchController.text);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Note> _filter(List<Note> notes, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return notes;
    return notes.where((n) {
      return n.title.toLowerCase().contains(q) ||
          n.description.toLowerCase().contains(q);
    }).toList();
  }

  List<Note> _applyFilters(List<Note> notes) {
    final byCategory = _selectedCategory == 'All'
        ? notes
        : notes.where((n) => n.category == _selectedCategory).toList();
    return _filter(byCategory, _query);
  }

  Future<void> _confirmDelete(Note note) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text(
            'Are you sure you want to delete this note?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _service.deleteNote(note.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            tooltip: _isSearching ? 'Close search' : 'Search',
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _query = '';
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: filterCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = filterCategories[index];
                final isSelected = _selectedCategory == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              },
            ),
          ),
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                ),
                textInputAction: TextInputAction.search,
              ),
            ),
          Expanded(
            child: StreamBuilder<List<Note>>(
              stream: _notesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      snapshot.error.toString(),
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final notes = snapshot.data ?? const <Note>[];

                if (notes.isEmpty) {
                  return const Center(child: Text('No notes yet'));
                }

                final filteredNotes = _applyFilters(notes);

                if (filteredNotes.isEmpty) {
                  final message = _selectedCategory == 'All'
                      ? 'No matching notes found.'
                      : 'No notes found in this category.';
                  return Center(child: Text(message));
                }

                return ListView.builder(
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          note.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          note.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditNoteScreen(note: note),
                            ),
                          );
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _confirmDelete(note),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditNoteScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
