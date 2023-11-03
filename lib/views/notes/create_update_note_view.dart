import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/extensions/get_arguments.dart';
import 'package:notes/services/crud/crud_service.dart';
import 'package:notes/services/crud/note.dart';
import 'package:notes/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  Note? _note;
  late final CrudService _notesService;
  late final TextEditingController _textController;
  late final TextEditingController _titleController;

  @override
  void initState() {
    _notesService = CrudService.sqlite();
    _textController = TextEditingController();
    _titleController = TextEditingController();
    super.initState();
  }

  Future<Note> createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<Note>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      _titleController.text = widgetNote.title;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    } else {
      final currentUser = AuthService.firebase().currentUser!;
      final userId = currentUser.id;
      final newNote =
          await _notesService.createNote(owner: userId);
      _note = newNote;
      return newNote;
    }
  }

  @override
  void dispose() {
    _deleteNoteIfEmpty();
    _saveNoteIfNotEmpty();
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _deleteNoteIfEmpty() async {
    final note = _note;
    if (_textController.text.isEmpty &&
        _titleController.text.isEmpty &&
        note != null) {
      await _notesService.deleteNote(
        id: note.documentId,
      );
    }
  }

  void _saveNoteIfNotEmpty() async {
    final note = _note;
    if ((_titleController.text.isNotEmpty || _textController.text.isNotEmpty) &&
        note != null) {
      await _notesService.updateNote(
        note: note,
        text: _textController.text,
        title: _titleController.text,
      );
    }
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    } else {
      final text = _textController.text;
      await _notesService.updateNote(
        note: note,
        text: text,
      );
    }
  }

  void _titleControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    } else {
      final title = _titleController.text;
      await _notesService.updateNote(
        note: note,
        title: title,
      );
    }
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
    _titleController.removeListener(_titleControllerListener);
    _titleController.addListener(_titleControllerListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
        actions: [
          IconButton(
            onPressed: () async {
              final text = _textController.text;
              final title = _titleController.text;
              if (text.isEmpty && title.isEmpty) {
                await cannotShareEmptyNoteDialog(context);
              } else if (text.isEmpty) {
                Share.share(title);
              } else if (title.isEmpty) {
                Share.share(text);
              } else {
                Share.share(
                  Note(
                    documentId: "documentId",
                    ownerId: "ownerId",
                    title: title,
                    text: text,
                  ).toString(),
                );
              }
            },
            icon: const Icon(Icons.share),
          )
        ],
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              //_note is set in createOrGetExistingNote()
              //_note = snapshot.data as CloudNote;
              _setupTextControllerListener();
              return Column(
                children: [
                  TextField(
                    controller: _titleController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration:
                        const InputDecoration(hintText: "Enter the title here"),
                  ),
                  TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText: "Enter the content here"),
                  ),
                ],
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
