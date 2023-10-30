import 'package:flutter/material.dart';
//import 'dart:developer' as devtools show log;

import 'package:notes/constants/routes.dart';
import 'package:notes/enums/menu_action.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/services/crud/crud_exceptions.dart';
import 'package:notes/services/crud/notes_service.dart';
import 'package:notes/utilities/dialogs/show_logout_dialog.dart';
import 'package:notes/views/notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email;

  @override
  void initState() {
    _notesService = NotesService();
    try {
      _notesService.open();
    } on DatabaseAlreadyOpenException {}

    super.initState();
  }

  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              //devtools.log(value.toString());
              switch (value) {
                case MenuAction.logout:
                  final shouldLogOut = await showLogOutDialogue(context);
                  //devtools.log(shouldLogOut.toString());
                  if (shouldLogOut) {
                    await AuthService.firebase().logOut();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (route) => false,
                    );
                  }
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text("Log Out"),
                )
              ];
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                stream: _notesService.allNotes,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if (snapshot.hasData) {
                          final allNotes = snapshot.data as List<DatabaseNote>;
                          return NotesListView(
                            allNotes: allNotes,
                            onDeleteNote: (note) async {
                              await _notesService.deleteNote(id: note.id);
                            },
                            onTap: (note) async {
                              Navigator.of(context).pushNamed(
                                  createOrUpdateNoteRoute,
                                  arguments: note);
                            },
                          );
                      } else {
                        return const CircularProgressIndicator();
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                },
              );
            default:
              return const Column(
                children: [
                  Center(
                    child: CircularProgressIndicator(),
                  )
                ],
              );
          }
        },
      ),
    );
  }
}
