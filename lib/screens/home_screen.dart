import 'package:flutter/material.dart';
import '../database/task_helper.dart'; // File này chứa CafeHelper
import 'add_task_screen.dart';
import 'login_screen.dart';
import '../utils/app_style.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.parentId == null ? "CupfulCanvas" : "Item Details",
          style: AppStyle.heading.copyWith(fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primary),
        actions: [
          if (widget.parentId == null)
            IconButton(
              icon: const Icon(Icons.logout, color: AppColors.primary),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            )
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                "No items yet. Tap + to add!",
                style: AppStyle.subHeading,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: items.length,
              itemBuilder: (context, i) {
                var item = items[i];
                bool served = item['status'] == 'Served';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: AppStyle.filledCardDecoration,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: served ? Colors.green.withOpacity(0.1) : AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.coffee_rounded,
                        color: served ? Colors.green : AppColors.primary,
                        size: 32,
                      ),
                    ),
                    title: Text(
                      item['name'],
                      style: AppStyle.body.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.top: 6.0),
                      child: Text(
                        "Price: ${item['price']}đ\nNote: ${item['note'] ?? ''}",
                        style: AppStyle.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
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
                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
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
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
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
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
      ),
    );
  }
}