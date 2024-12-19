import 'package:cloud_firestore/cloud_firestore.dart';

class Friend {
  final String friendId;
  final String name;
  final String profilePicture;

  Friend({
    required this.friendId,
    required this.name,
    this.profilePicture = '',
  });

  /// Convert Friend object to Firestore-compatible Map
  Map<String, dynamic> toFirestore() {
    return {
      'friendId': friendId,
      'name': name,
      'profilePicture': profilePicture,
    };
  }

  /// Create a Friend object from Firestore document
  factory Friend.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Friend(
      friendId: doc.id,
      name: data['name'] ?? 'No Name',
      profilePicture: data['profilePicture'] ?? '',
    );
  }
}
