import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/cafe_db_helper.dart';
import '../utils/app_style.dart';

class OrderManagerSheet extends StatefulWidget {
  final Map<String, dynamic> table;
  final Map<String, dynamic> bill;
  final int userId;
  final VoidCallback onUpdate;

  OrderManagerSheet({
    required this.table,
    required this.bill,
    required this.userId,
    required this.onUpdate,
  });

  @override
  _OrderManagerSheetState createState() => _OrderManagerSheetState();
}

class _OrderManagerSheetState extends State<OrderManagerSheet> {
  List<Map<String, dynamic>> billItems = [];
  List<Map<String, dynamic>> allProducts = [];
  Map<int, int> selectedQuantities = {};
  String activeCategory = 'Tất cả';

  final List<String> categories = [
    'Tất cả',
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
    var items = await CafeDBHelper.getBillItems(widget.bill['id']);
    var products = await CafeDBHelper.getProducts(widget.userId);
    setState(() {
      billItems = items;
      allProducts = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter products based on active category
    List<Map<String, dynamic>> filteredProducts = activeCategory.trim().toLowerCase() == 'tất cả'
        ? allProducts
        : allProducts.where((p) {
            var cat = (p['category'] ?? 'Khác').toString().trim().toLowerCase();
            return cat == activeCategory.trim().toLowerCase();
          }).toList();

    return Material(
      color: Colors.transparent,
      child: Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
              Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.black.withAlpha((0.05 * 255).round()), borderRadius: BorderRadius.circular(10)),
                  ),
          const SizedBox(height: 15),
          Text("ĐẶT MÓN: ${widget.table['name']}", style: AppStyle.heading),
          const SizedBox(height: 15),
          
          // Category Selector (Tabs)
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, i) {
                bool isSelected = activeCategory == categories[i];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => activeCategory = categories[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        categories[i],
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 15),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // List "Đã gọi" (Bên trái, nhỏ gọn hơn)
                Container(
                  width: 140,
                  decoration: BoxDecoration(
                    color: AppColors.background.withAlpha((0.5 * 255).round()),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text("ĐÃ GỌI (${billItems.length})", style: AppStyle.subHeading.copyWith(fontSize: 10)),
                      const Divider(),
                      Expanded(
                        child: billItems.isEmpty
                            ? const Center(child: Text("Trống", style: TextStyle(fontSize: 10, color: Colors.grey)))
                            : ListView.builder(
                                itemCount: billItems.length,
                                itemBuilder: (context, i) {
                                  var item = billItems[i];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item['name'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("x${item['quantity']}", style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w900)),
                                            GestureDetector(
                                              onTap: () async {
                                                await CafeDBHelper.removeFromBill(widget.bill['id'], item['productId']);
                                                _load();
                                              },
                                              child: const Icon(CupertinoIcons.minus_circle, size: 16, color: AppColors.danger),
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
                ),
                const SizedBox(width: 10),
                // Menu món theo danh mục (Bên phải)
                Expanded(
                  child: Column(
                    children: [
                      Text("THỰC ĐƠN: $activeCategory", style: AppStyle.subHeading.copyWith(fontSize: 10)),
                      const SizedBox(height: 10),
                      Expanded(
                        child: filteredProducts.isEmpty
                            ? const Center(child: Text("Không có món trong nhóm này", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey)))
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 20),
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, i) {
                                  var product = filteredProducts[i];
                                  int qty = selectedQuantities[product['id']] ?? 1;
                                  
                                   return Container(
                                     margin: const EdgeInsets.only(bottom: 12),
                                     padding: const EdgeInsets.all(8),
                                     decoration: AppStyle.cardDecoration.copyWith(boxShadow: []),
                                     child: Column(
                                       mainAxisSize: MainAxisSize.min,
                                       mainAxisAlignment: MainAxisAlignment.center,
                                       children: [
                                         // Top row: image + name
                                         Row(
                                           children: [
                                             Container(
                                               width: 48,
                                               height: 48,
                                               decoration: BoxDecoration(
                                                 color: AppColors.background,
                                                 borderRadius: BorderRadius.circular(8),
                                               ),
                                               child: product['imagePath'] != null && (product['imagePath'] as String).isNotEmpty
                                                   ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(product['imagePath']), fit: BoxFit.cover))
                                                   : const Icon(Icons.fastfood_rounded, color: AppColors.secondary, size: 22),
                                             ),
                                             const SizedBox(width: 8),
                                             Expanded(
                                               child: Column(
                                                 crossAxisAlignment: CrossAxisAlignment.start,
                                                 children: [
                                                   Text(product['name'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                                   const SizedBox(height: 4),
                                                   Text("${NumberFormat('#,###').format(product['price'])}đ", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                                                 ],
                                               ),
                                             ),
                                           ],
                                         ),
                                         const SizedBox(height: 6),
                                         // Quantity controls + select
                                         Row(
                                           mainAxisAlignment: MainAxisAlignment.center,
                                           children: [
                                             GestureDetector(
                                               onTap: () => setState(() => selectedQuantities[product['id']] = qty > 1 ? qty - 1 : 1),
                                               child: const Icon(CupertinoIcons.minus_circle_fill, size: 22, color: AppColors.textSecondary),
                                             ),
                                             SizedBox(width: 25, child: Text("$qty", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
                                             GestureDetector(
                                               onTap: () => setState(() => selectedQuantities[product['id']] = qty + 1),
                                               child: const Icon(CupertinoIcons.plus_circle_fill, size: 22, color: AppColors.primary),
                                             ),
                                             const SizedBox(width: 10),
                                             ElevatedButton(
                                               style: ElevatedButton.styleFrom(
                                                 backgroundColor: AppColors.primary,
                                                 padding: const EdgeInsets.symmetric(horizontal: 10),
                                                 minimumSize: const Size(50, 30),
                                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                               ),
                                               onPressed: () async {
                                                 await CafeDBHelper.addToBill(widget.bill['id'], product['id'], product['price'], quantity: qty);
                                                 _load();
                                                 setState(() => selectedQuantities[product['id']] = 1);
                                               },
                                               child: const Text("CHỌN", style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                             )
                                           ],
                                         )
                                       ],
                                     ),
                                   );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                Navigator.pop(context);
                widget.onUpdate();
              },
              child: const Text("XÁC NHẬN PHỤC VỤ", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      ),
    );
  }
}