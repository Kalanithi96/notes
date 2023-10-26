import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:notes/constants/routes.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        actions: [
          PopupMenuButton<MenuAction>(onSelected: (value) async {
            devtools.log(value.toString());
            switch (value) {
              case MenuAction.logout:
                final shouldLogOut = await showLogOutDialogue(context);
                devtools.log(shouldLogOut.toString());
                if (shouldLogOut) {
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (route) => false,
                  );
                }
            }
          }, itemBuilder: (context) {
            return [
              const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout, child: Text("Log Out"))
            ];
          })
        ],
      ),
      body: const Text("Hello World"),
    );
  }
}

enum MenuAction { logout }

Future<bool> showLogOutDialogue(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Log out"),
          content: const Text("Are you sure if you want to log out?"),
          actions: [
            TextButton(
                onPressed: () {
                  devtools.log("Canceling");
                  Navigator.of(context).pop(false);
                },
                child: const Text("Cancel")),
            TextButton(
                onPressed: () {
                  devtools.log("Logging out");
                  Navigator.of(context).pop(true);
                },
                child: const Text("Log out")),
          ],
        );
      }).then(
    (value) {
      //devtools.log(value.toString());
      return value ?? false;
    },
  );
}
