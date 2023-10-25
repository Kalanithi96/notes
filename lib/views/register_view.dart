import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes/firebase_options.dart';

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
                  final userCred = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: email, password: password);
    
                  print(userCred);
                } on FirebaseAuthException catch (e) {
                  switch (e.code) {
                    case "email-already-in-use":
                      print("Email already registered");
                      break;
                    case "weak-password":
                      print("Use a stronger password");
                      break;
                    case "invalid-email":
                      print("Use a valid email");
                      break;
                    default:
                      print("Something Bad happened");
                      print(e);
                  }
                }
              },
              child: const Text("Register"),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/login/', (route) => false);
              },
              child: const Text("Already registered? Login here"),
            ),
          ),
        ],
      ),
    );
  }
}
