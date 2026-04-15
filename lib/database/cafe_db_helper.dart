import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CafeDBHelper {
  static Database? _db;

  static Future<Database> getDB() async {
    if (_db != null) return _db!;
    // Nâng cấp lên v4 để làm mới database và thêm cột paidAt
    _db = await openDatabase(
      join(await getDatabasesPath(), 'cafe_pro_v4.db'),
      onCreate: (db, version) async {
        await db.execute("CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, password TEXT)");
        await db.execute("CREATE TABLE products(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, price REAL, description TEXT, imagePath TEXT, category TEXT, userId INTEGER)");
        await db.execute("CREATE TABLE tables(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, status TEXT, openedAt TEXT, guestCount INTEGER, userId INTEGER)");
        await db.execute("CREATE TABLE bills(id INTEGER PRIMARY KEY AUTOINCREMENT, tableId INTEGER, totalAmount REAL, status TEXT, createdAt TEXT, paidAt TEXT, userId INTEGER)");
        await db.execute("CREATE TABLE bill_details(id INTEGER PRIMARY KEY AUTOINCREMENT, billId INTEGER, productId INTEGER, quantity INTEGER, price REAL)");
      },
      version: 1,
    );
    return _db!;
  }
  
  // Auth
  static Future<int> register(String user, String pass) async {
    final db = await getDB();
    try { return await db.insert('users', {'username': user, 'password': pass}); } catch (e) { return -1; }
  }
  static Future<Map<String, dynamic>?> login(String user, String pass) async {
    final db = await getDB();
    var res = await db.query('users', where: 'username = ? AND password = ?', whereArgs: [user, pass]);
    return res.isNotEmpty ? res.first : null;
  }

  // Products
  static Future<int> addProduct(Map<String, dynamic> data) async {
    final db = await getDB();
    return await db.insert('products', data);
  }
  static Future<List<Map<String, dynamic>>> getProducts(int userId) async {
    final db = await getDB();
    return await db.query('products', where: 'userId = ?', whereArgs: [userId]);
  }
  static Future<int> deleteProduct(int id) async {
    final db = await getDB();
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // Tables
  static Future<int> addTable(Map<String, dynamic> data) async {
    final db = await getDB();
    return await db.insert('tables', data);
  }
  static Future<List<Map<String, dynamic>>> getTables(int userId) async {
    final db = await getDB();
    return await db.rawQuery('''
      SELECT t.*, (SELECT SUM(bd.quantity) FROM bill_details bd JOIN bills b ON bd.billId = b.id WHERE b.tableId = t.id AND b.status = 'Pending') as itemCount
      FROM tables t
      WHERE t.userId = ?
    ''', [userId]);
  }
  static Future<int> updateTableStatus(int id, String status, {String? openedAt, int? guestCount}) async {
    final db = await getDB();
    Map<String, dynamic> values = {'status': status};
    values['openedAt'] = openedAt;
    values['guestCount'] = guestCount ?? 0;
    return await db.update('tables', values, where: 'id = ?', whereArgs: [id]);
  }
  static Future<int> deleteTable(int id) async {
    final db = await getDB();
    return await db.delete('tables', where: 'id = ?', whereArgs: [id]);
  }

  // Orders/Bills
  static Future<int> startBill(int tableId, int userId) async {
    final db = await getDB();
    return await db.insert('bills', {
      'tableId': tableId,
      'totalAmount': 0.0,
      'status': 'Pending',
      'createdAt': DateTime.now().toIso8601String(),
      'userId': userId
    });
  }

  static Future<int> addToBill(int billId, int productId, double price, {int quantity = 1}) async {
    final db = await getDB();
    var existing = await db.query('bill_details', where: 'billId = ? AND productId = ?', whereArgs: [billId, productId]);
    if (existing.isNotEmpty) {
      int newQty = (existing.first['quantity'] as int) + quantity;
      return await db.update('bill_details', {'quantity': newQty}, where: 'id = ?', whereArgs: [existing.first['id']]);
    } else {
      return await db.insert('bill_details', {
        'billId': billId,
        'productId': productId,
        'quantity': quantity,
        'price': price
      });
    }
  }

  static Future<int> removeFromBill(int billId, int productId) async {
    final db = await getDB();
    var existing = await db.query('bill_details', where: 'billId = ? AND productId = ?', whereArgs: [billId, productId]);
    if (existing.isNotEmpty) {
      int currentQty = existing.first['quantity'] as int;
      if (currentQty > 1) {
        return await db.update('bill_details', {'quantity': currentQty - 1}, where: 'id = ?', whereArgs: [existing.first['id']]);
      } else {
        return await db.delete('bill_details', where: 'id = ?', whereArgs: [existing.first['id']]);
      }
    }
    return 0;
  }

  static Future<Map<String, dynamic>?> getActiveBill(int tableId) async {
    final db = await getDB();
    var res = await db.query('bills', where: 'tableId = ? AND status = ?', whereArgs: [tableId, 'Pending']);
    return res.isNotEmpty ? res.first : null;
  }

  static Future<List<Map<String, dynamic>>> getBillItems(int billId) async {
    final db = await getDB();
    return await db.rawQuery('''
      SELECT bd.*, p.name 
      FROM bill_details bd 
      JOIN products p ON bd.productId = p.id 
      WHERE bd.billId = ?
    ''', [billId]);
  }

  static Future<void> closeBill(int billId, double totalAmount) async {
    final db = await getDB();
    await db.update('bills', {
      'status': 'Paid', 
      'totalAmount': totalAmount,
      'paidAt': DateTime.now().toIso8601String() // Ghi lại thời gian thanh toán
    }, where: 'id = ?', whereArgs: [billId]);
  }

  static Future<List<Map<String, dynamic>>> getBills(int userId) async {
    final db = await getDB();
    return await db.rawQuery('''
      SELECT b.*, t.name as tableName 
      FROM bills b 
      LEFT JOIN tables t ON b.tableId = t.id 
      WHERE b.userId = ? AND b.status = 'Paid' 
      ORDER BY b.paidAt DESC
    ''', [userId]);
  }

  static Future<double> getRevenue(int userId) async {
    final db = await getDB();
    var res = await db.rawQuery("SELECT SUM(totalAmount) as total FROM bills WHERE userId = ? AND status = 'Paid'", [userId]);
    return (res.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Tổng số hóa đơn đã thanh toán của người dùng
  static Future<int> getTotalBillsCount(int userId) async {
    final db = await getDB();
    var res = await db.rawQuery("SELECT COUNT(*) as cnt FROM bills WHERE userId = ? AND status = 'Paid'", [userId]);
    // rawQuery returns numbers sometimes as int or num depending on platform
    var cnt = res.first['cnt'];
    if (cnt is int) return cnt;
    if (cnt is num) return cnt.toInt();
    return 0;
  }

  // Lấy số đơn theo từng ngày trong khoảng `days` ngày gần nhất (bao gồm hôm nay)
  // Trả về danh sách map: { 'day': 'YYYY-MM-DD', 'count': N }
  static Future<List<Map<String, dynamic>>> getOrdersPerDay(int userId, {int days = 7}) async {
    final db = await getDB();
    // Tính ngày bắt đầu (00:00 của ngày bắt đầu) từ Dart và so sánh với trường paidAt (ISO string)
    DateTime start = DateTime.now().subtract(Duration(days: days - 1));
    DateTime startDay = DateTime(start.year, start.month, start.day);
    String startIso = startDay.toIso8601String();

    var res = await db.rawQuery('''
      SELECT DATE(paidAt) as day, COUNT(*) as count
      FROM bills
      WHERE userId = ? AND status = 'Paid' AND paidAt >= ?
      GROUP BY DATE(paidAt)
      ORDER BY DATE(paidAt) ASC
    ''', [userId, startIso]);

    // Ensure we return a continuous list for each day in the range (fill 0 where không có đơn)
    List<Map<String, dynamic>> filled = [];
    for (int i = 0; i < days; i++) {
      DateTime d = DateTime.now().subtract(Duration(days: days - 1 - i));
      String key = "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      var match = res.firstWhere((r) => (r['day'] as String) == key, orElse: () => {});
      if (match.isEmpty) {
        filled.add({'day': key, 'count': 0});
      } else {
        var cnt = match['count'];
        if (cnt is int) {
          filled.add({'day': match['day'], 'count': cnt});
        } else if (cnt is num) {
          filled.add({'day': match['day'], 'count': cnt.toInt()});
        } else {
          filled.add({'day': match['day'], 'count': 0});
        }
      }
    }

    return filled;
  }

  static Future<List<Map<String, dynamic>>> getOrdersForThisWeek(int userId) async {
    final db = await getDB();
    DateTime now = DateTime.now();
    // Monday is start of week
    DateTime startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    String startIso = "${startOfWeek.year}-${startOfWeek.month.toString().padLeft(2, '0')}-${startOfWeek.day.toString().padLeft(2, '0')} 00:00:00";

    var res = await db.rawQuery('''
      SELECT DATE(paidAt) as day, COUNT(*) as count 
      FROM bills 
      WHERE userId = ? AND status = 'Paid' AND paidAt >= ? 
      GROUP BY DATE(paidAt)
    ''', [userId, startIso]);

    List<Map<String, dynamic>> filled = [];
    for (int i = 0; i < 7; i++) {
      DateTime d = startOfWeek.add(Duration(days: i));
      String key = "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
      var match = res.firstWhere((r) => r['day'] == key, orElse: () => {});
      filled.add({
        'day': key,
        'count': match.isEmpty ? 0 : (match['count'] as num).toInt(),
      });
    }
    return filled;
  }
}