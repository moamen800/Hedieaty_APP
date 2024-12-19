import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gift_model.dart';

class GiftController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream to get all gifts for a specific event
  Stream<List<GiftModel>> getGifts(String userId, String eventId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .collection('gifts')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return GiftModel.fromMap(
          doc.data(),
          doc.id,
          eventId,
          userId,
        );
      }).toList();
    });
  }

  /// Add a new gift
  Future<void> addGift({
    required String userId,
    required String eventId,
    required String name,
    required String category,
    required String description,
    required double price,
  }) async {
    try {
      final giftId = _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc()
          .id;

      final gift = GiftModel(
        userId: userId,
        eventId: eventId,
        giftId: giftId,
        name: name,
        category: category,
        description: description,
        status: 'available',
        price: price,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .set(gift.toMap());
    } catch (e) {
      throw Exception('Failed to add gift: $e');
    }
  }

  /// Edit an existing gift
  Future<void> editGift({
    required String userId,
    required String eventId,
    required String giftId,
    required String name,
    required String description,
    required String category,
    required String status,
    required double price,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .update({
        'name': name,
        'description': description,
        'category': category,
        'status': status,
        'price': price,
      });
    } catch (e) {
      throw Exception('Failed to edit gift: $e');
    }
  }

  /// Delete a gift
  Future<void> deleteGift({
    required String userId,
    required String eventId,
    required String giftId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete gift: $e');
    }
  }

  /// Get pledged gifts for a specific event
  Stream<List<GiftModel>> getPledgedGifts(String userId, String eventId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .collection('gifts')
        .where('status', isEqualTo: 'pledged')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return GiftModel.fromMap(
          doc.data(),
          doc.id,
          eventId,
          userId,
        );
      }).toList();
    });
  }
}
