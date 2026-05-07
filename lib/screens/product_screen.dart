// Dùng để xử lý file ảnh món ăn
import 'dart:io';
// Widget iOS
import 'package:flutter/cupertino.dart';
// Widget Material
import 'package:flutter/material.dart';
// Chọn ảnh từ gallery
import 'package:image_picker/image_picker.dart';
// Định dạng số tiền
import 'package:intl/intl.dart';
// Truy vấn database
import '../database/cafe_db_helper.dart';
// Style chung toàn app
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
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black.withAlpha(12), borderRadius: BorderRadius.circular(10))),
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
                      border: Border.all(color: AppColors.primary.withAlpha(25)),
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
                      decoration: AppStyle.cardDecoration.copyWith(color: AppColors.background.withAlpha(128)),
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
                          'status': 'Còn hàng',
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

  Future<void> _showEditProductSheet(Map<String, dynamic> product) async {
    String name = product['name'] ?? '';
    String price = (product['price'] ?? '').toString();
    String description = product['description'] ?? '';
    String category = product['category'] ?? categories[0];
    String status = product['status'] ?? 'Còn hàng';
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
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black.withAlpha(12), borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 25),
                  Text("SỬA MÓN", style: AppStyle.heading),
                  const SizedBox(height: 20),
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
                        border: Border.all(color: AppColors.primary.withAlpha(25)),
                      ),
                      child: image == null
                          ? (product['imagePath'] != null && product['imagePath'].isNotEmpty
                              ? ClipRRect(borderRadius: BorderRadius.circular(25), child: Image.file(File(product['imagePath']), fit: BoxFit.cover))
                              : const Icon(CupertinoIcons.camera_fill, color: AppColors.primary, size: 40))
                          : ClipRRect(borderRadius: BorderRadius.circular(25), child: Image.file(File(image!.path), fit: BoxFit.cover)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInput(label: 'TÊN MÓN ĂN', hint: 'Tên món', onChanged: (v) => name = v),
                  const SizedBox(height: 12),
                  _buildInput(label: 'GIÁ TIỀN (VNĐ)', hint: 'Giá', keyboardType: TextInputType.number, onChanged: (v) => price = v),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("DANH MỤC", style: AppStyle.subHeading),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: AppStyle.cardDecoration.copyWith(color: AppColors.background.withAlpha(128)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: category,
                            isExpanded: true,
                            items: categories.map((String value) {
                              return DropdownMenuItem<String>(value: value, child: Text(value));
                            }).toList(),
                            onChanged: (v) => setModalState(() => category = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("TRẠNG THÁI", style: AppStyle.subHeading),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Còn hàng'),
                              value: 'Còn hàng',
                              groupValue: status,
                              onChanged: (v) => setModalState(() => status = v!),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Hết hàng'),
                              value: 'Hết hàng',
                              groupValue: status,
                              onChanged: (v) => setModalState(() => status = v!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInput(label: 'MÔ TẢ', hint: 'Mô tả', maxLines: 2, onChanged: (v) => description = v),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('CẬP NHẬT', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        Map<String, dynamic> data = {
                          'name': name,
                          'price': double.tryParse(price) ?? 0.0,
                          'description': description,
                          'category': category,
                          'status': status,
                        };
                        if (image != null) data['imagePath'] = image!.path;
                        await CafeDBHelper.updateProduct(product['id'], data);
                        Navigator.pop(context);
                        _load();
                      },
                    ),
                  ),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy bỏ', style: TextStyle(color: AppColors.danger))),
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
          decoration: AppStyle.cardDecoration.copyWith(color: AppColors.background.withAlpha(128)),
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
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("THỰC ĐƠN", style: AppStyle.heading.copyWith(fontSize: 28)),
            Text("Quản lý danh mục món ăn và đồ uống", style: AppStyle.subHeading),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: _showAddProductSheet,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.textPrimary, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.textPrimary,
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Chips
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: AppColors.background,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: ['Tất cả', ...categories].map((cat) {
                bool isSelected = selectedCategoryFilter == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => setState(() => selectedCategoryFilter = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.secondary : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.textPrimary, width: 2),
                        boxShadow: isSelected ? null : const [
                          BoxShadow(
                            color: AppColors.textPrimary,
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(cat, style: AppStyle.body.copyWith(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        )),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.flatware_rounded, size: 80, color: AppColors.textPrimary.withAlpha(50)),
                        const SizedBox(height: 16),
                        Text("Chưa có món ăn nào được thêm", style: AppStyle.body.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, i) {
                      final p = filteredProducts[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: AppStyle.cardDecoration.copyWith(
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.textPrimary,
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Image
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.textPrimary, width: 2),
                              ),
                              child: (p['imagePath'] != null && p['imagePath'].toString().isNotEmpty)
                                  ? ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(File(p['imagePath'].toString()), fit: BoxFit.cover))
                                  : const Icon(Icons.fastfood_rounded, color: AppColors.textPrimary, size: 32),
                            ),

                            const SizedBox(width: 20),

                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p['name'].toString().toUpperCase(), style: AppStyle.heading.copyWith(fontSize: 18)),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: AppColors.textPrimary, width: 1),
                                    ),
                                    child: Text(
                                      p['category']?.toString() ?? 'Khác',
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 8, fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Status badge
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: (p['status']?.toString() ?? 'Còn hàng') == 'Còn hàng' ? Colors.green.withAlpha(30) : Colors.red.withAlpha(30),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.textPrimary.withAlpha(30)),
                                        ),
                                        child: Text(
                                          (p['status']?.toString() ?? 'Còn hàng'),
                                          style: TextStyle(
                                            color: (p['status']?.toString() ?? 'Còn hàng') == 'Còn hàng' ? Colors.green[800] : Colors.red[800],
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        "${NumberFormat('#,###').format(p['price'])}đ",
                                        style: AppStyle.heading.copyWith(color: AppColors.primary, fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Actions
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: AppColors.primary, size: 22),
                                  onPressed: () async => await _showEditProductSheet(p),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 24),
                                  onPressed: () async {
                                    await CafeDBHelper.deleteProduct(p['id']);
                                    _load();
                                  },
                                ),
                              ],
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

