// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: "Enter your Email"),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: "Enter your password"),
          ),
          Center(
            child: TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;

                try {
                  await AuthService.firebase().register(
                    email: email,
                    password: password,
                  );
                  await AuthService.firebase().sendEmailVerification();
                  Navigator.of(context).pushNamed(
                    verifyEmailRoute,
                  );
                } on EmailAlreadyInUseException catch (_) {
                  await showErrorDialog(
                    context,
                    "Email already registered",
                  );
                } on WeakPasswordException catch (_) {
                  await showErrorDialog(
                    context,
                    "Use a stronger password",
                  );
                } on InvalidEmailException catch (_) {
                  await showErrorDialog(
                    context,
                    "Use a valid email",
                  );
                } on EmptyChannelException catch (_) {
                  await showErrorDialog(
                    context,
                    "Fields cannot be empty",
                  );
                } on GenericAuthException catch (_) {
                  await showErrorDialog(
                    context,
                    "Error in registering",
                  );
                }
              },
              child: const Text("Register"),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text("Already registered? Login here"),
            ),
          ),
        ],
      ),
    );
  }
}
