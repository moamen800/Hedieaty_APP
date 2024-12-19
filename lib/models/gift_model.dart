import 'package:cloud_firestore/cloud_firestore.dart';

class GiftModel {
  final String userId;
  final String eventId;
  final String giftId;
  final String name;
  final String category;
  final String description;
  final String status;
  final double price;

  GiftModel({
    required this.userId,
    required this.eventId,
    required this.giftId,
    required this.name,
    required this.category,
    required this.description,
    required this.status,
    required this.price,
  });

  // Convert GiftModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'eventId': eventId,
      'giftId': giftId,
      'name': name,
      'category': category,
      'description': description,
      'status': status,
      'price': price,
    };
  }

  // Create a GiftModel from Firestore Map
  static GiftModel fromMap(Map<String, dynamic> map, String giftId, String eventId, String userId) {
    return GiftModel(
      userId: userId,
      eventId: eventId,
      giftId: giftId,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'available',
      price: map['price']?.toDouble() ?? 0.0,
    );
  }
}
