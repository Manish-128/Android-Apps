import 'package:note_up/classes/image_class.dart';
import 'package:sqflite/sqflite.dart';
import 'package:note_up/classes/note_class.dart';

import 'database.dart';

class ImageDbHelper {

  // Singleton pattern
  static final ImageDbHelper instance = ImageDbHelper._init();

  ImageDbHelper._init();

  Future<Database> get database async {
    return await DatabaseHelper().database;
  }

  static Future<void> createImageTable(Database db) async {
    await db.execute('''
      CREATE TABLE images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imageOne TEXT,
        imageTwo TEXT,
        imageThree TEXT
      )
    ''');
  }

  // Register table creator
  static void registerImageTable() {
    DatabaseHelper().registerTableCreator(createImageTable);
  }



  // Create
  Future<int> createImage(ImageClass img) async {
    final db = await instance.database;
    return await db.insert('images', img.toMap());
  }

  // Read All
  Future<List<ImageClass>> readAllImage() async {
    final db = await instance.database;
    final result = await db.query('images', orderBy: 'id DESC');
    return result.map((map) => ImageClass.fromMap(map)).toList();
  }

  // Read Single
  Future<ImageClass?> readImage(int id) async {
    final db = await instance.database;
    final result = await db.query('images', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? ImageClass.fromMap(result.first) : null;
  }

  // Update
  Future<int> updateImage(ImageClass img) async {
    final db = await instance.database;
    return db.update('images', img.toMap(), where: 'id = ?', whereArgs: [img.id]);
  }

  // Delete
  Future<int> deleteImage(int id) async {
    final db = await instance.database;
    return await db.delete('images', where: 'id = ?', whereArgs: [id]);
  }

  // Close
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}