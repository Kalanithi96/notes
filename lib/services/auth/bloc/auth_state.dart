import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:notes/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String loadingText;
  const AuthState({
    required this.isLoading,
    this.loadingText = "Please wait a moment",
  });
}

class AuthUninitializedState extends AuthState {
  const AuthUninitializedState({required super.isLoading});
}

class AuthLoggedInState extends AuthState {
  final AuthUser user;
  const AuthLoggedInState({required this.user, required super.isLoading});
}

class AuthLoggedOutState extends AuthState with EquatableMixin {
  final Exception? exception;
  const AuthLoggedOutState({
    required super.isLoading,
    required this.exception,
    super.loadingText
  });

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthNotRegisteredState extends AuthState {
  final Exception? exception;
  const AuthNotRegisteredState({
    required super.isLoading,
    required this.exception,
    super.loadingText
  });

  List<Object?> get props => [exception, isLoading];
}

class AuthEmailNotVerifiedState extends AuthState {
  const AuthEmailNotVerifiedState({required super.isLoading});
}
