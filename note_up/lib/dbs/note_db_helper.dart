import 'package:sqflite/sqflite.dart';
import 'package:note_up/classes/note_class.dart';

import 'database.dart';

class NoteDbHelper {

  // Singleton pattern
  static final NoteDbHelper instance = NoteDbHelper._init();

  NoteDbHelper._init();

  Future<Database> get database async {
    return await DatabaseHelper().database;
  }

  static Future<void> createNotesTable(Database db) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        imgKey INTEGER
      )
    ''');
  }

  // Register table creator
  static void registerNotesTable() {
    DatabaseHelper().registerTableCreator(createNotesTable);
  }



  // Create
  Future<int> createNote(Note note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  // Read All
  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes', orderBy: 'id DESC');
    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Read Single
  Future<Note?> readNote(int id) async {
    final db = await instance.database;
    final result = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? Note.fromMap(result.first) : null;
  }

  // Update
  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    return db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  // Delete
  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Close
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}