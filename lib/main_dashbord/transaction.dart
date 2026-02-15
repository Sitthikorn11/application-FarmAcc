import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:application_farmacc/services/supabase_service.dart';

// Model สำหรับแสดงผล
class TransactionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? tag;
  final String amount;
  final double rawAmount; // เก็บค่าตัวเลขดิบไว้คำนวณกราฟ
  final bool isIncome;
  final String dateGroup;
  final DateTime date;

  TransactionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.tag,
    required this.amount,
    required this.rawAmount,
    required this.isIncome,
    required this.dateGroup,
    required this.date,
  });
}

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  final _service = SupabaseService();
  
  // สถานะการกรอง (all, income, expense)
  String _filterStatus = 'all';
  bool _isLoading = true;

  // รายการข้อมูลที่ดึงมาจาก Supabase
  List<TransactionData> _allTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // ✅ ฟังก์ชันดึงและแปลงข้อมูลจาก Supabase
  Future<void> _fetchData() async {
    try {
      // ดึงข้อมูลทั้งหมด
      final data = await _service.getTransactions();
      
      List<TransactionData> loadedData = data.map((item) {
        final bool isIncome = item['type'] == 'income';
        // แปลงค่าตัวเลขให้ปลอดภัย (รองรับทั้ง int และ double)
        final double amount = (item['amount'] as num).toDouble();
        final String category = item['category'] ?? 'ทั่วไป';
        final String desc = item['description'] ?? '';
        final DateTime date = DateTime.parse(item['transaction_date']);
        
        return TransactionData(
          icon: _getIconByCategory(category), 
          title: category,
          subtitle: desc.isNotEmpty ? '$desc • ${DateFormat('HH:mm').format(date)} น.' : DateFormat('HH:mm น.').format(date),
          tag: isIncome ? 'รายรับ' : null,
          amount: '${isIncome ? '+' : '-'}฿${NumberFormat('#,###').format(amount)}',
          rawAmount: amount,
          isIncome: isIncome,
          dateGroup: _getDateGroup(date), 
          date: date,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _allTransactions = loadedData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print('Error fetching transactions: $e');
    }
  }

  // Helper: เลือกไอคอนตามหมวดหมู่
  IconData _getIconByCategory(String category) {
    if (category.contains('ข้าว')) return Icons.grass;
    if (category.contains('ปุ๋ย')) return Icons.compost;
    if (category.contains('น้ำมัน')) return Icons.local_gas_station;
    if (category.contains('แรงงาน')) return Icons.engineering;
    if (category.contains('ผลไม้') || category.contains('ทุเรียน')) return Icons.eco;
    return Icons.paid; // Default icon
  }

  // Helper: จัดกลุ่มวันที่
  String _getDateGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return 'วันนี้, ${DateFormat('d MMM', 'th').format(date)}';
    if (checkDate == yesterday) return 'เมื่อวาน, ${DateFormat('d MMM', 'th').format(date)}';
    return DateFormat('d MMM yyyy', 'th').format(date);
  }

  // Helper: คำนวณยอดรวม
  Map<String, double> _calculateStats() {
    double income = 0;
    double expense = 0;
    for (var t in _allTransactions) {
      if (t.isIncome) income += t.rawAmount;
      else expense += t.rawAmount;
    }
    return {'income': income, 'expense': expense, 'net': income - expense};
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    const Color primaryColor = Color(0xFF13ec13);
    const Color roseColor = Color(0xFFF43F5E);
    final Color backgroundLight = const Color(0xFFf6f8f6);
    final Color backgroundDark = const Color(0xFF102210);
    final Color surfaceLight = Colors.white;
    final Color surfaceDark = const Color(0xFF1c301c);

    final Color textMain = isDark ? Colors.white : const Color(0xFF111811);
    final Color textSecondary = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    // กรองข้อมูลตามสถานะที่เลือก
    List<TransactionData> displayList = _allTransactions.where((item) {
      if (_filterStatus == 'income') return item.isIncome;
      if (_filterStatus == 'expense') return !item.isIncome;
      return true;
    }).toList();

    // จัดกลุ่มข้อมูลตาม dateGroup เพื่อแสดง Header
    List<String> groups = displayList.map((e) => e.dateGroup).toSet().toList();

    return Scaffold(
      backgroundColor: isDark ? backgroundDark : backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark ? surfaceDark : surfaceLight,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'รายการทั้งหมด',
          style: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: textMain),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchData(); 
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05), height: 1.0),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryColor))
        : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ส่วนแสดงสถิติ
              Builder(
                builder: (context) {
                  final stats = _calculateStats();
                  return _buildStatsOverview(
                    isDark, surfaceLight, surfaceDark, primaryColor, roseColor, textMain, textSecondary,
                    stats['net']!, stats['income']!, stats['expense']!
                  );
                }
              ),
              
              // ส่วน Filter Chips
              _buildFilterChips(isDark, surfaceLight, surfaceDark, primaryColor, textMain),

              // ส่วนแสดงรายการข้อมูล
              if (displayList.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Center(child: Text('ไม่มีรายการ', style: TextStyle(color: textSecondary))),
                ),

              // Loop แสดงผลตามกลุ่มวันที่
              ...groups.map((group) {
                final itemsInGroup = displayList.where((i) => i.dateGroup == group).toList();
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(group, textSecondary),
                    ...itemsInGroup.map((item) => _buildTransactionItem(
                      icon: item.icon,
                      title: item.title,
                      subtitle: item.subtitle,
                      tag: item.tag,
                      amount: item.amount,
                      isIncome: item.isIncome,
                      isDark: isDark,
                      primaryColor: const Color.fromARGB(255, 42, 157, 42),
                    )),
                  ],
                );
              }),

              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Text('สิ้นสุดรายการ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
    );
  }

  // --- Widgets ย่อย ---

  Widget _buildFilterChips(bool isDark, Color light, Color dark, Color primary, Color textMain) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildSelectableChip('ทั้งหมด', 'all', isDark, primary),
          const SizedBox(width: 8),
          _buildSelectableChip('รายรับ', 'income', isDark, primary),
          const SizedBox(width: 8),
          _buildSelectableChip('รายจ่าย', 'expense', isDark, Colors.red),
        ],
      ),
    );
  }

  Widget _buildSelectableChip(String label, String value, bool isDark, Color activeColor) {
    bool isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : (isDark ? const Color(0xFF1c301c) : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.transparent : (isDark ? Colors.white10 : Colors.grey[300]!)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? (isDark ? Colors.black : Colors.white) : (isDark ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(
    bool isDark, Color light, Color dark, Color primary, Color rose, Color text, Color secText,
    double netProfit, double income, double expense
  ) {
    double total = income + expense;
    int incomeFlex = total == 0 ? 5 : ((income / total) * 10).round();
    int expenseFlex = total == 0 ? 5 : 10 - incomeFlex;
    if (incomeFlex == 0 && expense > 0) { incomeFlex = 1; expenseFlex = 9; }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? dark : light,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('กำไรสุทธิ (ทั้งหมด)', style: TextStyle(color: secText, fontSize: 14, fontWeight: FontWeight.w500)),
                    Icon(Icons.trending_up, color: netProfit >= 0 ? primary : rose, size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${netProfit >= 0 ? '+' : ''}฿${NumberFormat('#,###').format(netProfit)}', 
                  style: TextStyle(color: text, fontSize: 32, fontWeight: FontWeight.w900)
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: Row(
                    children: [
                      Expanded(flex: incomeFlex, child: Container(height: 10, color: primary)),
                      Expanded(flex: expenseFlex, child: Container(height: 10, color: rose)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIndicator('รายรับ ${total == 0 ? 0 : ((income/total)*100).round()}%', primary, secText),
                    _buildIndicator('รายจ่าย ${total == 0 ? 0 : ((expense/total)*100).round()}%', rose, secText),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniStatCard('รายรับ', '฿${NumberFormat('#,###').format(income)}', Icons.arrow_downward, primary, isDark, light, dark),
              const SizedBox(width: 12),
              _buildMiniStatCard('รายจ่าย', '฿${NumberFormat('#,###').format(expense)}', Icons.arrow_upward, rose, isDark, light, dark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(String label, Color color, Color textCol) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: textCol, fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMiniStatCard(String label, String val, IconData icon, Color color, bool isDark, Color light, Color dark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? dark : light,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
            const SizedBox(height: 4),
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(title.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
    );
  }

  Widget _buildTransactionItem({required IconData icon, required String title, required String subtitle, String? tag, required String amount, required bool isIncome, required bool isDark, required Color primaryColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1c301c) : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.02))),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: isIncome ? primaryColor.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: isIncome ? primaryColor : Colors.red, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (tag != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(tag, style: TextStyle(color: isDark ? primaryColor : Colors.green[800], fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          Text(amount, style: TextStyle(color: isIncome ? primaryColor : Colors.red, fontWeight: FontWeight.w900, fontSize: 16)),
        ],
      ),
    );
  }
}