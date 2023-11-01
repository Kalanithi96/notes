import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes/services/cloud/cloud_note.dart';
import 'package:notes/services/cloud/cloud_storage_constants.dart';
import 'package:notes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');

  FirebaseCloudStorage._sharedInstance();
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  Future<CloudNote> createNewNote({
    required String ownerId,
  }) async {
    final document = await notes.add({
      ownerIdFieldName: ownerId,
      textFieldName: "",
      titleFieldName: "",
    });
    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      ownerId: ownerId,
      title: "",
      text: "",
    );
  }

  Future<Iterable<CloudNote>> getNotes({
    required String ownerId,
  }) async {
    try {
      return await notes
          .where(
            ownerIdFieldName,
            isEqualTo: ownerId,
          )
          .get()
          .then(
              (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)));
    } catch (_) {
      throw CouldNotGetAllNotesException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerId}) =>
      notes.snapshots().map((event) => event.docs
          .map(
            (doc) => CloudNote.fromSnapshot(doc),
          )
          .where((note) => note.ownerId == ownerId));

  Future<void> updateNote({
    required String documentId,
    String? newText,
    String? newTitle,
  }) async {
    try {
      final note = await notes.doc(documentId).get().then(
            (value) => value.data(),
          );
      if (note == null) {
        throw NoNoteToUpdateException();
      }
      final text = note[textFieldName];
      final title = note[titleFieldName];
      await notes.doc(documentId).update({
        textFieldName: newText ?? text,
        titleFieldName: newTitle ?? title,
      });
    } catch (_) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<void> deleteNote({
    required String documentId,
  }) async {
    try {
      await notes.doc(documentId).delete();
    } catch (_) {
      throw CouldNotDeleteNoteException();
    }
  }
}
