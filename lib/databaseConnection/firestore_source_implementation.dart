import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/databaseConnection/firestore_source.dart';

class FirestoreSourceImplementation implements FirestoreSource {
  static final FirestoreSourceImplementation _instance = FirestoreSourceImplementation._internal();

  FirestoreSourceImplementation._internal();

  factory FirestoreSourceImplementation() {
    return _instance;
  }

  static FirebaseFirestore? _firestoreInstance;

  static void initialize(FirebaseFirestore firestore) {
    _firestoreInstance = firestore;
  }

  FirebaseFirestore get _firestore {
    if (_firestoreInstance == null) {
      throw Exception('FirestoreSourceImplementation not initialized. Call initialize() first.');
    }
    return _firestoreInstance!;
  }

  @override
  Future<DocumentSnapshot?> getDocumentById(String collection, String docId) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
    } on FirebaseException catch (e) {
      print('Firestore error fetching document by ID: $e');
      return null;
    } catch (e) {
      print('Unexpected error fetching document by ID: $e');
      return null;
    }
  }

  @override
  Future<QuerySnapshot> getDocumentsByQuery(String collection, {String? field, dynamic value}) async {
    try {
      if (field != null && value != null) {
        return await _firestore.collection(collection).where(field, isEqualTo: value).get();
      } else {
        return await _firestore.collection(collection).get();
      }
    } on FirebaseException catch (e) {
      print('Firestore error fetching documents by query: $e');
      rethrow;
    } catch (e) {
      print('Unexpected error fetching documents by query: $e');
      rethrow;
    }
  }

  @override
  Future<void> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).add(data);
    } on FirebaseException catch (e) {
      print('Firestore error adding document: $e');
      rethrow;
    } catch (e) {
      print('Unexpected error adding document: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } on FirebaseException catch (e) {
      print('Firestore error updating document: $e');
      rethrow;
    } catch (e) {
      print('Unexpected error updating document: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } on FirebaseException catch (e) {
      print('Firestore error deleting document: $e');
      rethrow;
    } catch (e) {
      print('Unexpected error deleting document: $e');
      rethrow;
    }
  }
}