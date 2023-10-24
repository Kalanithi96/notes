import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notes/firebase_options.dart';
import 'package:notes/views/email_verify.dart';
import 'package:notes/views/login_view.dart';
import 'package:notes/views/register_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    )
    );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page")
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
                      options: DefaultFirebaseOptions.currentPlatform,
                    ),
        builder: (context, snapshot){
          switch (snapshot.connectionState){
            case ConnectionState.done:
              final user = FirebaseAuth.instance.currentUser;
              print(user);
              if(user == null){
                print("You need to login/register first");
              } else if (user.emailVerified){
                print("Welcome to Homepage");
              } else{
                print("Please verify your email first");
                return const VerifyEmailView();
              }
              return const Text("Done");
            default: 
              return const Text("Loading...");       
          }
        },
      ),
    );
  }
}