import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AuthHelper {
  static Database? _db;

  static Future<Database> getDB() async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'user_data.db'),
      onCreate: (db, version) {
        return db.execute(
            "CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, password TEXT)"
        );
      },
      version: 1,
    );
    return _db!;
  }

  static Future<int> register(String user, String pass) async {
    final db = await getDB();
    try {
      return await db.insert('users', {'username': user, 'password': pass});
    } catch (e) { return -1; }
  }

  static Future<Map<String, dynamic>?> login(String user, String pass) async {
    final db = await getDB();
    List<Map<String, dynamic>> res = await db.query('users',
        where: 'username = ? AND password = ?', whereArgs: [user, pass]);
    return res.isNotEmpty ? res.first : null;
  }
}