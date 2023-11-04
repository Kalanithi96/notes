import 'package:bloc/bloc.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthUninitializedState(isLoading: true)) {
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthLoggedOutState(
          exception: null,
          isLoading: false,
        ));
      } else if (!user.isEmailVerified) {
        emit(const AuthEmailNotVerifiedState(
          isLoading: false,
        ));
      } else {
        emit(AuthLoggedInState(
          user: user,
          isLoading: false,
        ));
      }
    });

    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthLoggedOutState(
          exception: null,
          isLoading: true,
          loadingText: "Logging in, please wait..."));
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
          emit(const AuthEmailNotVerifiedState(
            isLoading: false,
          ));
        } else {
          emit(const AuthLoggedOutState(
            exception: null,
            isLoading: false,
          ));
          emit(AuthLoggedInState(
            user: user,
            isLoading: false,
          ));
        }
      } on Exception catch (e) {
        emit(AuthLoggedOutState(
          exception: e,
          isLoading: false,
        ));
      }
    });

    on<AuthEventRegister>((event, emit) async {
      emit(
        const AuthNotRegisteredState(
          exception: null,
          isLoading: true,
          loadingText: "Registering, please wait...",
        ),
      );
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
        emit(
          const AuthEmailNotVerifiedState(
            isLoading: false,
          ),
        );
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
        loadingText: "Logging out, please wait...",
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

    on<AuthEventForgotPassword>(
      (event, emit) async {
        emit(const AuthForgotPasswordState(
          isLoading: false,
          exception: null,
          hasSentEmail: false,
        ));
        final email = event.email;
        bool didSendEmail = false;
        Exception? exception;
        if (email == null) {
          return;
        } else {
          emit(const AuthForgotPasswordState(
            isLoading: true,
            exception: null,
            hasSentEmail: false,
          ));
          try {
            await provider.sendResetPasswordEmail(email: email);
            didSendEmail = true;
            exception = null;
          } on Exception catch (e) {
            didSendEmail = false;
            exception = e;
          }

          emit(AuthForgotPasswordState(
            isLoading: false,
            exception: exception,
            hasSentEmail: didSendEmail,
          ));
        }
      },
    );
  }
}
