import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirestoreSource {
  Future<DocumentSnapshot?> getDocumentById(String collection, String docId);
  Future<QuerySnapshot> getDocumentsByQuery(String collection, {String? field, dynamic value});
  Future<void> addDocument(String collection, Map<String, dynamic> data);
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data);
  Future<void> deleteDocument(String collection, String docId);
}