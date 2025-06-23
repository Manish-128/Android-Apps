import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

typedef TableCreator = Future<void> Function(Database db);

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  final List<TableCreator> _tableCreators = [];

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  void registerTableCreator(TableCreator creator) {
    _tableCreators.add(creator);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        for (var creator in _tableCreators) {
          await creator(db);
        }
      },
    );
  }
}
