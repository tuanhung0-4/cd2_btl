import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../database/cafe_db_helper.dart';
import '../utils/app_style.dart';

class ProductScreen extends StatefulWidget {
  final int userId;
  ProductScreen({required this.userId});
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Map<String, dynamic>> products = [];
  final ImagePicker _picker = ImagePicker();
  String selectedCategoryFilter = 'Tất cả';

  final List<String> categories = [
    'Cafe',
    'Đồ uống nóng',
    'Đồ uống lạnh',
    'Đồ ăn vặt',
    'Khác'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    var data = await CafeDBHelper.getProducts(widget.userId);
    setState(() => products = data);
  }

  Future<void> _showAddProductSheet() async {
    String name = '';
    String price = '';
    String description = '';
    String category = categories[0];
    XFile? image;

    await showCupertinoModalPopup(
      context: context,
      useRootNavigator: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Material(
          color: Colors.transparent,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(10))),
                const SizedBox(height: 25),
                Text("THÊM MÓN MỚI", style: AppStyle.heading),
                const SizedBox(height: 30),
                
                GestureDetector(
                  onTap: () async {
                    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) setModalState(() => image = pickedFile);
                  },
                  child: Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                    ),
                    child: image == null
                        ? const Icon(CupertinoIcons.camera_fill, color: AppColors.primary, size: 40)
                        : ClipRRect(borderRadius: BorderRadius.circular(25), child: Image.file(File(image!.path), fit: BoxFit.cover)),
                  ),
                ),
                const SizedBox(height: 30),

                _buildInput(label: "TÊN MÓN ĂN", hint: "Ví dụ: Cafe Muối", onChanged: (v) => name = v),
                const SizedBox(height: 20),
                _buildInput(label: "GIÁ TIỀN (VNĐ)", hint: "Ví dụ: 35000", keyboardType: TextInputType.number, onChanged: (v) => price = v),
                const SizedBox(height: 20),
                
                // Category Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("DANH MỤC", style: AppStyle.subHeading),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: AppStyle.cardDecoration.copyWith(color: AppColors.background.withOpacity(0.5)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: category,
                          isExpanded: true,
                          items: categories.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (v) => setModalState(() => category = v!),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                _buildInput(label: "MÔ TẢ CHI TIẾT", hint: "Ghi chú về món ăn...", maxLines: 2, onChanged: (v) => description = v),
                
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("LƯU VÀO THỰC ĐƠN", style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      if (name.isNotEmpty && price.isNotEmpty) {
                        await CafeDBHelper.addProduct({
                          'name': name,
                          'price': double.parse(price),
                          'description': description,
                          'imagePath': image?.path ?? '',
                          'category': category,
                          'userId': widget.userId
                        });
                        Navigator.pop(context);
                        _load();
                      }
                    },
                  ),
                ),
                TextButton(
                  child: const Text("Hủy bỏ", style: TextStyle(color: AppColors.danger)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildInput({required String label, required String hint, TextInputType? keyboardType, int maxLines = 1, required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyle.subHeading),
        const SizedBox(height: 10),
        Container(
          decoration: AppStyle.cardDecoration.copyWith(color: AppColors.background.withOpacity(0.5)),
          child: CupertinoTextField(
            placeholder: hint,
            placeholderStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            padding: const EdgeInsets.all(15),
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredProducts = selectedCategoryFilter.trim().toLowerCase() == 'tất cả'
        ? products
        : products.where((p) {
            var cat = (p['category'] ?? 'Khác').toString().trim().toLowerCase();
            return cat == selectedCategoryFilter.trim().toLowerCase();
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("THỰC ĐƠN", style: AppStyle.heading),
            Text("Quản lý danh mục món ăn", style: AppStyle.subHeading),
          ],
        ),
        actions: [
          // Replace CupertinoButton with a tappable Container to keep the '+' centered
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: _showAddProductSheet,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.add, color: AppColors.secondary, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: ['Tất cả', ...categories].map((cat) {
                bool isSelected = selectedCategoryFilter == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(cat, style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold
                    )),
                    selected: isSelected,
                    selectedColor: AppColors.secondary,
                    backgroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (bool selected) {
                      setState(() => selectedCategoryFilter = cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(child: Text("Không tìm thấy món ăn nào", style: TextStyle(color: AppColors.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, i) {
                      var p = filteredProducts[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(12),
                        decoration: AppStyle.cardDecoration,
                        child: Row(
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: p['imagePath'] != null && p['imagePath'].isNotEmpty
                                  ? ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.file(File(p['imagePath']), fit: BoxFit.cover))
                                  : const Icon(Icons.fastfood_rounded, color: AppColors.secondary, size: 30),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p['name'], style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(p['category'] ?? "Khác", style: TextStyle(color: AppColors.secondary.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(p['description'] ?? "Không có mô tả", maxLines: 1, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  const SizedBox(height: 6),
                                  Text("${NumberFormat("#,###").format(p['price'])}đ", style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w900, fontSize: 16)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(CupertinoIcons.delete, color: AppColors.danger, size: 20),
                              onPressed: () async {
                                await CafeDBHelper.deleteProduct(p['id']);
                                _load();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}