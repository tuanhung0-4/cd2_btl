import 'package:flutter/material.dart';
import '../database/task_helper.dart'; // File này chứa CafeHelper
import 'add_task_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final String username;
  final int? parentId;

  HomeScreen({required this.userId, required this.username, this.parentId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    var data = await CafeHelper.getItems(widget.parentId, widget.userId);
    setState(() => items = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parentId == null ? "Cafe: ${widget.username}" : "Chi tiết món"),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          if (widget.parentId == null)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              },
            )
        ],
      ),
      body: items.isEmpty
          ? Center(child: Text("Chưa có món nào. Bấm + để thêm!"))
          : ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i) {
          var item = items[i];
          bool served = item['status'] == 'Served';

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Icon(
                Icons.local_cafe,
                color: served ? Colors.green : Colors.brown,
              ),
              title: Text(
                item['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                "Giá: ${item['price']}đ\nGhi chú: ${item['note'] ?? ''}",
                style: TextStyle(fontSize: 12),
              ),
              isThreeLine: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                      userId: widget.userId,
                      username: widget.username,
                      parentId: item['id'],
                    ),
                  ),
                ).then((value) => _load());
              },
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await CafeHelper.deleteItem(item['id']);
                  _load();
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddTaskScreen(
              userId: widget.userId,
              parentId: widget.parentId,
            ),
          ),
        ).then((value) {
          if (value == true) _load();
        }),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}