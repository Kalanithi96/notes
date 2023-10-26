import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

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