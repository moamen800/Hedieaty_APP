import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/friend_model.dart';

class HomeController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Adds a friend using their email, ensuring the user cannot add themselves.
  Future<void> addFriendByEmail(String currentUserId, String friendEmail) async {
    final usersCollection = firestore.collection('users');

    try {
      final currentUserDoc = await usersCollection.doc(currentUserId).get();
      if (!currentUserDoc.exists) throw Exception("Current user data not found.");

      final currentUserEmail = currentUserDoc.data()?['email'];
      if (currentUserEmail == null) throw Exception("Your email is not set.");

      if (currentUserEmail == friendEmail) throw Exception("You cannot add yourself as a friend.");

      final querySnapshot = await usersCollection
          .where('email', isEqualTo: friendEmail)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) throw Exception("No user found with the provided email.");

      final friendDoc = querySnapshot.docs.first;
      final friendId = friendDoc.id;
      final friendName = friendDoc.data()?['name'] ?? 'No Name';
      final friendProfilePicture = friendDoc.data()?['profilePicture'] ?? '';

      final friendsRef = usersCollection.doc(currentUserId).collection('friends');
      final existingFriend = await friendsRef.doc(friendId).get();
      if (existingFriend.exists) throw Exception("Friend is already added.");

      final friend = Friend(
        friendId: friendId,
        name: friendName,
        profilePicture: friendProfilePicture,
      );

      await friendsRef.doc(friendId).set(friend.toFirestore());
    } catch (e) {
      print('Error adding friend by email: $e');
      throw Exception("Failed to add friend.");
    }
  }

  /// Deletes a friend from Firestore.
  Future<void> deleteFriend(String userId, String friendId) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(friendId)
          .delete();
    } catch (e) {
      print('Error deleting friend: $e');
      throw Exception("Failed to delete friend.");
    }
  }

  /// Displays a dialog for manual friend addition.
  void addFriendManually(BuildContext context, String userId, VoidCallback onFriendAdded) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Friend By Email'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Friend Email'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                final friendEmail = emailController.text.trim();
                if (friendEmail.isNotEmpty) {
                  try {
                    await addFriendByEmail(userId, friendEmail);
                    Navigator.of(context).pop();
                    onFriendAdded();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid email')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Fetches a list of friends formatted for the view.
  Future<List<Map<String, dynamic>>> getFriendsForView(String userId) async {
    try {
      final friendsRef = firestore
          .collection('users')
          .doc(userId)
          .collection('friends');

      final querySnapshot = await friendsRef.get();
      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs.map((doc) {
        final friend = Friend.fromFirestore(doc);
        return {
          'friendId': friend.friendId,
          'name': friend.name,
          'profilePicture': friend.profilePicture,
          'events': 0, // Placeholder for future functionality
        };
      }).toList();
    } catch (e) {
      print('Error fetching friends: $e');
      throw Exception('Failed to fetch friends.');
    }
  }
}
