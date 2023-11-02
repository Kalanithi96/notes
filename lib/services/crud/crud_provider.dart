import 'dart:async';
import 'package:notes/services/crud/note.dart';

abstract class CrudProvider {
  Iterable<Note> _notes = [];

  Future<Note> createNote({owner});

  Future<void> deleteNote({required dynamic id});

  Future<Note> getNote({required dynamic id});

  Stream<Iterable<Note>> getAllNotes({required dynamic owner});
  
  Future<Note> updateNote({
    required Note note,
    String? title,
    String? text,
  });
}
