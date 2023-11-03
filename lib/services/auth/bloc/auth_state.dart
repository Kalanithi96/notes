import 'package:flutter/foundation.dart' show immutable;
import 'package:notes/services/auth/auth_user.dart';

@immutable
abstract class AuthState{
  const AuthState();
}

class AuthLoadingState extends AuthState{
  const AuthLoadingState();
}

class AuthLoggedInState extends AuthState{
  final AuthUser user;
  const AuthLoggedInState({required this.user});
}

class AuthLogInFailureState extends AuthState{
  final Exception exception;
  const AuthLogInFailureState({required this.exception});
}

class AuthLoggedOutState extends AuthState{
  const AuthLoggedOutState();
}

class AuthEmailNotVerifiedState extends AuthState{
  const AuthEmailNotVerifiedState();
}

class AuthLogOutFailureState extends AuthState{
  final Exception exception;
  const AuthLogOutFailureState({required this.exception});
}

class AuthRegisterFailureState extends AuthState{
  final Exception exception;
  const AuthRegisterFailureState({required this.exception});
}
