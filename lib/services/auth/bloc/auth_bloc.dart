import 'package:bloc/bloc.dart';
import 'package:notes/services/auth/auth_provider.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthLoadingState()) {
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthLoggedOutState());
      } else if (!user.isEmailVerified) {
        emit(const AuthEmailNotVerifiedState());
      } else {
        emit(AuthLoggedInState(user: user));
      }
    });
    
    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthLoadingState());
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(
          email: email,
          password: password,
        );
        if(!user.isEmailVerified){
          emit(const AuthEmailNotVerifiedState());
        } else{
          emit(AuthLoggedInState(user: user));
        }
      } on Exception catch (e){
        emit(AuthLogInFailureState(exception: e));
      }
    });

    on<AuthEventRegister>((event, emit) async {
      emit(const AuthLoadingState());
      final email = event.email;
      final password = event.password;
      try {
        await provider.register(
          email: email,
          password: password,
        );
        emit(const AuthEmailNotVerifiedState());
      } on Exception catch (e){
        emit(AuthRegisterFailureState(exception: e));
      }
    });
    
    on<AuthEventLogOut>((event, emit) async {
      emit(const AuthLoadingState());
      try {
        await provider.logOut();
        emit(const AuthLoggedOutState());
      } on Exception catch (e){
        emit(AuthLogOutFailureState(exception: e));
      }
    });
  }
}
