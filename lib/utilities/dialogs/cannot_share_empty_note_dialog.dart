import 'package:flutter/material.dart';
import 'package:notes/utilities/dialogs/show_generic_dialog.dart';

Future<void> cannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: "Sharing",
      message: "You cannot share an empty note",
      optionsBuilder: () => {
            "OK": null,
          });
}
