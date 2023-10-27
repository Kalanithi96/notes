import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 2));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    if (email=="kalanithi96@gmail.com") throw InvalidCredentialsException();
    if (email=="kalanithi96gmail.com") throw InvalidEmailException();
    if (password == "green") throw InvalidCredentialsException();
    if (email == "") throw EmptyChannelException();
    if (password == "") throw EmptyChannelException();
    _user = const AuthUser(isEmailVerified: false);
    await Future.delayed(const Duration(seconds: 2));
    return Future.value(_user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    await Future.delayed(const Duration(seconds: 2));
    _user = null;
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    if (email=="kalanithi96@gmail.com") throw EmailAlreadyInUseException();
    if (email=="kalanithi96gmail.com") throw InvalidEmailException();
    if (password == "123") throw WeakPasswordException();
    if (email == "") throw EmptyChannelException();
    if (password == "") throw EmptyChannelException();
    _user = const AuthUser(isEmailVerified: false);
    await Future.delayed(const Duration(seconds: 2));
    return Future.value(_user);
  }

  @override
  Future<void> sendEmailVerification() {
    // TODO: implement sendEmailVerification
    throw UnimplementedError();
  }
}
