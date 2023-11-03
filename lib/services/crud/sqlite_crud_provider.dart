import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:notes/extensions/filter.dart';
import 'package:notes/services/crud/crud_provider.dart';
import 'package:notes/constants/sqlite_storage_constants.dart';
import 'package:notes/services/crud/sqlite_storage_exceptions.dart';
import 'package:notes/services/crud/note.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as devtools show log;

class SqliteCrudProvider implements CrudProvider{
  Database? _db;
  DatabaseUser? _user;

  static final SqliteCrudProvider _shared = SqliteCrudProvider._sharedInstance();
  SqliteCrudProvider._sharedInstance() {
    _notesStreamController = StreamController<Iterable<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory SqliteCrudProvider() => _shared;

  Iterable<DatabaseNote> _notes = [];

  late final StreamController<Iterable<DatabaseNote>> _notesStreamController;

  @override
  DatabaseUser? get user => _user;

  Stream<Iterable<DatabaseNote>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.ownerId == currentUser.id;
        } else {
          throw UserMustBeSetBeforeReadingAllNotes();
        }
      });

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes(owner: _user!);
    var notes = await allNotes.last;
    _notes = notes.toList();
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

      try {
        await db.execute(createUserTable);
        await db.execute(createNotesTable);
      } on DatabaseException {
        // Empty
      }

      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    } catch (e) {
      devtools.log(e.toString());
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException catch (_) {}
  }

  Future<void> close() async {
    final db = _getDatabaseOrThrow();
    await db.close();
    _db = null;
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
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

  @override
  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
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

  @override
  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
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

  @override
  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    await _ensureDbIsOpen();
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on UserDoesNotExist {
      final user = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<DatabaseNote> createNote({required covariant DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    // Make sure owner exists in the database with correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw UserMismatch();
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
      documentId: noteId,
      ownerId: owner.id,
      text: text,
      title: title,
      isSyncedWithCloud: true,
    );

    List<DatabaseNote> notes = _notes.toList();
    notes.add(newNote);
    _notes = notes;
    _notesStreamController.add(_notes);

    return newNote;
  }

  @override
  Future<void> deleteNote({required covariant int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final deleteCount = await db.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      List<DatabaseNote> notes = _notes.toList();
      notes.removeWhere((note) => note.documentId == id);
      _notes = notes;
      _notesStreamController.add(_notes);
    }
  }

  Future<int> deleteNotesOfOneUser({required int ownerId}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final deleteCount = await db.delete(
      notesTable,
      where: 'user_id = ?',
      whereArgs: [ownerId],
    );

    List<DatabaseNote> notes = _notes.toList();
    notes.removeWhere((note) => note.ownerId == ownerId);
    _notes = notes;
    _notesStreamController.add(_notes);

    return deleteCount;
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    _notes = [];
    _notesStreamController.add(_notes);

    return await db.delete(notesTable);
  }

  @override
  Future<DatabaseNote> getNote({required covariant int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final fetchedNote = await db.query(
      notesTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (fetchedNote.isEmpty) {
      throw CouldNotFindNote();
    }
    final note = DatabaseNote.fromRow(fetchedNote.first);
    List<DatabaseNote> notes = _notes.toList();
    notes.removeWhere((row) => id == row.documentId);
    notes.add(note);
    _notes = notes;
    _notesStreamController.add(_notes);
    return note;
  }

  @override
  Future<Stream<Iterable<DatabaseNote>>> getAllNotes({required covariant DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(notesTable);

    final notesIterable =
        notes.map((notesRow) => DatabaseNote.fromRow(notesRow));

    _notes = notesIterable.toList();
    _notesStreamController.add(_notes);

    return _notesStreamController.stream;
  }

  @override
  Future<DatabaseNote> updateNote({
    required covariant DatabaseNote note,
    String? title,
    String? text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final noteInDb = await getNote(id: note.documentId);

    final updatesCount = await db.update(
      notesTable,
      {
        textColumn: text ?? noteInDb.text,
        titleColumn: title ?? noteInDb.title,
        isSyncedWithCloudColumn: 0,
      },
      where: 'id = ?',
      whereArgs: [note.documentId],
    );
    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(id: note.documentId);
      List<DatabaseNote> notes = _notes.toList();
      notes.removeWhere((row) => updatedNote.documentId == row.documentId);
      notes.add(updatedNote);
      _notes = notes;
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

class DatabaseNote extends Note{
  final bool isSyncedWithCloud;

  const DatabaseNote({
    required super.documentId,
    required super.ownerId,
    required super.text,
    required super.title,
    required this.isSyncedWithCloud,
  });

  @override
  DatabaseNote.fromRow(Map<String, Object?> map):
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false,
        super.fromRow(map);
}