import 'package:note_up/classes/todo_class.dart';
import 'package:note_up/functionality/todo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'database.dart';

class TodoDbHelper {

  // Singleton pattern
  static final TodoDbHelper instance = TodoDbHelper._init();

  TodoDbHelper._init();

  Future<Database> get database async {
    return await DatabaseHelper().database;
  }

  static Future<void> createTodoTable(Database db) async {
    await db.execute('''
      CREATE TABLE todo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        workList TEXT
      )
    ''');
  }

  // Register table creator
  static void registerTodoTable() {
    DatabaseHelper().registerTableCreator(createTodoTable);
  }



  // Create
  Future<int> createTodo(toDOList todo) async {
    final db = await instance.database;
    return await db.insert('todo', todo.toMap());
  }

  // Read All
  Future<List<toDOList>> readAllTodos() async {
    final db = await instance.database;
    final result = await db.query('todo', orderBy: 'id DESC');
    return result.map((map) => toDOList.fromMap(map)).toList();
  }

  // Read Single
  Future<toDOList?> readTodo(int id) async {
    final db = await instance.database;
    final result = await db.query('todo', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? toDOList.fromMap(result.first) : null;
  }

  // Update
  Future<int> updateTodo(toDOList todo) async {
    final db = await instance.database;
    return db.update('todo', todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
  }

  // Delete
  Future<int> deleteTodo(int id) async {
    final db = await instance.database;
    return await db.delete('todo', where: 'id = ?', whereArgs: [id]);
  }

  // Close
  Future close() async {
    final db = await instance.database;
    db.close();
  }


}