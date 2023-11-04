import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'package:notes/utilities/dialogs/password_reset_email_sent_dialog.dart';
import 'package:notes/utilities/dialogs/show_error_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthForgotPasswordState) {
          if (state.hasSentEmail) {
            _controller.clear();
            await passwordResetEmailSentDialog(context);
          }
          if(state.exception is InvalidEmailException) {
            // ignore: use_build_context_synchronously
            await showErrorDialog(context,
                "Please enter a valid email address.");
          } else if(state.exception is EmptyChannelException) {
            // ignore: use_build_context_synchronously
            await showErrorDialog(context,
                "Email field is mandatory.");
          } else if (state.exception != null){
            // ignore: use_build_context_synchronously
            await showErrorDialog(context,
                "We cannot process your request. Please make sure that you are a registered user.");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Forgot Password"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                  "If you forgot your password, simply enter your email and we will send you a password reset email."),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                decoration:
                    const InputDecoration(hintText: "Your email address"),
              ),
              TextButton(
                onPressed: () {
                  final email = _controller.text;
                  context
                      .read<AuthBloc>()
                      .add(AuthEventForgotPassword(email: email));
                },
                child: const Text("Send me password reset link"),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventNavToLogin());
                },
                child: const Text("Back to login page"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
