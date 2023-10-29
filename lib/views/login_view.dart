// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
//import 'dart:developer' as devtools show log;

import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        title: const Text("Login"),
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
                  final user = await AuthService.firebase().logIn(
                    email: email,
                    password: password,
                  );
                  //devtools.log(user.toString());
                  if (user.isEmailVerified) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      notesRoute,
                      (route) => false,
                    );
                  } else {
                    Navigator.of(context).pushNamed(
                      verifyEmailRoute,
                    );
                  }
                } on InvalidCredentialsException catch (_) {
                  await showErrorDialog(
                    context,
                    "Invalid Credentials",
                  );
                } on EmptyChannelException catch (_) {
                  await showErrorDialog(
                    context,
                    "Fields cannot be empty",
                  );
                } on InvalidEmailException catch (_) {
                  
                  await showErrorDialog(
                    context,
                    "Invalid Email",
                  );
                } on GenericAuthException catch (_) {
                  
                  await showErrorDialog(
                    context,
                    "Authentication error",
                  );
                }
              },
              child: const Text("Login"),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  (route) => false,
                );
              },
              child: const Text("Not registered yet? Register here"),
            ),
          ),
        ],
      ),
    );
  }
}
