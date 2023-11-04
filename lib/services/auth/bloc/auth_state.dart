import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:notes/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthUninitializedState extends AuthState {
  const AuthUninitializedState();
}

class AuthLoggedInState extends AuthState {
  final AuthUser user;
  const AuthLoggedInState({required this.user});
}

class AuthLoggedOutState extends AuthState with EquatableMixin{
  final Exception? exception;
  final bool isLoading;
  const AuthLoggedOutState({
    required this.isLoading,
    required this.exception,
  });
  
  @override
  List<Object?> get props => [exception,isLoading];
}

class AuthNotRegisteredState extends AuthState {
  final Exception? exception;
  final bool isLoading;
  const AuthNotRegisteredState({
    required this.isLoading,
    required this.exception,
  });
  
  List<Object?> get props => [exception,isLoading];
}

class AuthEmailNotVerifiedState extends AuthState {
  const AuthEmailNotVerifiedState();
}
