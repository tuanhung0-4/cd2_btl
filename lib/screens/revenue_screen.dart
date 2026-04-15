import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../database/cafe_db_helper.dart';
import 'package:intl/intl.dart';
import '../utils/app_style.dart';

class RevenueScreen extends StatefulWidget {
  final int userId;
  final String mode; // 'bills' or 'revenue'

  RevenueScreen({required this.userId, required this.mode});

  @override
  _RevenueScreenState createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  List<Map<String, dynamic>> bills = [];
  double totalRevenue = 0.0;
  List<Map<String, dynamic>> ordersPerDay = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Luôn load lại dữ liệu mỗi khi màn hình được build để cập nhật hóa đơn mới
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  _load() async {
    // Always load bills (we may need count even in revenue view)
    var data = await CafeDBHelper.getBills(widget.userId);
    var rev = await CafeDBHelper.getRevenue(widget.userId);
    if (mounted) {
      setState(() {
        bills = data;
        totalRevenue = rev;
      });
    }
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null) return "N/A";
    DateTime dt = DateTime.parse(isoString);
    return DateFormat('HH:mm - dd/MM/yyyy').format(dt);
  }

  void _showBillDetail(Map<String, dynamic> bill) async {
    var items = await CafeDBHelper.getBillItems(bill['id']);
    
    showCupertinoModalPopup(
      context: context,
      useRootNavigator: true,
      builder: (context) => Material(
        color: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text("CHI TIẾT HÓA ĐƠN", style: AppStyle.heading),
            const SizedBox(height: 15),
            
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  _buildDetailRow("Bàn:", bill['tableName'] ?? "N/A"),
                  const SizedBox(height: 8),
                  _buildDetailRow("Thời gian:", _formatDateTime(bill['createdAt'])),
                  const SizedBox(height: 8),
                  _buildDetailRow("Mã HĐ:", "#${bill['id']}"),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            Align(alignment: Alignment.centerLeft, child: Text("DANH SÁCH MÓN", style: AppStyle.subHeading)),
            const Divider(height: 20),
            
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${items[i]['name']} x${items[i]['quantity']}", style: const TextStyle(fontSize: 14)),
                      Text("${NumberFormat("#,###").format(items[i]['price'] * items[i]['quantity'])}đ", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            
            const Divider(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TỔNG CỘNG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("${NumberFormat("#,###").format(bill['totalAmount'])}đ", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("ĐÓNG", style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ],
        ),
      ),
      ),
    );
  }

  // Show modal with total bills and a short column chart of orders per day
  void _showTotalBillsModal() async {
    // Load aggregated data
    int totalCount = await CafeDBHelper.getTotalBillsCount(widget.userId);
    var perDay = await CafeDBHelper.getOrdersPerDay(widget.userId, days: 7);

    if (!mounted) return;

    showCupertinoModalPopup(
      context: context,
      useRootNavigator: true,
      builder: (context) => Material(
        color: Colors.transparent,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 16),
            Text("TỔNG HÓA ĐƠN", style: AppStyle.heading),
            const SizedBox(height: 8),
            Text("$totalCount hóa đơn", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Align(alignment: Alignment.centerLeft, child: Text("Số đơn theo ngày (7 ngày gần nhất)", style: AppStyle.subHeading)),
            const SizedBox(height: 12),
            Expanded(
              child: perDay.isEmpty
                  ? const Center(child: Text("Không có dữ liệu"))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: _buildBarChart(perDay),
                    ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => Navigator.pop(context),
                child: const Text("ĐÓNG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.mode == 'bills' ? "LỊCH SỬ HÓA ĐƠN" : "THỐNG KÊ DOANH THU", style: AppStyle.heading),
            Text(widget.mode == 'bills' ? "Danh sách các giao dịch đã thực hiện" : "Tổng quan tình hình kinh doanh", style: AppStyle.subHeading),
          ],
        ),
      ),
      body: SafeArea(
        child: widget.mode == 'bills' ? _buildBillsList() : _buildRevenueView(),
      ),
    );
  }

  Widget _buildBillsList() {
    if (bills.isEmpty) return const Center(child: Text("Chưa có hóa đơn nào.", style: TextStyle(color: AppColors.textSecondary)));
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: bills.length,
      itemBuilder: (context, i) {
        var b = bills[i];
        return GestureDetector(
          onTap: () => _showBillDetail(b),
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(18),
            decoration: AppStyle.cardDecoration,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                  child: const Icon(CupertinoIcons.doc_text_fill, color: AppColors.primary),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${b['tableName'] ?? 'Bàn đã xóa'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(_formatDateTime(b['createdAt']), style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("${NumberFormat("#,###").format(b['totalAmount'])}đ", 
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 17)),
                    const Text("Xem chi tiết", style: TextStyle(color: AppColors.primary, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevenueView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(35),
            decoration: AppStyle.cardDecoration.copyWith(
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              children: [
                const Text("TỔNG DOANH THU", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                const SizedBox(height: 12),
                Text("${NumberFormat("#,###").format(totalRevenue)} VNĐ", 
                  style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildStatCard(CupertinoIcons.doc_plaintext, "Tổng hóa đơn", "${bills.length}", AppColors.secondary),
          const SizedBox(height: 15),
          _buildStatCard(CupertinoIcons.calendar, "Ngày hôm nay", DateFormat('dd/MM/yyyy').format(DateTime.now()), AppColors.accent),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return GestureDetector(
      onTap: () {
        if (label == 'Tổng hóa đơn') _showTotalBillsModal();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppStyle.cardDecoration,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 15),
            Text(label, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          ],
        ),
      ),
    );
  }

  // Build a simple column chart (BarChart) for daily orders using fl_chart
  Widget _buildBarChart(List<Map<String, dynamic>> perDay) {
    // Simple custom bar chart using basic widgets (no external package) so it works on all Flutter SDK versions.
    final counts = perDay.map((e) => (e['count'] as int)).toList();
    final labels = perDay.map((e) {
      var parts = (e['day'] as String).split('-');
      if (parts.length == 3) return '${parts[2]}/${parts[1]}';
      return e['day'];
    }).toList();

    int maxCount = counts.isEmpty ? 1 : counts.reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          // chart area
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(counts.length, (i) {
                final count = counts[i];
                final label = labels[i];
                final heightFactor = maxCount == 0 ? 0.0 : (count / maxCount);
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: heightFactor.clamp(0.0, 1.0),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(label, style: const TextStyle(fontSize: 10)),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          // legend / counts row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Số đơn', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text('Tối đa: $maxCount', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          )
        ],
      ),
    );
  }
}