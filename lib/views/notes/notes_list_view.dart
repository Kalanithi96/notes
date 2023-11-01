import 'package:flutter/material.dart';
import 'package:notes/services/cloud/cloud_note.dart';
import 'package:notes/utilities/dialogs/show_delete_dialog.dart';

typedef NoteCAllBack = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  const NotesListView({
    super.key,
    required this.allNotes,
    required this.onDeleteNote,
    required this.onTap
  });

  final Iterable<CloudNote> allNotes;
  final NoteCAllBack onDeleteNote;
  final NoteCAllBack onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: allNotes.length,
      itemBuilder: (context, index) {
        final note = allNotes.elementAt(index);
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
          onTap: (){
            onTap(note);
          },
        );
      },
    );
  }
}
