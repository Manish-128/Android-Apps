// import 'package:sqflite/sqflite.dart';
// import 'package:note_up/classes/Code.dart';
// import 'package:note_up/dbs/database.dart';
//
// class CodeModelHelper {
//   // Singleton pattern
//   static final CodeModelHelper instance = CodeModelHelper._init();
//
//   CodeModelHelper._init();
//
//   Future<Database> get database async {
//     return await DatabaseHelper().database;
//   }
//
//   static Future<void> createCodeTable(Database db) async {
//     await db.execute('''
//       CREATE TABLE code (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         content TEXT NOT NULL,
//         analysis TEXT
//       )
//     ''');
//   }
//
//   // Register table creator
//   static void registerCodeTable() {
//     DatabaseHelper().registerTableCreator(createCodeTable);
//   }
//
//   // Create
//   Future<int> createCode(Code code) async {
//     final db = await instance.database;
//     return await db.insert('code', code.toMap());
//   }
//
//   // Read All
//   Future<List<Code>> readAllCode() async {
//     final db = await instance.database;
//     final result = await db.query('code', orderBy: 'id DESC');
//     return result.map((map) => Code.fromMap(map)).toList();
//   }
//
//   // Read Single
//   Future<Code?> readCode(int id) async {
//     final db = await instance.database;
//     final result = await db.query('code', where: 'id = ?', whereArgs: [id]);
//     return result.isNotEmpty ? Code.fromMap(result.first) : null;
//   }
//
//   // Update
//   Future<int> updateCode(Code code) async {
//     final db = await instance.database;
//     return db.update('code', code.toMap(), where: 'id = ?', whereArgs: [code.id]);
//   }
//
//   // Delete
//   Future<int> deleteCode(int id) async {
//     final db = await instance.database;
//     return await db.delete('code', where: 'id = ?', whereArgs: [id]);
//   }
//
//   // Close
//   Future close() async {
//     final db = await instance.database;
//     db.close();
//   }
// }


import 'package:sqflite/sqflite.dart';
import 'package:note_up/classes/Code.dart';
import 'package:note_up/dbs/database.dart';

class CodeModelHelper {
  // Singleton pattern
  static final CodeModelHelper instance = CodeModelHelper._init();

  CodeModelHelper._init();

  Future<Database> get database async {
    return await DatabaseHelper().database;
  }

  static Future<void> createCodeTable(Database db) async {
    await db.execute('''
      CREATE TABLE code (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT NOT NULL,
        analysis TEXT
      )
    ''');
  }

  // Register table creator
  static void registerCodeTable() {
    DatabaseHelper().registerTableCreator(createCodeTable);
  }

  // Create
  Future<int> createCode(Code code) async {
    final db = await instance.database;
    return await db.insert('code', code.toMap());
  }

  // Read All
  Future<List<Code>> readAllCode() async {
    final db = await instance.database;
    final result = await db.query('code', orderBy: 'id DESC');
    return result.map((map) => Code.fromMap(map)).toList();
  }

  // Read Single
  Future<Code?> readCode(int id) async {
    final db = await instance.database;
    final result = await db.query('code', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Code.fromMap(result.first) : null;
  }

  // Update
  Future<int> updateCode(Code code) async {
    final db = await instance.database;
    return db.update('code', code.toMap(), where: 'id = ?', whereArgs: [code.id]);
  }

  // Delete
  Future<int> deleteCode(int id) async {
    final db = await instance.database;
    return await db.delete('code', where: 'id = ?', whereArgs: [id]);
  }

  // Close
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}