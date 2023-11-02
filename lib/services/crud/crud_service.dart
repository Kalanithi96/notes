import 'package:notes/services/crud/crud_provider.dart';
import 'package:notes/services/crud/note.dart';

class CrudService implements CrudProvider {
  final CrudProvider crudProvider;
  CrudService({required this.crudProvider});

  @override
  Future<Note> createNote({owner}) async {
    return await crudProvider.createNote(owner: owner);
  }

  @override
  Future<void> deleteNote({required id}) async {
    await crudProvider.deleteNote(id: id);
  }

  @override
  Stream<Iterable<Note>> getAllNotes({required owner}) {
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
}
