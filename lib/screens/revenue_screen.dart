import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
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
  double q1 = 0, q2 = 0, q3 = 0, q4 = 0;

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
    var stats = await CafeDBHelper.getOrdersForThisWeek(widget.userId);
    if (mounted) {
      double _q1 = 0, _q2 = 0, _q3 = 0, _q4 = 0;
      for (var b in data) {
        if (b['paidAt'] != null) {
          DateTime dt = DateTime.parse(b['paidAt']);
          double amt = (b['totalAmount'] as num).toDouble();
          if (dt.month <= 3) _q1 += amt;
          else if (dt.month <= 6) _q2 += amt;
          else if (dt.month <= 9) _q3 += amt;
          else _q4 += amt;
        }
      }

      setState(() {
        bills = data;
        totalRevenue = rev;
        ordersPerDay = stats;
        q1 = _q1; q2 = _q2; q3 = _q3; q4 = _q4;
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black.withAlpha(12), borderRadius: BorderRadius.circular(10))),
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
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black.withAlpha(12), borderRadius: BorderRadius.circular(10))),
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
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.mode == 'bills' ? "LỊCH SỬ" : "THỐNG KÊ", style: AppStyle.heading.copyWith(fontSize: 28)),
            Text(widget.mode == 'bills' ? "Danh sách hóa đơn đã xuất" : "Tổng quan tình hình kinh doanh", style: AppStyle.subHeading),
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
      padding: const EdgeInsets.all(24),
      itemCount: bills.length,
      itemBuilder: (context, i) {
        var b = bills[i];
        return GestureDetector(
          onTap: () => _showBillDetail(b),
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(20),
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.textPrimary, width: 2),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${b['tableName'] ?? 'Unknown'}".toUpperCase(), 
                        style: AppStyle.heading.copyWith(fontSize: 18)
                      ),
                      const SizedBox(height: 2),
                      Text(_formatDateTime(b['createdAt']), style: AppStyle.body.copyWith(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${NumberFormat("#,###").format(b['totalAmount'])}đ", 
                      style: AppStyle.heading.copyWith(color: AppColors.primary, fontSize: 18)
                    ),
                    Text(
                      "VIEW INFO", 
                      style: AppStyle.body.copyWith(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)
                    ),
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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.textPrimary, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.textPrimary,
                  offset: Offset(8, 8),
                  blurRadius: 0,
                )
              ],
            ),
            child: Column(
              children: [
                Text(
                  "TỔNG DOANH THU", 
                  style: GoogleFonts.outfit(color: Colors.white.withAlpha(200), fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)
                ),
                const SizedBox(height: 12),
                Text(
                  "${NumberFormat("#,###").format(totalRevenue)} đ", 
                  style: AppStyle.heading.copyWith(color: Colors.white, fontSize: 36)
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          _buildStatCard(Icons.article_rounded, "Tổng hóa đơn", "${bills.length}", AppColors.secondary),
          
          const SizedBox(height: 32),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("THỐNG KÊ", style: AppStyle.heading.copyWith(fontSize: 20)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.textPrimary, width: 2),
                ),
                child: Text("HÀNG TUẦN", style: AppStyle.body.copyWith(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppStyle.cardDecoration.copyWith(
              boxShadow: const [
                BoxShadow(
                  color: AppColors.textPrimary,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  child: ordersPerDay.isEmpty 
                    ? const Center(child: Text("No data available"))
                    : _buildBarChart(ordersPerDay),
                ),
                const SizedBox(height: 12),
                Text(
                  "Tổng số đơn trong 7 ngày gần nhất", 
                  style: AppStyle.body.copyWith(color: AppColors.textSecondary, fontSize: 12)
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          Text("DOANH THU THEO QUÝ", style: AppStyle.heading.copyWith(fontSize: 20)),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _buildQuarterCard("Quý 1", q1, AppColors.primary),
              _buildQuarterCard("Quý 2", q2, AppColors.secondary),
              _buildQuarterCard("Quý 3", q3, AppColors.accent),
              _buildQuarterCard("Quý 4", q4, AppColors.primary),
            ],
          ),
          
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildQuarterCard(String label, double amount, Color color) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label.toUpperCase(), style: AppStyle.body.copyWith(fontWeight: FontWeight.w900, fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "${NumberFormat("#,###").format(amount)}đ", 
              style: AppStyle.heading.copyWith(fontSize: 18, color: AppColors.textPrimary)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return GestureDetector(
      onTap: () {
        if (label == 'Total Bills') _showTotalBillsModal();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color, 
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.textPrimary, width: 2),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 20),
            Text(label.toUpperCase(), style: AppStyle.body.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontSize: 13, letterSpacing: 1)),
            const Spacer(),
            Text(value, style: AppStyle.heading.copyWith(fontSize: 18, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  // Build a simple column chart (BarChart) for daily orders using fl_chart
  Widget _buildBarChart(List<Map<String, dynamic>> perDay) {
    // Simple custom bar chart using basic widgets (no external package) so it works on all Flutter SDK versions.
    final counts = perDay.map((e) => (e['count'] as int)).toList();
    final List<String> vnDays = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
    final labels = List.generate(7, (i) => vnDays[i]);

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
                      Text(
                        "$count", 
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)
                      ),
                      const SizedBox(height: 2),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: heightFactor.clamp(0.0, 1.0),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary, 
                                borderRadius: BorderRadius.circular(4)
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900)),
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