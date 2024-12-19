import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a new event for a user
  Future<void> addEvent({
    required String userId,
    required String name,
    required String date,
    required String location,
    required String description,
  }) async {
    try {
      final eventId = DateTime.now().millisecondsSinceEpoch.toString();
      final newEvent = Event(
        id: eventId,
        name: name,
        date: date,
        location: location,
        description: description,
        userId: userId,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .set(newEvent.toFirestore());
    } catch (e) {
      print('Error adding event: $e');
      rethrow;
    }
  }

  /// Update an existing event
  Future<void> updateEvent({
    required String userId,
    required String eventId,
    required String name,
    required String date,
    required String location,
    required String description,
  }) async {
    try {
      final updatedEvent = Event(
        id: eventId,
        name: name,
        date: date,
        location: location,
        description: description,
        userId: userId,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .update(updatedEvent.toFirestore());
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

  /// Delete an event
  Future<void> deleteEvent(String userId, String eventId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .delete();
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }

  /// Fetch all events as a list of `Event` objects
  Future<List<Event>> fetchEventsForUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .get();

      return querySnapshot.docs.map((doc) => Event.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  /// Fetch events as a list of formatted maps for UI
  Future<List<Map<String, dynamic>>> fetchEventsForView(String userId) async {
    final events = await fetchEventsForUser(userId);
    return events.map((event) {
      return {
        'id': event.id,
        'name': event.name,
        'date': event.date,
        'location': event.location,
        'description': event.description,
      };
    }).toList();
  }

  /// Stream events for real-time updates
  Stream<List<Map<String, dynamic>>> fetchEventsForViewAsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('events')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final event = Event.fromFirestore(doc);
        return {
          'id': event.id,
          'name': event.name,
          'date': event.date,
          'location': event.location,
          'description': event.description,
        };
      }).toList();
    });
  }
}
