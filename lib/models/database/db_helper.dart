// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
//
// class DBHelper {
//   static const _dbName = 'hedieaty.db';
//   static const _dbVersion = 1;
//
//   static Future<Database> initDB() async {
//     // Get the database path
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, _dbName);
//
//     // Open or create the database
//     return openDatabase(
//       path,
//       version: _dbVersion,
//       onCreate: (db, version) async {
//         // Create the users table
//         await db.execute('''
//           CREATE TABLE users (
//             id TEXT PRIMARY KEY,
//             name TEXT NOT NULL,
//             email TEXT NOT NULL,
//             preferences TEXT
//           )
//         ''');
//
//         // Create the events table
//         await db.execute('''
//           CREATE TABLE events (
//             id TEXT PRIMARY KEY,
//             name TEXT NOT NULL,
//             date TEXT,
//             location TEXT,
//             description TEXT,
//             userId TEXT
//           )
//         ''');
//
//         // Create the gifts table
//         await db.execute('''
//           CREATE TABLE gifts (
//             id TEXT PRIMARY KEY,
//             name TEXT NOT NULL,
//             description TEXT,
//             category TEXT,
//             price REAL,
//             status TEXT,
//             eventId TEXT
//           )
//         ''');
//
//         // Create the friends table
//         await db.execute('''
//           CREATE TABLE friends (
//             userId TEXT,
//             friendId TEXT,
//             PRIMARY KEY (userId, friendId)
//           )
//         ''');
//       },
//     );
//   }
// }