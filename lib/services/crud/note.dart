
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes/constants/cloud_storage_constants.dart';
import 'package:notes/constants/sqlite_storage_constants.dart';

@immutable
class Note {
  // ignore: prefer_typing_uninitialized_variables
  final documentId;
  // ignore: prefer_typing_uninitialized_variables
  final ownerId;
  final String title;
  final String text;

  const Note({
    required this.documentId,
    required this.ownerId,
    required this.title,
    required this.text
  });

  @override
  String toString(){
    return "Title: $title\nText: $text";
  }
  @override
  bool operator ==(covariant Note other) => documentId == other.documentId;

  @override
  int get hashCode => documentId.hashCode;

  Note.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerId = snapshot.data()[ownerIdFieldName],
        title = snapshot.data()[titleFieldName] as String,
        text = snapshot.data()[textFieldName] as String;
  
  Note.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerId = snapshot.data()![ownerIdFieldName],
        title = snapshot.data()![titleFieldName] as String,
        text = snapshot.data()![textFieldName] as String;

  Note.fromRow(Map<String, Object?> map)
      : documentId = map[idColumn] as int,
        ownerId = map[userIdColumn] as int,
        title = map[titleColumn] as String,
        text = map[textColumn] as String;
}
