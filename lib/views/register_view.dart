// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:notes/constants/routes.dart';
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
                  await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: email, password: password);
                  Navigator.of(context).pushNamed(
                    verifyEmailRoute,
                  );
                } on FirebaseAuthException catch (e) {
                  switch (e.code) {
                    case "email-already-in-use":
                      devtools.log("Email already registered");
                      await showErrorDialog(context, "Email already registered");
                      break;
                    case "weak-password":
                      devtools.log("Use a stronger password");
                      await showErrorDialog(context, "Use a stronger password");
                      break;
                    case "invalid-email":
                      devtools.log("Use a valid email");
                      await showErrorDialog(context, "Use a valid email");
                      break;
                    default:
                      devtools.log("Something Bad happened");
                      await showErrorDialog(context, "Error: ${e.code}");
                      devtools.log(e.toString());
                  }
                } catch (e) {
                  await showErrorDialog(context, "Error: ${e.toString()}");
                  devtools.log(e.toString());
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