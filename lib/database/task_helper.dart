import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CafeHelper {
  static Database? _db;

  static Future<Database> getDB() async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'cafe_data.db'),
      onCreate: (db, version) {
        return db.execute(
            "CREATE TABLE items(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, note TEXT, parentId INTEGER, price TEXT, status TEXT, userId INTEGER)"
        );
      },
      version: 1,
    );
    return _db!;
  }

  static Future<int> insertItem(Map<String, dynamic> data) async {
    final db = await getDB();
    return await db.insert('items', data);
  }

  static Future<List<Map<String, dynamic>>> getItems(int? parentId, int userId) async {
    final db = await getDB();
    return await db.query('items',
        where: 'parentId ${parentId == null ? "IS NULL" : "= ?"} AND userId = ?',
        whereArgs: parentId == null ? [userId] : [parentId, userId]);
  }

  static Future<int> updateStatus(int id, String? status) async {
    final db = await getDB();
    return await db.update('items', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> deleteItem(int id) async {
    final db = await getDB();
    return await db.delete('items', where: 'id = ? OR parentId = ?', whereArgs: [id, id]);
  }
}