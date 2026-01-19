import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple/main_dashbord/ProduceEntry.dart'; 
import 'package:simple/editprofile/profile.dart';
import 'package:simple/main_dashbord/transaction.dart';
import 'package:simple/main_dashbord/summaryreport.dart';
import 'package:simple/main_dashbord/inventory.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.kanitTextTheme(), 
      ),
      home: const FarmerDashboard(),
    ),
  );
}

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  int _currentIndex = 0;
  String _selectedPeriod = 'ต.ค.';

  static const Color activeGreen = Color(0xFF39FF14);
  static const Color inactiveGrey = Color(0xFF94A3B8);

  final List<String> _months = [
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
  ];

  // ✅ 1. แก้ไขฟังก์ชันเลือกเดือน (จัดระเบียบปีกกาใหม่)
  void _showPeriodPicker(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C261C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('เลือกเดือน',
                  style: GoogleFonts.prompt(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black)),
              const SizedBox(height: 20),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2,
                  ),
                  itemCount: _months.length,
                  itemBuilder: (context, index) {
                    bool isSelected = _selectedPeriod == _months[index];
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedPeriod = _months[index]);
                        Navigator.pop(context);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF13ec13)
                              : (isDark ? Colors.grey[800] : Colors.grey[200]),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _months[index],
                          style: GoogleFonts.prompt(
                            color: isSelected
                                ? Colors.black
                                : (isDark ? Colors.white : Colors.black),
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // ✅ 2. ฟังก์ชันแสดงหน้าต่างแจ้งเตือน
  void _showNotificationPanel(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF102210) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2))),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('การแจ้งเตือน',
                          style: GoogleFonts.prompt(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black)),
                      TextButton(
                          onPressed: () {},
                          child: const Text('อ่านทั้งหมด',
                              style: TextStyle(color: Color(0xFF13ec13)))),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      _buildNotificationItem(
                        icon: Icons.wb_sunny_outlined,
                        color: Colors.orange,
                        title: 'พยากรณ์อากาศวันนี้',
                        description: 'ท้องฟ้าแจ่มใส เหมาะแก่การฉีดพ่นสารอาหารพืช',
                        time: '10 นาทีที่แล้ว',
                        isDark: isDark,
                      ),
                      _buildNotificationItem(
                        icon: Icons.warning_amber_rounded,
                        color: Colors.red,
                        title: 'แจ้งเตือนพายุฝน',
                        description: 'คาดการณ์ฝนตกหนักในช่วงเย็น โปรดเตรียมการระบายน้ำ',
                        time: '2 ชั่วโมงที่แล้ว',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationItem(
      {required IconData icon,
      required Color color,
      required String title,
      required String description,
      required String time,
      required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 15)),
                const SizedBox(height: 4),
                Text(description,
                    style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        fontSize: 13)),
                const SizedBox(height: 4),
                Text(time,
                    style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      _buildHomeContent(context, isDark),
      const AllTransactionsPage(),
      const InventoryPage(),
      const SummaryReportPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF1C261C) : Colors.white,
        selectedItemColor: activeGreen,
        unselectedItemColor: inactiveGrey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedLabelStyle:
            GoogleFonts.prompt(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.prompt(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded), label: 'ภาพรวม'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded), label: 'รายการ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.agriculture_rounded), label: 'ผลผลิต'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded), label: 'สรุป'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded), label: 'ตั้งค่า'),
        ],
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, bool isDark) {
    const Color primaryColor = Color(0xFF13ec13);
    const Color backgroundLight = Color(0xFFf6f8f6);
    const Color backgroundDark = Color(0xFF102210);
    const Color surfaceLight = Colors.white;
    const Color surfaceDark = Color(0xFF1C261C);
    const Color slate900 = Color(0xFF0f172a);
    const Color slate500 = Color(0xFF64748b);
    const Color slate400 = Color(0xFF94a3b8);

    return Scaffold(
      backgroundColor: isDark ? backgroundDark : backgroundLight,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundImage:
                          NetworkImage('https://via.placeholder.com/150'),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('สวัสดีตอนเช้า',
                            style: TextStyle(color: slate500, fontSize: 14)),
                        Text('คุณสมชาย',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isDark ? Colors.white : slate900)),
                      ],
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => _showNotificationPanel(context, isDark),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? surfaceDark : surfaceLight,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4)
                      ],
                    ),
                    child: Icon(Icons.notifications_none,
                        color: isDark ? Colors.white : slate900),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => _showPeriodPicker(context, isDark),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? surfaceDark : surfaceLight,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month,
                            color: primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text('เดือนนี้ ($_selectedPeriod)',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : slate900)),
                        const SizedBox(width: 4),
                        const Icon(Icons.expand_more,
                            color: slate400, size: 20),
                      ],
                    ),
                  ),
                ),
                const Icon(Icons.filter_list, color: slate400),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? surfaceDark : surfaceLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: isDark ? Colors.grey[800]! : Colors.grey[100]!),
              ),
              child: Column(
                children: [
                  const Text('กำไรสุทธิ',
                      style: TextStyle(
                          color: slate500, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text('฿',
                          style: TextStyle(
                              color: slate400,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      Text('45,000',
                          style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : slate900)),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.trending_up,
                            color: primaryColor, size: 16),
                        const SizedBox(width: 4),
                        Text('+12% จากเดือนที่แล้ว',
                            style: TextStyle(
                                color: Colors.green[600],
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Divider(height: 40),
                  Row(
                    children: [
                      _buildMiniStat(true, "+60,000", isDark),
                      const SizedBox(width: 12),
                      _buildMiniStat(false, "-15,000", isDark),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('รายการล่าสุด',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : slate900)),
                TextButton(
                    onPressed: () {},
                    child: const Text('ดูทั้งหมด',
                        style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 8),
            _buildTransactionItem(context, "ขายข้าวหอมมะลิ", "วันนี้, 10:30 น.",
                "+12,000", "ขายผลผลิต", Icons.grass, Colors.green, isDark),
            _buildTransactionItem(context, "ค่าปุ๋ยเคมี", "เมื่อวาน, 14:20 น.",
                "-2,500", "วัสดุการเกษตร", Icons.compost, Colors.orange, isDark),
            _buildTransactionItem(context, "ค่าน้ำมันเชื้อเพลิง",
                "12 ต.ค., 09:15 น.", "-800", "ค่าใช้จ่ายทั่วไป",
                Icons.water_drop, Colors.blue, isDark),
            _buildTransactionItem(context, "ขายไข่ไก่", "10 ต.ค., 07:00 น.",
                "+540", "ขายผลผลิต", Icons.egg, Colors.green, isDark),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ProduceEntryPage()));
        },
        backgroundColor: primaryColor,
        foregroundColor: const Color(0xFF0a2b0a),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildMiniStat(bool isIncome, String amount, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isIncome
              ? (isDark ? Colors.green[900]!.withOpacity(0.1) : Colors.green[50])
              : (isDark ? Colors.red[900]!.withOpacity(0.1) : Colors.red[50]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isIncome
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 14, color: isIncome ? Colors.green : Colors.red),
                const SizedBox(width: 4),
                Text(isIncome ? 'รายรับ' : 'รายจ่าย',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 4),
            Text(amount,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isIncome ? Colors.green[700] : Colors.red[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, String title, String time,
      String amount, String tag, IconData icon, Color color, bool isDark) {
    return InkWell(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C261C) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[100]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : const Color(0xFF111811))),
                  Text(time,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: amount.startsWith('+')
                            ? Colors.green
                            : Colors.red)),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(tag,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}