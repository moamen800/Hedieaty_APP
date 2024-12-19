// import 'package:sqflite/sqflite.dart';
// import 'package:hedieaty/models/event_model.dart';
//
// class EventRepository {
//   final Database db;
//   static const String tableName = 'events'; // Table name for consistency
//
//   // Constructor
//   EventRepository(this.db);
//
//   /// Inserts a new event into the 'events' table
//   Future<void> insertEvent(Event event) async {
//     try {
//       await db.insert(
//         tableName,
//         event.toMap(),
//         conflictAlgorithm: ConflictAlgorithm.replace, // Replace on conflict
//       );
//     } catch (e) {
//       print('Error inserting event: $e');
//       rethrow;
//     }
//   }
//
//   /// Fetches all events from the 'events' table
//   Future<List<Event>> fetchAllEvents() async {
//     try {
//       final List<Map<String, dynamic>> maps = await db.query(tableName);
//       return maps.map((map) => Event.fromMap(map)).toList();
//     } catch (e) {
//       print('Error fetching all events: $e');
//       return [];
//     }
//   }
//
//   /// Fetches events for a specific user by user ID
//   Future<List<Event>> fetchEventsByUser(String userId) async {
//     try {
//       final List<Map<String, dynamic>> maps = await db.query(
//         tableName,
//         where: 'userId = ?',
//         whereArgs: [userId],
//       );
//       return maps.map((map) => Event.fromMap(map)).toList();
//     } catch (e) {
//       print('Error fetching events for user $userId: $e');
//       return [];
//     }
//   }
//
//   /// Updates an existing event by ID
//   Future<void> updateEvent(Event event) async {
//     try {
//       await db.update(
//         tableName,
//         event.toMap(),
//         where: 'id = ?',
//         whereArgs: [event.id],
//       );
//     } catch (e) {
//       print('Error updating event ${event.id}: $e');
//       rethrow;
//     }
//   }
//
//   /// Deletes an event by ID
//   Future<void> deleteEvent(String eventId) async {
//     try {
//       await db.delete(
//         tableName,
//         where: 'id = ?',
//         whereArgs: [eventId],
//       );
//     } catch (e) {
//       print('Error deleting event $eventId: $e');
//       rethrow;
//     }
//   }
// }
