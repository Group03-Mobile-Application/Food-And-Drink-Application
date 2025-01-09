import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:path/path.dart' as p;
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
    final path = p.join(dbPath, fileName);

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

  Future<List<Map<String, dynamic>>> getMealsByDay(String day) async {
    final db = await instance.database;
    return await db.query('meal_plans', where: 'day = ?', whereArgs: [day]);
  }

  Future<int> updateMealPlan(int id, Map<String, dynamic> mealPlan) async {
    final db = await instance.database;
    return await db.update('meal_plans', mealPlan, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteMealPlan(int id) async {
    final db = await instance.database;
    return await db.delete('meal_plans', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({Key? key}) : super(key: key);

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final MealPlanDatabaseHelper _dbHelper = MealPlanDatabaseHelper.instance;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _mealPlans = [];

  Future<void> _loadMeals() async {
    final meals = await _dbHelper.getMealsByDay(_selectedDate.toIso8601String().split('T').first);
    setState(() {
      _mealPlans = meals;
    });
  }

  Future<void> _addOrEditMeal({Map<String, dynamic>? meal}) async {
    final TextEditingController mealController = TextEditingController(
      text: meal != null ? meal['mealDescription'] : '',
    );

    String mealType = meal?['mealType'] ?? 'Breakfast';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(meal != null ? 'Edit Meal' : 'Add Meal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: mealType,
                items: ['Breakfast', 'Lunch', 'Dinner', 'Dessert']
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    mealType = value!;
                  });
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: mealController,
                decoration: const InputDecoration(hintText: 'Enter meal description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final mealData = {
                  'day': _selectedDate.toIso8601String().split('T').first,
                  'mealType': mealType,
                  'mealDescription': mealController.text,
                };
                if (meal == null) {
                  await _dbHelper.insertMealPlan(mealData);
                } else {
                  await _dbHelper.updateMealPlan(meal['id'], mealData);
                }
                await _loadMeals();
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

  }

  Future<void> _deleteMeal(int id) async {
    await _dbHelper.deleteMealPlan(id);
    await _loadMeals();
  }

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0cb3ab),
        title: const Text('Meal Plan'),
      ),
      body: Column(
        children: [
          // Calendar
          TableCalendar(
            focusedDay: _selectedDate,
            firstDay: DateTime.utc(2000),
            lastDay: DateTime.utc(2100),
            calendarFormat: CalendarFormat.week,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
              _loadMeals();
            },
            headerStyle: const HeaderStyle(formatButtonVisible: false),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Color(0xff0eb4ac), shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Color(0xff0cb3ab), shape: BoxShape.circle),
            ),
          ),
          // Meals List
          Expanded(
            child: ListView.builder(
              itemCount: _mealPlans.length,
              itemBuilder: (context, index) {
                final meal = _mealPlans[index];
                return ListTile(
                  title: Text('${meal['mealType']}: ${meal['mealDescription']}'),
                  subtitle: Text('Day: ${meal['day']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _addOrEditMeal(meal: meal),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMeal(meal['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => _addOrEditMeal(),
            child: const Text('Add Meal'),
          ),
        ],
      ),
    );
  }
}