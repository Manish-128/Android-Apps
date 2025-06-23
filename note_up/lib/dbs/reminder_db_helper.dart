import 'package:note_up/classes/reminder_class.dart';
import 'package:sqflite/sqflite.dart';
import 'database.dart';


class ReminderDbHelper {

  // Singleton pattern
  static final ReminderDbHelper instance = ReminderDbHelper._init();

  ReminderDbHelper._init();

  Future<Database> get database async {
    return await DatabaseHelper().database;
  }

  static Future<void> createRegisterTable(Database db) async {
    await db.execute('''
      CREATE TABLE reminder (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        time TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  // Register table creator
  static void registerRegisterTable() {
    DatabaseHelper().registerTableCreator(createRegisterTable);
  }



  // Create
  Future<int> createRegister(Reminder remainder) async {
    final db = await instance.database;
    return await db.insert('reminder', remainder.toMap());
  }

  // Read All
  Future<List<Reminder>> readAllRemainder() async {
    final db = await instance.database;
    final result = await db.query('reminder', orderBy: 'id DESC');
    return result.map((map) => Reminder.fromMap(map)).toList();
  }

  // Read Single
  Future<Reminder?> readRemainder(int id) async {
    final db = await instance.database;
    final result = await db.query('reminder', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Reminder.fromMap(result.first) : null;
  }

  // Update
  Future<int> updateRemainder(Reminder remainder) async {
    final db = await instance.database;
    return db.update('reminder', remainder.toMap(), where: 'id = ?', whereArgs: [remainder.id]);
  }

  // Delete
  Future<int> deleteRemainder(int id) async {
    final db = await instance.database;
    return await db.delete('reminder', where: 'id = ?', whereArgs: [id]);
  }

  // Close
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}