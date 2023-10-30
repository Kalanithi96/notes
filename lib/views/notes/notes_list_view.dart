import 'package:flutter/material.dart';
import 'package:notes/services/crud/notes_service.dart';
import 'package:notes/utilities/dialogs/show_delete_dialog.dart';

typedef DeleteNoteCAllBack = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  const NotesListView({
    super.key,
    required this.allNotes,
    required this.onDeleteNote,
  });

  final List<DatabaseNote> allNotes;
  final DeleteNoteCAllBack onDeleteNote;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: allNotes.length,
      itemBuilder: (context, index) {
        final note = allNotes[index];
        final display = (note.title == '') ? note.text : note.title;
        return ListTile(
          title: Text(
            display,
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if(shouldDelete){
                onDeleteNote(note);
              }
            },
          ),
        );
      },
    );
  }
}
