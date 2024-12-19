import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String name;
  String email;
  String preferences;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.preferences,
  });

  // Firestore Mapping
  Map<String, dynamic> toFirestore() => {
    'id': id,
    'name': name,
    'email': email,
    'preferences': preferences,
  };

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      preferences: data['preferences'],
    );
  }
}
