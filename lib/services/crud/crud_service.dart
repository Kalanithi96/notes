import 'package:notes/services/crud/crud_provider.dart';
import 'package:notes/services/crud/firebase_crud_provider.dart';
import 'package:notes/services/crud/note.dart';
import 'package:notes/services/crud/sqlite_crud_provider.dart';

class CrudService implements CrudProvider {
  final CrudProvider crudProvider;
  CrudService({required this.crudProvider});

  @override
  dynamic get user => crudProvider.user;

  @override
  Future<Note> createNote({owner}) async {
    return await crudProvider.createNote(owner: owner);
  }

  @override
  Future<void> deleteNote({required id}) async {
    await crudProvider.deleteNote(id: id);
  }

  @override
  Future<Stream<Iterable<Note>>> getAllNotes({required owner}) {
    return crudProvider.getAllNotes(owner: owner);
  }

  @override
  Future<Note> getNote({required id}) async {
    return await crudProvider.getNote(id: id);
  }

  @override
  Future<Note> updateNote({
    required Note note,
    String? title,
    String? text,
  }) async {
    return await crudProvider.updateNote(
      note: note,
      title: title,
      text: text,
    );
  }

  factory CrudService.sqlite() => CrudService(crudProvider: SqliteCrudProvider());
  factory CrudService.firebase() => CrudService(crudProvider: FirebaseCrudProvider());
  
  @override
  Future createUser({required String email}) async {
    return await crudProvider.createUser(email: email);
  }
  
  @override
  Future getOrCreateUser({required String email, bool setAsCurrentUser = true}) async {
    return await crudProvider.getOrCreateUser(email: email);
  }
  
  @override
  Future getUser({required String email}) async {
    return await crudProvider.getUser(email: email);
  }
}
