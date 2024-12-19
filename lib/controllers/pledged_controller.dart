import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PledgedController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch pledged gifts as a stream of formatted maps
  Future<List<Map<String, dynamic>>> fetchPledgedGifts(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('pledgedGifts')
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          ...doc.data(),
          'id': doc.id,
        };
      }).toList();
    } catch (e) {
      print('Error fetching pledged gifts: $e');
      return [];
    }
  }

  /// Toggle the pledge status of a gift
  Future<void> togglePledgeStatus({
    required String friendId,
    required String eventId,
    required String giftId,
    required bool isPledged,
  }) async {
    if (isPledged) {
      await unpledgeGift(friendId: friendId, eventId: eventId, giftId: giftId);
    } else {
      await pledgeGift(friendId: friendId, eventId: eventId, giftId: giftId);
    }
  }

  Future<void> pledgeGift({
    required String friendId,
    required String eventId,
    required String giftId,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in!');

    final userDoc = await _firestore.collection('users').doc(userId).get();
    final giftDoc = await _firestore
        .collection('users')
        .doc(friendId)
        .collection('events')
        .doc(eventId)
        .collection('gifts')
        .doc(giftId)
        .get();

    if (!userDoc.exists || !giftDoc.exists) {
      throw Exception('User or gift not found!');
    }

    final giftData = giftDoc.data();
    final userName = userDoc.data()?['name'] ?? 'Someone';

    // Add gift to the current user's pledgedGifts collection
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('pledgedGifts')
        .doc(giftId)
        .set({
      ...giftData!,
      'pledgedFrom': friendId,
      'status': 'pledged',
    });

    // Update the gift's status in the friend's gifts collection
    await _firestore
        .collection('users')
        .doc(friendId)
        .collection('events')
        .doc(eventId)
        .collection('gifts')
        .doc(giftId)
        .update({'status': 'pledged'});

    // Add notification to the friend's notifications collection
    await _firestore
        .collection('users')
        .doc(friendId) // Notification sent to the owner of the gift
        .collection('notifications')
        .doc(giftId)
        .set({
      'senderId': userId, // The pledger's ID
      'senderName': userName,
      'giftName': giftData['name'],
      'read': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unpledgeGift({
    required String friendId,
    required String eventId,
    required String giftId,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in!');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('pledgedGifts')
        .doc(giftId)
        .delete();

    await _firestore
        .collection('users')
        .doc(friendId)
        .collection('events')
        .doc(eventId)
        .collection('gifts')
        .doc(giftId)
        .update({'status': 'available'});
  }
}