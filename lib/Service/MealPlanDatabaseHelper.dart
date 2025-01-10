import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MealPlanDatabaseHelper {
  static final MealPlanDatabaseHelper instance = MealPlanDatabaseHelper._init();
  static Database? _database;

  MealPlanDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('meal_plans.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE meal_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day TEXT NOT NULL,
        mealType TEXT NOT NULL,
        mealDescription TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertMealPlan(Map<String, dynamic> mealPlan) async {
    final db = await instance.database;
    return await db.insert('meal_plans', mealPlan);
  }

  Future<int> updateMealPlan(int id, Map<String, dynamic> mealPlan) async {
    final db = await instance.database;
    return await db.update(
      'meal_plans',
      mealPlan,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMealPlan(int id) async {
    final db = await instance.database;
    return await db.delete(
      'meal_plans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllMealPlans() async {
    final db = await instance.database;
    return await db.query('meal_plans');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}