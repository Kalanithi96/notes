import 'package:flutter/material.dart';
import 'package:notes/utilities/dialogs/show_generic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String message) {
  return showGenericDialog(
      context: context,
      title: "Error",
      message: message,
      optionsBuilder: () => {
            "OK": null,
          });
}
