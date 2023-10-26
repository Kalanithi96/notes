import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/firebase_options.dart';
import 'package:notes/views/email_verify.dart';
import 'package:notes/views/login_view.dart';
import 'package:notes/views/notes_view.dart';
import 'package:notes/views/register_view.dart';
import 'dart:developer' as devtools show log;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
      },
    )
    );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
                      options: DefaultFirebaseOptions.currentPlatform,
                    ),
        builder: (context, snapshot){
          switch (snapshot.connectionState){
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              devtools.log(user.toString());
              if(user == null){
                return const LoginView();
              } else if (user.emailVerified){
                //devtools.log("Welcome to Homepage");
                return const NotesView();
              } else{
                //devtools.log("Please verify your email first");
                return const VerifyEmailView();
              }
            default: 
              return const CircularProgressIndicator();
          }
        },
      );
  }
}