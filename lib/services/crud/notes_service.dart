import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:notes/services/crud/crud_exceptions.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class NotesService {
  Database? _db;

  List<DatabaseNote> _notes = [];

  final _notesStreamController = StreamController<List<DatabaseNote>>.broadcast();

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> _cacheNotes() async{
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createNotesTable);

      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> close() async {
    final db = _getDatabaseOrThrow();
    await db.close();
    _db = null;
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteUser();
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final userId = await db.insert(
      userTable,
      {
        emailColumn: email.toLowerCase(),
      },
    );
    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw UserDoesNotExist();
    }
    return DatabaseUser.fromRow(results.first);
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try{
      final user = await getUser(email: email);
      return user;
    }on CouldNotFindUser{
      final user = await createUser(email: email);
      return user;
    } catch(e){
      rethrow;
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();

    // Make sure owner exists in the database with correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = '';
    const title = '';
    final noteId = await db.insert(notesTable, {
      userIdColumn: owner.id,
      textColumn: text,
      titleColumn: title,
      isSyncedWithCloudColumn: 1,
    });

    final newNote = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      title: title,
      isSyncedWithCloud: true,
    );

    _notes.add(newNote);
    _notesStreamController.add(_notes);

    return newNote;
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();

    final deleteCount = await db.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    } else{
      _notes.removeWhere((note)=> note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<int> deleteNotesOfOneUser({required int userId}) async {
    final db = _getDatabaseOrThrow();

    final deleteCount = await db.delete(
      notesTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    _notes.removeWhere((note)=> note.userId == userId);
    _notesStreamController.add(_notes);

    return deleteCount;
  }

  Future<int> deleteAllNotes() async {
    final db = _getDatabaseOrThrow();
    
    _notes = [];
    _notesStreamController.add(_notes);
    
    return await db.delete(notesTable);
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      notesTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNote();
    }
    final note = DatabaseNote.fromRow(notes.first);
    _notes.removeWhere((row)=>id==row.id);
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(notesTable);

    final notesIterable = notes.map((notesRow) => DatabaseNote.fromRow(notesRow));

    _notes = notesIterable.toList();
    _notesStreamController.add(_notes);

    return notesIterable;
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    String? title,
    String? text,
  }) async {
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updatesCount = await db.update(
      notesTable,
      {
        textColumn: text ?? note.text,
        titleColumn: title ?? note.title,
        isSyncedWithCloudColumn: 0,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );
    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {

      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((row)=>updatedNote.id==row.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);

      return updatedNote;
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() {
    return "id = $id and email = $email\n";
  }

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String title;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.title,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        title = map[titleColumn] as String,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() {
    return "ID = $id, User ID = $userId, Title = $title, isSyncedWithCloud = $isSyncedWithCloud, Text = $text\n";
  }

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'notes.db';
const userTable = 'user';
const notesTable = 'notes';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const titleColumn = 'title';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUserTable = '''CREATE TABLE "user" (
                                  "id"	INTEGER NOT NULL,
                                  "email"	TEXT NOT NULL UNIQUE,
                                  PRIMARY KEY("id" AUTOINCREMENT)
                                );''';
const createNotesTable = '''CREATE TABLE "notes" (
                                  "id"	INTEGER NOT NULL UNIQUE,
                                  "user_id"	INTEGER NOT NULL,
                                  "text"	TEXT,
                                  "title"	TEXT NOT NULL,
                                  "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
                                  FOREIGN KEY("user_id") REFERENCES "user"("id") ON UPDATE CASCADE ON DELETE CASCADE,
                                  PRIMARY KEY("id")
                                );''';
