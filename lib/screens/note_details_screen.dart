import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/firestore_service.dart';
import 'add_edit_note_screen.dart';

class NoteDetailsScreen extends StatelessWidget {
  final Note note;

  const NoteDetailsScreen({super.key, required this.note});

  Future<void> _confirmAndDelete(BuildContext context) async {
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

    if (shouldDelete != true) return;

    final service = FirestoreService();
    await service.deleteNote(note.id!);

    if (!context.mounted) return;
    Navigator.pop(context);
  }

  void _openEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditNoteScreen(note: note),
      ),
    );
  }

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'Not available';
    final day = date.day.toString().padLeft(2, '0');
    final month = _monthNames[date.month - 1];
    final year = date.year.toString();

    final hour24 = date.hour;
    final hour12Raw = hour24 % 12;
    final hour12 = hour12Raw == 0 ? 12 : hour12Raw;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour24 < 12 ? 'AM' : 'PM';

    return '$day $month $year, $hour12:$minute $period';
  }

  Widget _metaRow(BuildContext context, {
    required String label,
    required String value,
  }) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: muted,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      note.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _metaRow(
              context,
              label: 'Created',
              value: _formatDateTime(note.createdAt),
            ),
            _metaRow(
              context,
              label: 'Last updated',
              value: _formatDateTime(note.updatedAt),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openEdit(context),
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _confirmAndDelete(context),
              icon: const Icon(Icons.delete),
              label: const Text('Delete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
