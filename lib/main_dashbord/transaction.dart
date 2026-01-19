import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. สร้าง Model เพื่อช่วยในการกรองข้อมูล
class TransactionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? tag;
  final String amount;
  final bool isIncome;
  final String dateGroup;

  TransactionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.tag,
    required this.amount,
    required this.isIncome,
    required this.dateGroup,
  });
}

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  // 2. ตัวแปรเก็บสถานะการกรอง (all, income, expense)
  String _filterStatus = 'all';

  // 3. รวมรายการข้อมูลทั้งหมดไว้ใน List เดียวเพื่อให้ง่ายต่อการกรอง
  final List<TransactionData> _allTransactions = [
    TransactionData(
      icon: Icons.agriculture,
      title: 'ขายข้าวหอมมะลิ',
      subtitle: '500 กก. • 14:30 น.',
      tag: 'ผลผลิต',
      amount: '+฿8,500',
      isIncome: true,
      dateGroup: 'วันนี้, 12 ต.ค.',
    ),
    TransactionData(
      icon: Icons.compost,
      title: 'ซื้อปุ๋ยเคมี',
      subtitle: 'ร้านลุงแดง • 10:15 น.',
      amount: '-฿1,200',
      isIncome: false,
      dateGroup: 'วันนี้, 12 ต.ค.',
    ),
    TransactionData(
      icon: Icons.eco,
      title: 'ขายผลไม้ (ทุเรียน)',
      subtitle: '200 กก. • 16:45 น.',
      tag: 'ผลผลิต',
      amount: '+฿12,000',
      isIncome: true,
      dateGroup: 'เมื่อวาน, 11 ต.ค.',
    ),
    TransactionData(
      icon: Icons.engineering,
      title: 'ค่าจ้างคนงาน',
      subtitle: '3 คน • 17:00 น.',
      amount: '-฿1,500',
      isIncome: false,
      dateGroup: 'เมื่อวาน, 11 ต.ค.',
    ),
    TransactionData(
      icon: Icons.local_gas_station,
      title: 'ค่าน้ำมันรถไถ',
      subtitle: 'ปั๊ม PT • 08:30 น.',
      amount: '-฿800',
      isIncome: false,
      dateGroup: 'เมื่อวาน, 11 ต.ค.',
    ),
  ];

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

    // 4. ทำการกรองข้อมูลตามสถานะที่เลือก
    List<TransactionData> displayList = _allTransactions.where((item) {
      if (_filterStatus == 'income') return item.isIncome;
      if (_filterStatus == 'expense') return !item.isIncome;
      return true; // ถ้าเป็น 'all' ให้แสดงทั้งหมด
    }).toList();

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
            icon: Icon(Icons.search, color: textMain),
            onPressed: () {},
          ),
        ],
        shape: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsOverview(isDark, surfaceLight, surfaceDark, primaryColor, roseColor, textMain, textSecondary),
            
            // 5. ส่วน Filter Chips (ปรับปรุงให้กดเลือกได้)
            _buildFilterChips(isDark, surfaceLight, surfaceDark, primaryColor, textMain),

            // 6. ส่วนแสดงรายการข้อมูล (Loop ตาม displayList ที่กรองแล้ว)
            if (displayList.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Center(child: Text('ไม่มีรายการ', style: TextStyle(color: textSecondary))),
              ),

            ...displayList.map((item) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(item.dateGroup, textSecondary),
                  _buildTransactionItem(
                    icon: item.icon,
                    title: item.title,
                    subtitle: item.subtitle,
                    tag: item.tag,
                    amount: item.amount,
                    isIncome: item.isIncome,
                    isDark: isDark,
                    primaryColor: const Color.fromARGB(255, 42, 157, 42),
                  ),
                ],
              );
            }).toList(),

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

  // --- Widgets ย่อย (คงเดิมและปรับปรุงฟังก์ชันกด) ---

  Widget _buildFilterChips(bool isDark, Color light, Color dark, Color primary, Color textMain) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildChip(Icons.calendar_month, 'เดือนนี้', isDark, light, dark, isSelected: false, hasDropdown: true),
          const SizedBox(width: 8),
          // ปุ่ม "ทั้งหมด"
          _buildSelectableChip('ทั้งหมด', 'all', isDark, primary),
          const SizedBox(width: 8),
          // ปุ่ม "รายรับ"
          _buildSelectableChip('รายรับ', 'income', isDark, primary),
          const SizedBox(width: 8),
          // ปุ่ม "รายจ่าย"
          _buildSelectableChip('รายจ่าย', 'expense', isDark, Colors.red),
        ],
      ),
    );
  }

  // Widget สำหรับปุ่มที่กดเลือกได้จริง
  Widget _buildSelectableChip(String label, String value, bool isDark, Color activeColor) {
    bool isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = value;
        });
      },
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

  // คง Widget เดิมไว้ตามโครงสร้างที่คุณส่งมา
  Widget _buildChip(IconData? icon, String label, bool isDark, Color light, Color dark, {bool isSelected = false, bool hasDropdown = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? light : (isDark ? dark : light),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isSelected ? Colors.transparent : (isDark ? Colors.white10 : Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, size: 16, color: isDark ? Colors.white : Colors.black), const SizedBox(width: 6)],
          Text(label, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
          if (hasDropdown) ...[const SizedBox(width: 4), const Icon(Icons.expand_more, size: 16, color: Colors.grey)],
        ],
      ),
    );
  }

  // --- ส่วนอื่นๆ คงเนื้อหาเดิมไว้ทั้งหมด ---

  Widget _buildStatsOverview(bool isDark, Color light, Color dark, Color primary, Color rose, Color text, Color secText) {
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
                    Text('กำไรสุทธิ (เดือนนี้)', style: TextStyle(color: secText, fontSize: 14, fontWeight: FontWeight.w500)),
                    Icon(Icons.trending_up, color: primary, size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                Text('+฿15,000', style: TextStyle(color: text, fontSize: 32, fontWeight: FontWeight.w900)),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: Row(
                    children: [
                      Expanded(flex: 7, child: Container(height: 10, color: primary)),
                      Expanded(flex: 3, child: Container(height: 10, color: rose)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIndicator('รายรับ 70%', primary, secText),
                    _buildIndicator('รายจ่าย 30%', rose, secText),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniStatCard('รายรับ', '฿25,000', Icons.arrow_downward, primary, isDark, light, dark),
              const SizedBox(width: 12),
              _buildMiniStatCard('รายจ่าย', '฿10,000', Icons.arrow_upward, rose, isDark, light, dark),
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