import 'package:flutter/material.dart';
import 'package:notes/utilities/dialogs/show_generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: "Delete Note",
      message: "Are you sure if you want to delete the note?",
      optionsBuilder: () => {
            "Cancel": false,
            "Yes": true,
          }).then((value) {
    //devtools.log(value.toString());
    return value ?? false;
  });
}
