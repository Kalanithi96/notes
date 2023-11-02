import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes/services/crud/cloud/cloud_storage_constants.dart';

@immutable
class CloudNote {
  final String documentId;
  final String ownerId;
  final String title;
  final String text;
  const CloudNote({
    required this.documentId,
    required this.ownerId,
    required this.title,
    required this.text,
  });

  @override
  String toString(){
    return "Title: $title\nText: $text";
  }

  CloudNote.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        ownerId = snapshot.data()[ownerIdFieldName],
        title = snapshot.data()[titleFieldName] as String,
        text = snapshot.data()[textFieldName] as String;
}
