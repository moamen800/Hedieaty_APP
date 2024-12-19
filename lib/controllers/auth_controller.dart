import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthController {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firebase Sign-In
  Future<Map<String, String>?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      final firebaseUser = credential.user;

      if (firebaseUser != null) {
        final user = await getUser(firebaseUser.uid);
        if (user != null) {
          return {'name': user.name, 'email': user.email};
        }
      }
    } catch (e) {
      print('Error signing in: $e');
    }
    return null;
  }

  // Firebase Sign-Up
  Future<Map<String, String>?> signUp(String email, String password, String name, String preferences) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      final firebaseUser = credential.user;

      if (firebaseUser != null) {
        final newUser = User(
          id: firebaseUser.uid,
          name: name,
          email: email,
          preferences: preferences,
        );
        await createUser(newUser);

        return {'name': name, 'email': email};
      }
    } catch (e) {
      print('Error signing up: $e');
    }
    return null;
  }

  // Firebase Sign-Out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Fetch current user's profile
  Future<Map<String, String>?> getUserProfile() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        final user = await getUser(firebaseUser.uid);
        if (user != null) {
          return {'name': user.name, 'email': user.email};
        }
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
    return null;
  }

  Future<String?> getCurrentUserId() async {
    final user = _firebaseAuth.currentUser;
    return user?.uid;
  }

  // -------------------------
  // User Firestore Operations
  // -------------------------

  Future<void> createUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toFirestore());
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Future<User?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromFirestore(doc);
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
    return null;
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }
}
