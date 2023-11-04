import 'package:flutter/material.dart';
import 'package:notes/utilities/dialogs/show_generic_dialog.dart';

Future<void> passwordResetEmailSentDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: "Password Reset",
      message: "We have sent you a password reset link. Please check your email for more information.",
      optionsBuilder: () => {
            "OK": null,
          });
}
