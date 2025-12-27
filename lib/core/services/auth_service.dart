import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // To check if we are on Web

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Listen to auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // --- GOOGLE SIGN IN (WEB VERSION) ---
  Future<void> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      // 1. WEB: Use the simple Popup
      if (kIsWeb) {
        userCredential = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        // Fallback for generic platforms (or just throw error if you only want web)
        throw "This feature is only for Web right now.";
      }

      // 2. Get the User
      User? user = userCredential.user;

      // 3. Create Profile in Database if new
      if (user != null) {
        final userDoc = await _db.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          UserModel newUser = UserModel(
            uid: user.uid,
            email: user.email!,
            name: user.displayName ?? "Student",
          );
          await _db.collection('users').doc(user.uid).set(newUser.toMap());
        }
      }
    } catch (e) {
      print("Google Sign In Error: $e");
      throw e;
    }
  }

  // --- EXISTING METHODS ---
  Future<void> signUp(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password
      );
      UserModel newUser = UserModel(
        uid: result.user!.uid, email: email, name: name
      );
      await _db.collection('users').doc(newUser.uid).set(newUser.toMap());
    } catch (e) { throw e; }
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}