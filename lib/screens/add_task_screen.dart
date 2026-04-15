import 'package:flutter/material.dart';
import '../database/task_helper.dart'; // Sử dụng CafeHelper

class AddTaskScreen extends StatefulWidget {
  final int userId;
  final int? parentId;

  AddTaskScreen({required this.userId, this.parentId});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String note = '';
  String price = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parentId == null ? "Thêm món mới" : "Thêm tùy chọn"),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Tên món / Dịch vụ',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.restaurant_menu),
                ),
                onChanged: (v) => name = v,
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Giá (VNĐ)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) => price = v,
                validator: (v) => v!.isEmpty ? 'Vui lòng nhập giá' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Ghi chú (Ví dụ: ít đường, không đá)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
                onChanged: (v) => note = v,
              ),
              Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  minimumSize: Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await CafeHelper.insertItem({
                      'name': name,
                      'note': note,
                      'parentId': widget.parentId,
                      'price': price,
                      'userId': widget.userId,
                      'status': 'Pending',
                    });
                    Navigator.pop(context, true);
                  }
                },
                child: Text("THÊM VÀO THỰC ĐƠN", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}