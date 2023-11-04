import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventLogIn extends AuthEvent {
  final String email;
  final String password;
  const AuthEventLogIn({
    required this.email,
    required this.password,
  });
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;
  const AuthEventRegister({
    required this.email,
    required this.password,
  });
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}

class AuthEventSendVerificationEmail extends AuthEvent {
  const AuthEventSendVerificationEmail();
}
class AuthEventNavToRegister extends AuthEvent {
  const AuthEventNavToRegister();
}
class AuthEventNavToLogin extends AuthEvent {
  const AuthEventNavToLogin();
}

class AuthEventForgotPassword extends AuthEvent{
  final String? email;
  const AuthEventForgotPassword({this.email});
}