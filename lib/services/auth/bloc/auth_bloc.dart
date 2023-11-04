import 'package:bloc/bloc.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthUninitializedState()) {
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthLoggedOutState(
          exception: null,
          isLoading: false,
        ));
      } else if (!user.isEmailVerified) {
        emit(const AuthEmailNotVerifiedState());
      } else {
        emit(AuthLoggedInState(user: user));
      }
    });

    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthLoggedOutState(
        exception: null,
        isLoading: true,
      ));
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(
          email: email,
          password: password,
        );
        if (!user.isEmailVerified) {
          emit(const AuthLoggedOutState(
            exception: null,
            isLoading: false,
          ));
          emit(const AuthEmailNotVerifiedState());
        } else {
          emit(const AuthLoggedOutState(
            exception: null,
            isLoading: false,
          ));
          emit(AuthLoggedInState(user: user));
        }
      } on Exception catch (e) {
        emit(AuthLoggedOutState(
          exception: e,
          isLoading: false,
        ));
      }
    });

    on<AuthEventRegister>((event, emit) async {
      emit(const AuthNotRegisteredState(
        exception: null,
        isLoading: true,
      ));
      final email = event.email;
      final password = event.password;
      try {
        await provider.register(
          email: email,
          password: password,
        );
        emit(const AuthNotRegisteredState(
          exception: null,
          isLoading: false,
        ));
        emit(const AuthEmailNotVerifiedState());
      } on Exception catch (e) {
        emit(AuthNotRegisteredState(
          exception: e,
          isLoading: false,
        ));
      }
    });

    on<AuthEventLogOut>((event, emit) async {
      emit(const AuthLoggedOutState(
        exception: null,
        isLoading: true,
      ));
      try {
        await provider.logOut();
        emit(const AuthLoggedOutState(
          exception: null,
          isLoading: false,
        ));
      } on Exception catch (e) {
        emit(AuthLoggedOutState(
          exception: e,
          isLoading: false,
        ));
      }
    });

    on<AuthEventSendVerificationEmail>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    on<AuthEventNavToLogin>((event, emit) async {
      emit(const AuthLoggedOutState(
        exception: null,
        isLoading: false,
      ));
    });

    on<AuthEventNavToRegister>((event, emit) async {
      emit(const AuthNotRegisteredState(
        exception: null,
        isLoading: false,
      ));
    });
  }
}
