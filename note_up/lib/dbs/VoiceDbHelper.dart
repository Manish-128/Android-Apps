// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:note_up/classes/voiceLog.dart';
// class VoiceLogDb {
//   static final VoiceLogDb _instance = VoiceLogDb._internal();
//   factory VoiceLogDb() => _instance;
//   VoiceLogDb._internal();
//
//   Database? _db;
//
//   Future<Database> get database async {
//     if (_db != null) return _db!;
//     _db = await _initDb();
//     return _db!;
//   }
//
//   Future<Database> _initDb() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'voice_logs.db');
//
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE logs (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             timestamp TEXT,
//             spokenInput TEXT,
//             command TEXT,
//             response TEXT
//           )
//         ''');
//       },
//     );
//   }
//
//   Future<void> insertLog(VoiceLog log) async {
//     final db = await database;
//     await db.insert('logs', log.toMap());
//   }
//
//   Future<List<VoiceLog>> getLogs() async {
//     final db = await database;
//     final maps = await db.query('logs', orderBy: 'id DESC');
//
//     return maps.map((map) => VoiceLog.fromMap(map)).toList();
//   }
//
//   Future<void> clearLogs() async {
//     final db = await database;
//     await db.delete('logs');
//   }
// }


import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:note_up/classes/voiceLog.dart';

class VoiceLogDb {
  static final VoiceLogDb _instance = VoiceLogDb._internal();
  factory VoiceLogDb() => _instance;
  VoiceLogDb._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'voice_logs.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT,
            spokenInput TEXT,
            command TEXT,
            response TEXT,
            status TEXT
          )
        ''');
      },
    );
  }

  Future<void> insertLog(VoiceLog log) async {
    final db = await database;
    await db.insert('logs', log.toMap());
  }

  Future<List<VoiceLog>> getLogs() async {
    final db = await database;
    final maps = await db.query('logs', orderBy: 'id DESC');
    return maps.map((map) => VoiceLog.fromMap(map)).toList();
  }

  Future<void> clearLogs() async {
    final db = await database;
    await db.delete('logs');
  }
}