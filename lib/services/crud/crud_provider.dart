import 'dart:async';
import 'package:notes/services/crud/note.dart';

abstract class CrudProvider {
  Future<Note> createNote({required dynamic owner});

  Future<void> deleteNote({required dynamic id});

  Future<Note> getNote({required dynamic id});

  Future<Stream<Iterable<Note>>> getAllNotes({required dynamic owner});
  
  Future<Note> updateNote({
    required Note note,
    String? title,
    String? text,
  });
}
