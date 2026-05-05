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
  List<Map<String, dynamic>> filteredBills = [];
  DateTime? selectedDate;
  double dailyRevenue = 0.0;
  double weeklyRevenue = 0.0;
  double monthlyRevenue = 0.0;
  int billsToday = 0;
  int billsThisWeek = 0;
  int billsThisMonth = 0;
  int itemsToday = 0;
  int itemsThisWeek = 0;
  int itemsThisMonth = 0;
  List<Map<String, dynamic>> topSellingItems = [];

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
    var data = await CafeDBHelper.getBills(widget.userId);
    var dRev = await CafeDBHelper.getDailyRevenue(widget.userId);
    var wRev = await CafeDBHelper.getWeeklyRevenue(widget.userId);
    var mRev = await CafeDBHelper.getMonthlyRevenue(widget.userId);
    
    // Đơn hàng
    var bToday = data.where((b) {
      DateTime dt = DateTime.parse(b['paidAt']);
      DateTime now = DateTime.now();
      return dt.year == now.year && dt.month == now.month && dt.day == now.day;
    }).length;
    
    // Tuần
    DateTime now = DateTime.now();
    DateTime startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    var bWeek = data.where((b) => DateTime.parse(b['paidAt']).isAfter(startOfWeek)).length;
    
    // Tháng
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    var bMonth = data.where((b) => DateTime.parse(b['paidAt']).isAfter(startOfMonth)).length;

    var iToday = await CafeDBHelper.getDailyItemsSold(widget.userId); // Cần thêm vào DBHelper hoặc tính từ bills items
    var iWeek = await CafeDBHelper.getWeeklyItemsSold(widget.userId); // Dummy cho demo hoặc load thực tế
    var iMonth = await CafeDBHelper.getMonthlyItemsSold(widget.userId);
    
    var topItems = await CafeDBHelper.getTopSellingItems(widget.userId);
    
    if (mounted) {
      setState(() {
        bills = data;
        filteredBills = data;
        dailyRevenue = dRev;
        weeklyRevenue = wRev;
        monthlyRevenue = mRev;
        billsToday = bToday;
        billsThisWeek = bWeek;
        billsThisMonth = bMonth;
        itemsToday = iToday;
        itemsThisWeek = iWeek;
        itemsThisMonth = iMonth;
        topSellingItems = topItems;
      });
    }
  }

  void _filterBillsByDate(DateTime? date) {
    setState(() {
      selectedDate = date;
      if (date == null) {
        filteredBills = bills;
      } else {
        filteredBills = bills.where((b) {
          if (b['paidAt'] == null) return false;
          DateTime dt = DateTime.parse(b['paidAt']);
          return dt.year == date.year && dt.month == date.month && dt.day == date.day;
        }).toList();
      }
    });
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedDate == null ? "Tất cả giao dịch" : "Ngày: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Row(
                children: [
                  if (selectedDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () => _filterBillsByDate(null),
                    ),
                  IconButton(
                    icon: const Icon(Icons.calendar_month, color: AppColors.primary),
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) _filterBillsByDate(picked);
                    },
                  ),
                ],
              )
            ],
          ),
        ),
        Expanded(
          child: filteredBills.isEmpty 
            ? const Center(child: Text("Không có hóa đơn nào.", style: TextStyle(color: AppColors.textSecondary)))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: filteredBills.length,
                itemBuilder: (context, i) {
                  var b = filteredBills[i];
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
                                "CHI TIẾT", 
                                style: AppStyle.body.copyWith(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildRevenueView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.textPrimary, width: 3),
              boxShadow: const [BoxShadow(color: AppColors.textPrimary, offset: Offset(6, 6), blurRadius: 0)],
            ),
            child: Column(
              children: [
                Text("DOANH THU THÁNG NÀY", style: GoogleFonts.outfit(color: Colors.white.withAlpha(180), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text("${NumberFormat("#,###").format(monthlyRevenue)} đ", style: AppStyle.heading.copyWith(color: Colors.white, fontSize: 32)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text("HÔM NAY", style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 10, fontWeight: FontWeight.bold)),
                          Text("${NumberFormat("#,###").format(dailyRevenue)}đ", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 30, color: Colors.white.withAlpha(50)),
                    Expanded(
                      child: Column(
                        children: [
                          Text("TUẦN NÀY", style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 10, fontWeight: FontWeight.bold)),
                          Text("${NumberFormat("#,###").format(weeklyRevenue)}đ", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Text("THỐNG KÊ ĐƠN HÀNG", style: AppStyle.heading.copyWith(fontSize: 20)),
          const SizedBox(height: 16),
          _buildCountGrid("Hóa đơn", billsToday, billsThisWeek, billsThisMonth, AppColors.secondary),
          
          const SizedBox(height: 24),
          Text("THỐNG KÊ SỐ LƯỢNG", style: AppStyle.heading.copyWith(fontSize: 20)),
          const SizedBox(height: 16),
          _buildCountGrid("Món đã bán", itemsToday, itemsThisWeek, itemsThisMonth, AppColors.accent),
          
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("MÓN BÁN CHẠY", style: AppStyle.heading.copyWith(fontSize: 20)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.textPrimary, width: 2)),
                child: Text("TOP 10", style: AppStyle.body.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTopSellingCard(),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildCountGrid(String label, int today, int week, int month, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyle.cardDecoration.copyWith(
        boxShadow: const [BoxShadow(color: AppColors.textPrimary, offset: Offset(4, 4), blurRadius: 0)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(label == "Hóa đơn" ? Icons.receipt_long : Icons.fastfood, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCountItem("Ngày", today),
              _buildCountItem("Tuần", week),
              _buildCountItem("Tháng", month),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCountItem(String period, int count) {
    return Column(
      children: [
        Text(period, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 4),
        Text("$count", style: AppStyle.heading.copyWith(fontSize: 22, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildTopSellingCard() {
    if (topSellingItems.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: AppStyle.cardDecoration,
        child: const Center(child: Text("Chưa có món nào được bán", style: TextStyle(color: AppColors.textSecondary))),
      );
    }
    
    return Container(
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
        children: List.generate(topSellingItems.length, (index) {
          var item = topSellingItems[index];
          return Container(
            margin: EdgeInsets.only(bottom: index == topSellingItems.length - 1 ? 0 : 16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: index < 3 ? AppColors.primary : AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.textPrimary, width: 2),
                  ),
                  child: Text(
                    "${index + 1}", 
                    style: TextStyle(
                      color: index < 3 ? Colors.white : AppColors.textPrimary, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "${item['name']}", 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                  )
                ),
                Text(
                  "${item['totalQuantity']}", 
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)
                ),
              ],
            ),
          );
        }),
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
            height: 130, // Reduced from 160 to avoid overflow
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