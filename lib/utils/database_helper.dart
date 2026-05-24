import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nutrisee.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // Tabel Profil Pengguna
    await db.execute('''
      CREATE TABLE users (
        id $idType,
        name $textType,
        email $textType,
        gender $textType,
        birthDate $textType,
        weight $realType,
        height $realType,
        targetWeight $realType,
        profileImage $textType
      )
    ''');

    // Tabel Log Makanan
    await db.execute('''
      CREATE TABLE foods (
        id $idType,
        name $textType,
        category $textType,
        portion $intType,
        calories $intType,
        carbs $realType,
        protein $realType,
        fat $realType,
        createdAt $textType
      )
    ''');

    // Tabel Log Aktivitas
    await db.execute('''
      CREATE TABLE activities (
        id $idType,
        name $textType,
        intensity $textType,
        duration $intType,
        caloriesBurned $intType,
        createdAt $textType
      )
    ''');
  }

  // --- Operasi CRUD: Makanan ---
  Future<int> insertFood(Map<String, dynamic> food) async {
    final db = await instance.database;
    return await db.insert('foods', food,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getFoodsByDate(String date) async {
    final db = await instance.database;
    return await db.query(
      'foods',
      where: 'createdAt LIKE ?',
      whereArgs: ['$date%'],
      orderBy: 'createdAt DESC',
    );
  }

  // --- Operasi CRUD: Aktivitas ---
  Future<int> insertActivity(Map<String, dynamic> activity) async {
    final db = await instance.database;
    return await db.insert('activities', activity,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getActivitiesByDate(String date) async {
    final db = await instance.database;
    return await db.query(
      'activities',
      where: 'createdAt LIKE ?',
      whereArgs: ['$date%'],
      orderBy: 'createdAt DESC',
    );
  }

  // --- Operasi CRUD: Profil Pengguna ---
  Future<int> saveUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    // Asumsi: Aplikasi *single-user* lokal, selalu perbarui baris pertama (ID 1)
    final existingUser =
        await db.query('users', where: 'id = ?', whereArgs: [1]);
    if (existingUser.isEmpty) {
      user['id'] = 1;
      return await db.insert('users', user);
    } else {
      return await db.update('users', user, where: 'id = ?', whereArgs: [1]);
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    final db = await instance.database;
    final result =
        await db.query('users', where: 'id = ?', whereArgs: [1], limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  // --- Fungsi Mengubah Data (Update) ---
  Future<int> updateFood(Map<String, dynamic> food) async {
    final db = await instance.database;
    // Mengubah data makanan spesifik berdasarkan ID
    return await db.update(
      'foods',
      food,
      where: 'id = ?',
      whereArgs: [food['id']],
    );
  }

  Future<int> updateActivity(Map<String, dynamic> activity) async {
    final db = await instance.database;
    // Mengubah data aktivitas spesifik berdasarkan ID
    return await db.update(
      'activities',
      activity,
      where: 'id = ?',
      whereArgs: [activity['id']],
    );
  }

  // --- Fungsi Menghapus Data (Delete) ---
  Future<int> deleteFood(int id) async {
    final db = await instance.database;
    // Menghapus baris makanan secara permanen dari penyimpanan lokal
    return await db.delete(
      'foods',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteActivity(int id) async {
    final db = await instance.database;
    // Menghapus baris aktivitas secara permanen dari penyimpanan lokal
    return await db.delete(
      'activities',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
