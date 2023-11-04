import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:notes/constants/routes.dart';
import 'package:notes/services/auth/bloc/auth_bloc.dart';
import 'package:notes/services/auth/bloc/auth_event.dart';
import 'package:notes/services/auth/bloc/auth_state.dart';
import 'package:notes/services/auth/firebase_auth_provider.dart';
import 'package:notes/views/notes/create_update_note_view.dart';
import 'package:notes/views/verify_email.dart';
import 'package:notes/views/login_view.dart';
import 'package:notes/views/notes/notes_view.dart';
import 'package:notes/views/register_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: BlocProvider(
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: const HomePage(),
    ),
    routes: {
      createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoggedOutState) {
          return const LoginView();
        } else if (state is AuthEmailNotVerifiedState) {
          return const VerifyEmailView();
        } else if (state is AuthLoggedInState) {
          return const NotesView();
        } else if (state is AuthNotRegisteredState) {
          return const RegisterView();
        } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
/* 

To test Bloc - Counter App

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Testing Bloc"),
        ),
        body: BlocConsumer<CounterBloc, CounterState>(
          listener: (context, state) {
            _textEditingController.clear();
          },
          builder: (context, state) {
            final invalidValue =
                (state is InvalidCounterState) ? state.invalidValue : '';
            return Column(
              children: [
                Text('Current Value : ${state.value}'),
                Visibility(
                  visible: state is InvalidCounterState,
                  child: Text("Invalid input: $invalidValue"),
                ),
                TextField(
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                    hintText: "Enter a number here",
                  ),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        context
                            .read<CounterBloc>()
                            .add(DecrementEvent(_textEditingController.text));
                      },
                      child: const Text("-"),
                    ),
                    TextButton(
                      onPressed: () {
                        context
                            .read<CounterBloc>()
                            .add(IncrementEvent(_textEditingController.text));
                      },
                      child: const Text("+"),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

@immutable
abstract class CounterState {
  final int value;
  const CounterState({required this.value});
}

class ValidCounterState extends CounterState {
  const ValidCounterState(int value) : super(value: value);
}

class InvalidCounterState extends CounterState {
  final String invalidValue;
  const InvalidCounterState({
    required int previousValue,
    required this.invalidValue,
  }) : super(value: previousValue);
}

@immutable
abstract class CounterEvent {
  final String value;
  const CounterEvent({required this.value});
}

class IncrementEvent extends CounterEvent {
  const IncrementEvent(String value) : super(value: value);
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent(String value) : super(value: value);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const ValidCounterState(0)) {
    on<IncrementEvent>((event, emit) {
      final integer = int.tryParse(event.value);
      if (integer != null) {
        emit(ValidCounterState(state.value + integer));
      } else {
        emit(InvalidCounterState(
          previousValue: state.value,
          invalidValue: event.value,
        ));
      }
    });
    on<DecrementEvent>((event, emit) {
      final integer = int.tryParse(event.value);
      if (integer != null) {
        emit(ValidCounterState(state.value - integer));
      } else {
        emit(InvalidCounterState(
          previousValue: state.value,
          invalidValue: event.value,
        ));
      }
    });
  }
}
 */