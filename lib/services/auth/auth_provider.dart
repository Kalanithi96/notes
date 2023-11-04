import 'package:notes/services/auth/auth_user.dart';


abstract class AuthProvider{
  AuthUser? get currentUser;
  Future<void> initialize();
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });
  Future<AuthUser> register({
    required String email,
    required String password,
  });
  Future<void> logOut();
  Future<void> sendEmailVerification();
  Future<void> sendResetPasswordEmail({required String email});
}