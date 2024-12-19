// import 'package:hedieaty/models/friend_model.dart';
// import 'package:sqflite/sqflite.dart';
//
// class FriendRepository {
//   final Database db;
//
//   // Constructor
//   FriendRepository(this.db);
//
//   /// Inserts a new friend into the 'friends' table
//   Future<void> insertFriend(Friend friend) async {
//     await db.insert(
//       'friends',
//       friend.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace, // Replaces if conflict occurs
//     );
//   }
//
//   /// Fetches all friends from the 'friends' table
//   Future<List<Friend>> fetchFriends() async {
//     final List<Map<String, dynamic>> maps = await db.query('friends');
//
//     // Convert the list of maps into a list of Friend objects
//     return maps.map((map) => Friend.fromMap(map)).toList();
//   }
//
//   /// Deletes a friend by userId and friendId
//   Future<void> deleteFriend(String userId, String friendId) async {
//     await db.delete(
//       'friends',
//       where: 'userId = ? AND friendId = ?', // WHERE clause
//       whereArgs: [userId, friendId],
//     );
//   }
// }