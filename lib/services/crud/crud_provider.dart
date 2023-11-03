import 'dart:async';
import 'package:notes/services/crud/note.dart';

abstract class CrudProvider {
  dynamic get user;

  Future<Note> createNote({required dynamic owner});

  Future<void> deleteNote({required dynamic id});

  Future<Note> getNote({required dynamic id});

  Future<Stream<Iterable<Note>>> getAllNotes({required dynamic owner});

  Future<dynamic> createUser({required String email});

  Future<dynamic> getUser({required String email});

  Future<dynamic> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  });
  
  Future<Note> updateNote({
    required Note note,
    String? title,
    String? text,
  });
}
