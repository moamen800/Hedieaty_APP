// import 'package:hedieaty/models/gift_model.dart';
// import 'package:sqflite/sqflite.dart';
//
// class GiftRepository {
//   final Database db;
//
//   // Constructor
//   GiftRepository(this.db);
//
//   /// Inserts a new gift into the 'gifts' table
//   Future<void> insertGift(GiftModel gift) async {
//     await db.insert(
//       'gifts',
//       gift.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace, // Replace if conflict occurs
//     );
//   }
//
//   /// Fetches all gifts from the 'gifts' table
//   Future<List<GiftModel>> fetchGifts() async {
//     final List<Map<String, dynamic>> maps = await db.query('gifts');
//
//     // Convert the list of maps into a list of GiftModel objects
//     return maps.map((map) => GiftModel.fromMap(map, '', '', '')).toList();
//   }
//
//   /// Fetches gifts by event ID
//   Future<List<GiftModel>> fetchGiftsByEvent(String eventId) async {
//     final List<Map<String, dynamic>> maps = await db.query(
//       'gifts',
//       where: 'eventId = ?', // WHERE clause to filter by eventId
//       whereArgs: [eventId],
//     );
//     return maps.map((map) => GiftModel.fromMap(map, '', eventId, '')).toList();
//   }
//
//   /// Updates an existing gift
//   Future<void> updateGift(GiftModel gift) async {
//     await db.update(
//       'gifts',
//       gift.toMap(),
//       where: 'giftId = ?', // WHERE clause to find the gift by its ID
//       whereArgs: [gift.giftId],
//     );
//   }
//
//   /// Deletes a gift by its ID
//   Future<void> deleteGift(String giftId) async {
//     await db.delete(
//       'gifts',
//       where: 'giftId = ?', // WHERE clause to find the gift by its ID
//       whereArgs: [giftId],
//     );
//   }
// }
