// import 'package:hedieaty/models/user_model.dart';
// import 'package:sqflite/sqflite.dart';
//
// class UserRepository {
//   final Database db;
//
//   // Constructor
//   UserRepository(this.db);
//
//   /// Inserts a new user into the 'users' table
//   Future<void> insertUser(User user) async {
//     await db.insert(
//       'users',
//       user.toMap(),
//       conflictAlgorithm: ConflictAlgorithm.replace, // Replace if conflict occurs
//     );
//   }
//
//   /// Fetches all users from the 'users' table
//   Future<List<User>> fetchUsers() async {
//     final List<Map<String, dynamic>> maps = await db.query('users');
//
//     // Convert the list of maps into a list of User objects
//     return maps.map((map) => User.fromMap(map)).toList();
//   }
//
//   /// Fetches a user by ID
//   Future<User?> fetchUserById(String id) async {
//     final List<Map<String, dynamic>> maps = await db.query(
//       'users',
//       where: 'id = ?', // WHERE clause to filter by ID
//       whereArgs: [id],
//     );
//
//     if (maps.isNotEmpty) {
//       return User.fromMap(maps.first); // Return the first result
//     }
//     return null; // Return null if no user is found
//   }
//
//   /// Updates an existing user
//   Future<void> updateUser(User user) async {
//     await db.update(
//       'users',
//       user.toMap(),
//       where: 'id = ?', // WHERE clause to find the user by their ID
//       whereArgs: [user.id],
//     );
//   }
//
//   /// Deletes a user by ID
//   Future<void> deleteUser(String userId) async {
//     await db.delete(
//       'users',
//       where: 'id = ?', // WHERE clause to find the user by their ID
//       whereArgs: [userId],
//     );
//   }
// }