import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/constants/cloud_storage_constants.dart';
import 'package:notes/services/crud/cloud_storage_exceptions.dart';
import 'package:notes/services/crud/crud_provider.dart';
import 'package:notes/services/crud/note.dart';

class FirebaseCrudProvider implements CrudProvider{
  final notes = FirebaseFirestore.instance.collection('notes');

  dynamic get user => AuthService.firebase().currentUser?.id;

  FirebaseCrudProvider._sharedInstance();
  static final FirebaseCrudProvider _shared =
      FirebaseCrudProvider._sharedInstance();
  factory FirebaseCrudProvider() => _shared;

  @override
  Future<CloudNote> createNote({
    required covariant String owner,
  }) async {
    final document = await notes.add({
      ownerIdFieldName: owner,
      textFieldName: "",
      titleFieldName: "",
    });
    final fetchedNote = await document.get();
    return CloudNote(
      documentId: fetchedNote.id,
      ownerId: owner,
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

  @override
  Future<Stream<Iterable<CloudNote>>> getAllNotes({required covariant String owner}) async {
      return notes.snapshots().map((event) => event.docs
          .map(
            (doc) => CloudNote.fromSnapshot(doc),
          )
          .where((note) => note.ownerId == owner));
  }
  @override
  Future<CloudNote> updateNote({
    required covariant Note note,
    String? text,
    String? title,
  }) async {
    try {
      final oldNote = await notes.doc(note.documentId).get().then(
            (value) => value.data(),
          );
      if (oldNote == null) {
        throw NoNoteToUpdateException();
      }
      final oldText = oldNote[textFieldName];
      final oldTitle = oldNote[titleFieldName];
      await notes.doc(note.documentId).update({
        textFieldName: text ?? oldText,
        titleFieldName: title ?? oldTitle,
      });
      return await getNote(id: note.documentId);
    } catch (_) {
      throw CouldNotUpdateNoteException();
    }
  }

  @override
  Future<void> deleteNote({
    required covariant String id,
  }) async {
    try {
      await notes.doc(id).delete();
    } catch (_) {
      throw CouldNotDeleteNoteException();
    }
  }
  
  @override
  Future<CloudNote> getNote({required id,}) async {
    try {
      final value = await notes.doc(id)
          .get();
      return CloudNote.fromDocumentSnapshot(value);
    } catch (_) {
      throw CouldNotGetAllNotesException();
    }
  }
  
  @override
  Future createUser({required String email}) {
    return Future.delayed(const Duration(microseconds: 1));
  }
  
  @override
  Future getOrCreateUser({required String email, bool setAsCurrentUser = true}) {
    return Future.delayed(const Duration(microseconds: 1));
  }
  
  @override
  Future getUser({required String email}) {
    return Future.delayed(const Duration(microseconds: 1));
  }
}


@immutable
class CloudNote extends Note {
  const CloudNote({
    required super.documentId,
    required super.ownerId,
    required super.title,
    required super.text,
  });

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : super.fromSnapshot(snapshot);
  
  CloudNote.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : super.fromDocumentSnapshot(snapshot);
}