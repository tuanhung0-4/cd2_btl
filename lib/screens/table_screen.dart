import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/cafe_db_helper.dart';
import '../widgets/order_manager_sheet.dart';
import '../utils/app_style.dart';

class TableScreen extends StatefulWidget {
  final int userId;
  TableScreen({required this.userId});
  @override
  _TableScreenState createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  List<Map<String, dynamic>> tables = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _load() async {
    var data = await CafeDBHelper.getTables(widget.userId);
    setState(() => tables = data);
  }

  _addTable() async {
    await CafeDBHelper.addTable({
      'name': 'Bàn ${tables.length + 1}',
      'status': 'Empty',
      'userId': widget.userId,
      'guestCount': 0
    });
    _load();
  }

  String _getDuration(String? openedAt) {
    if (openedAt == null) return "00:00:00";
    DateTime openTime = DateTime.parse(openedAt);
    Duration diff = DateTime.now().difference(openTime);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(diff.inHours)}:${twoDigits(diff.inMinutes.remainder(60))}:${twoDigits(diff.inSeconds.remainder(60))}";
  }

  void _showTableOptions(Map<String, dynamic> table) {
    bool isBusy = table['status'] == 'Busy';

    showCupertinoModalPopup(
      context: context,
      useRootNavigator: true,
      builder: (context) => CupertinoActionSheet(
        title: Text(table['name'], style: AppStyle.subHeading),
        message: Text(isBusy ? "BÀN ĐANG HOẠT ĐỘNG" : "BÀN TRỐNG", style: const TextStyle(fontSize: 10)),
        actions: [
          if (!isBusy)
            CupertinoActionSheetAction(
              child: const Text("Mở bàn (Bật bàn)"),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                _openTableDialog(table);
              },
            ),
          if (isBusy) ...[
            CupertinoActionSheetAction(
              child: const Text("Thêm món / Gọi món", style: TextStyle(color: AppColors.primary)),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                _orderItems(table);
              },
            ),
            CupertinoActionSheetAction(
              child: const Text("Thanh toán bàn", style: TextStyle(color: AppColors.secondary)),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                _payTable(table);
              },
            ),
          ],
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            child: const Text("Xóa bàn"),
            onPressed: () async {
              await CafeDBHelper.deleteTable(table['id']);
              Navigator.of(context, rootNavigator: true).pop();
              _load();
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text("Đóng"),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
      ),
    );
  }

  void _openTableDialog(Map<String, dynamic> table) {
    int guests = 1;
    showCupertinoDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => CupertinoAlertDialog(
          title: Text("Mở ${table['name']}"),
          content: Column(
            children: [
              const SizedBox(height: 15),
              const Text("Số lượng khách:", style: TextStyle(fontSize: 12)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.minus_circle, color: AppColors.primary),
                    onPressed: () => setDialogState(() => guests > 1 ? guests-- : null)
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text("$guests", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.plus_circle, color: AppColors.primary),
                    onPressed: () => setDialogState(() => guests++)
                  ),
                ],
              )
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text("Hủy", style: TextStyle(color: AppColors.danger)), 
              onPressed: () => Navigator.of(context, rootNavigator: true).pop()
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text("Xác nhận", style: TextStyle(color: AppColors.primary)),
              onPressed: () async {
                await CafeDBHelper.updateTableStatus(table['id'], 'Busy', 
                  openedAt: DateTime.now().toIso8601String(), 
                  guestCount: guests);
                await CafeDBHelper.startBill(table['id'], widget.userId);
                Navigator.of(context, rootNavigator: true).pop();
                _load();
                Future.delayed(const Duration(milliseconds: 200), () {
                  _orderItems({...table, 'status': 'Busy', 'guestCount': guests});
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _orderItems(Map<String, dynamic> table) async {
    var bill = await CafeDBHelper.getActiveBill(table['id']);
    if (bill == null) return;
    showCupertinoModalPopup(
      context: context,
      useRootNavigator: true,
      builder: (context) => OrderManagerSheet(
        table: table, 
        bill: bill, 
        userId: widget.userId,
        onUpdate: () => _load(),
      ),
    );
  }

  void _payTable(Map<String, dynamic> table) async {
    var bill = await CafeDBHelper.getActiveBill(table['id']);
    if (bill == null) return;
    var billItems = await CafeDBHelper.getBillItems(bill['id']);
    double total = 0;
    for (var item in billItems) { total += (item['price'] * item['quantity']); }

    showCupertinoDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => CupertinoAlertDialog(
        title: Text("Thanh toán ${table['name']}"),
        content: Column(
          children: [
            const SizedBox(height: 15),
            const Text("TỔNG TIỀN", style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            Text("${NumberFormat("#,###").format(total)}đ", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 10),
            const Text("Xác nhận thanh toán và đóng bàn?", style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          CupertinoDialogAction(child: const Text("Hủy"), onPressed: () => Navigator.of(context, rootNavigator: true).pop()),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("Thanh toán", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
            onPressed: () async {
              await CafeDBHelper.closeBill(bill['id'], total);
              await CafeDBHelper.updateTableStatus(table['id'], 'Empty', openedAt: null, guestCount: 0);
              Navigator.of(context, rootNavigator: true).pop();
              _load();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("DS BÀN", style: AppStyle.heading.copyWith(fontSize: 28)),
            Text("Quản lý phục vụ thời gian thực", style: AppStyle.subHeading),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: _addTable,
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
      body: tables.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.coffee_maker_rounded, size: 80, color: AppColors.textPrimary.withAlpha(50)),
                  const SizedBox(height: 16),
                  Text("Chưa có bàn nào được thiết lập", style: AppStyle.body.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                crossAxisSpacing: 20, 
                mainAxisSpacing: 20, 
                childAspectRatio: 0.85
              ),
              itemCount: tables.length,
              itemBuilder: (context, i) {
                var table = tables[i];
                bool isBusy = table['status'] == 'Busy';
                int itemCount = table['itemCount'] ?? 0;

                return GestureDetector(
                  onTap: () => _showTableOptions(table),
                  child: Container(
                    decoration: AppStyle.cardDecoration.copyWith(
                      color: isBusy ? AppColors.primary : Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.textPrimary,
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        if (isBusy)
                          Positioned(
                            top: 12, right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Text(
                                _getDuration(table['openedAt']), 
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                isBusy ? Icons.person_rounded : Icons.table_restaurant_outlined, 
                                size: 48, 
                                color: isBusy ? Colors.white : AppColors.textPrimary
                              ),
                              const Spacer(),
                              Text(
                                table['name'].toUpperCase(), 
                                style: AppStyle.heading.copyWith(
                                  fontSize: 20, 
                                  color: isBusy ? Colors.white : AppColors.textPrimary
                                )
                              ),
                              const SizedBox(height: 4),
                              if (isBusy) ...[
                                Row(
                                  children: [
                                    _buildSmallInfo(Icons.people_alt_rounded, "${table['guestCount']}", Colors.white),
                                    const SizedBox(width: 8),
                                    _buildSmallInfo(Icons.shopping_bag_rounded, "$itemCount", Colors.white),
                                  ],
                                ),
                              ] else 
                                Text("SẴN SÀNG", style: AppStyle.subHeading.copyWith(fontSize: 10, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSmallInfo(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}