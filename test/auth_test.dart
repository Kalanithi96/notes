import 'package:notes/services/auth/auth_exceptions.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group("Mock Authentication", () {
    final provider = MockAuthProvider();
    test("Should not be initialized to begin with", () {
      expect(
        provider.isInitialized,
        false,
      );
    });
    test("Cannot log out when not initialized", () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });
    test("Should be able to initialize", () async {
      await provider.initialize();
      expect(
        provider.isInitialized,
        true,
      );
    });
    test("User should be able null after initialization", () {
      expect(
        provider.currentUser,
        null,
      );
    });
    test(
      "User should be able to initialize within 3 seconds",
      () async {
        await provider.initialize();
        expect(
          provider.isInitialized,
          true,
        );
      },
      timeout: const Timeout(Duration(seconds: 3)),
    );
    test("Registering a user", () async {
      expect(
        provider.register(
          email: "kalanithi96@gmail.com",
          password: "password",
        ),
        throwsA(const TypeMatcher<EmailAlreadyInUseException>()),
      );
      expect(
        provider.register(
          email: "kalanithi96gmail.com",
          password: "password",
        ),
        throwsA(const TypeMatcher<InvalidEmailException>()),
      );
      expect(
        provider.register(
          email: "kalanithigmail.com",
          password: "123",
        ),
        throwsA(const TypeMatcher<WeakPasswordException>()),
      );
      expect(
        provider.register(
          email: "",
          password: "password",
        ),
        throwsA(const TypeMatcher<EmptyChannelException>()),
      );
      expect(
        provider.register(
          email: "name@email.com",
          password: "",
        ),
        throwsA(const TypeMatcher<EmptyChannelException>()),
      );
      final user = await provider.register(
        email: "name@email.com",
        password: "password",
      );
      expect(
        provider.currentUser,
        user,
      );
      expect(
        user.isEmailVerified,
        false,
      );
    });
    test("Logged in user should be able to get verified", () async {
      final user = provider.currentUser;
      expect(user, isNotNull);
      await provider.sendEmailVerification();
      final verifiedUser = provider.currentUser;
      expect(verifiedUser!.isEmailVerified, true);
    });
    test("Should be able to log out and log in again", () async {
      await provider.logOut();
      final user = provider.currentUser;
      expect(user, isNull);
      await provider.logIn(
        email: "name@email.com",
        password: "password",
      );
      expect(provider.currentUser, isNotNull);
    });
  });
}

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
    if (email == "kalanithi96@gmail.com") throw InvalidCredentialsException();
    if (email == "kalanithi96gmail.com") throw InvalidEmailException();
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
    if (email == "kalanithi96@gmail.com") throw EmailAlreadyInUseException();
    if (email == "kalanithi96gmail.com") throw InvalidEmailException();
    if (password == "123") throw WeakPasswordException();
    if (email == "") throw EmptyChannelException();
    if (password == "") throw EmptyChannelException();
    _user = const AuthUser(isEmailVerified: false);
    await Future.delayed(const Duration(seconds: 2));
    return Future.value(_user);
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    await Future.delayed(const Duration(seconds: 2));
    _user = const AuthUser(isEmailVerified: true);
  }
}
