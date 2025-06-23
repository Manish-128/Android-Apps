import 'package:note_up/classes/watchlist_class.dart';
import 'package:sqflite/sqflite.dart';

import 'database.dart';

class WatchListDbHelper{

  // Singleton pattern
  static final WatchListDbHelper instance = WatchListDbHelper._init();

  WatchListDbHelper._init();

  Future<Database> get database async {
    return await DatabaseHelper().database;
  }

  static Future<void> createWatchlistTable(Database db) async {
    await db.execute('''
      CREATE TABLE watchlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        year INTEGER NOT NULL,
        image TEXT 
      )
    ''');
  }

  // Register table creator
  static void registerRegisterTable() {
    DatabaseHelper().registerTableCreator(createWatchlistTable);
  }



  // Create
  Future<int> createWatchlist(WatchListClass watchlist) async {
    final db = await instance.database;
    return await db.insert('watchlist', watchlist.toMap());
  }

  // Read All
  Future<List<WatchListClass>> readAllWatchlist() async {
    final db = await instance.database;
    final result = await db.query('watchlist', orderBy: 'id DESC');
    return result.map((map) => WatchListClass.fromMap(map)).toList();
  }

  // Read Single
  Future<WatchListClass?> readWatchlist(int id) async {
    final db = await instance.database;
    final result = await db.query('watchlist', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? WatchListClass.fromMap(result.first) : null;
  }

  // Update
  Future<int> updateWatchlist(WatchListClass watchlist) async {
    final db = await instance.database;
    return db.update('watchlist', watchlist.toMap(), where: 'id = ?', whereArgs: [watchlist.id]);
  }

  // Delete
  Future<int> deleteWatchlist(int id) async {
    final db = await instance.database;
    return await db.delete('watchlist', where: 'id = ?', whereArgs: [id]);
  }

  // Close
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}