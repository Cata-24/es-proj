import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screen/login/login.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String? get uid => FirebaseAuth.instance.currentUser?.uid;
  String? get email => FirebaseAuth.instance.currentUser?.email;
  String? get name => FirebaseAuth.instance.currentUser?.displayName;
  
  Future<String?> signup({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('user').doc(user.uid).set({
          'userId': user.uid,
          'name': name,
          'email': email,
        });

        return user.uid;
      }
    } on FirebaseAuthException catch (e) {
      String message = ' ';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is badly formatted.';
      } else {
        message = e.message ?? 'An unknown error occurred.';
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return null;
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<String?> signin({
    required String email,
    required String password,
    required BuildContext context
  }) async {
    
    try {

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

      final uid = credential.user?.uid;

      if (uid != null) {
        final userDoc = await FirebaseFirestore.instance.collection('user').doc(uid).get();
        final userName = userDoc.data()?['name'];

        if (userName != null && userName.isNotEmpty) {
          await credential.user?.updateDisplayName(userName);
          await credential.user?.reload();
        }
      }

    final firebaseUser = credential.user;

    if (firebaseUser != null) {
      return firebaseUser.uid;
    }

    return null; 
      
    } on FirebaseAuthException catch(e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-credential') {
        message = 'Wrong password provided for that user.';
      }
       Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return null;
    }
    catch(e){
      return null;
    }
  }
  Future<void> signout({
    required BuildContext context
  }) async {
    
    await FirebaseAuth.instance.signOut();
    await Future.delayed(const Duration(seconds: 1));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) =>LoginScreen()
        )
      );
  }

  Future<String> getUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('user').doc(user.uid).get();
      final name = doc.data()?['name'] ?? '';
      return name;
    }
    return '';
  }
  
  Future<String> getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('user').doc(user.uid).get();
      final userId = doc.data()?['userId'] ?? '';
      return userId;
    }
    return '';
  }

  Future<bool> emailAlreadyExists(String email) async {
    final query = await FirebaseFirestore.instance
        .collection('user')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

}