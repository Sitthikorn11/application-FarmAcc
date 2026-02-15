import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// Import หน้าต่างๆ
import 'package:application_farmacc/main_dashbord/ProduceEntry.dart';
import 'package:application_farmacc/editprofile/profile.dart';
import 'package:application_farmacc/main_dashbord/transaction.dart';
import 'package:application_farmacc/main_dashbord/summaryreport.dart';
import 'package:application_farmacc/login_gold/login.dart';
import 'package:application_farmacc/services/supabase_service.dart';
import 'package:application_farmacc/main_dashbord/market_price.dart';
import 'package:application_farmacc/main_dashbord/weather_card.dart';
import 'package:application_farmacc/main_dashbord/calendar_page.dart';
import 'package:application_farmacc/login_gold/change_password.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('th', null);

  await Supabase.initialize(
    url: 'https://ahmbevnarwxjsduiogrp.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFobWJldm5hcnd4anNkdWlvZ3JwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4MjcwMDIsImV4cCI6MjA4NDQwMzAwMn0.aObq5MpxgaWE60FZ8kwXexE6Zyve6jlTmUFHrekdqcI',
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => const ChangePasswordPage()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'FarmAcc',
      theme: ThemeData(
        textTheme: GoogleFonts.kanitTextTheme(),
        primarySwatch: Colors.green,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF13ec13),
          primary: const Color(0xFF13ec13),
        ),
      ),
      home: isLoggedIn ? const FarmerDashboard() : const LoginPage(),
    );
  }
}

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  int _currentIndex = 0;
  final _service = SupabaseService();

  String _userName = 'ผู้ใช้งาน';
  String? _avatarUrl;
  double _totalIncome = 0;
  double _totalExpense = 0;
  List<Map<String, dynamic>> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _service.getUserProfile();
      final allTrans = await _service.getTransactions();

      double income = 0;
      double expense = 0;

      for (var t in allTrans) {
        final amount = (t['amount'] as num).toDouble();
        if (t['type'] == 'income') {
          income += amount;
        } else {
          expense += amount;
        }
      }

      final recent = allTrans.take(5).toList();

      if (mounted) {
        setState(() {
          if (profile != null) {
            _userName = profile['full_name'] ?? 'ผู้ใช้งาน';
            _avatarUrl = profile['avatar_url'];
          }
          _totalIncome = income;
          _totalExpense = expense;
          _recentTransactions = recent;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      _buildHomeContent(context, isDark),
      const AllTransactionsPage(),
      const ProduceEntryPage(),
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
        selectedItemColor: const Color(0xFF39FF14),
        unselectedItemColor: const Color(0xFF94A3B8),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) _fetchAllData();
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
              icon: Icon(Icons.add_circle_outline, size: 30),
              label: 'จดบันทึก'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded), label: 'สรุป'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'ข้อมูลส่วนตัว'),
        ],
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, bool isDark) {
    const Color primaryColor = Color(0xFF13ec13);
    final Color background =
        isDark ? const Color(0xFF102210) : const Color(0xFFf6f8f6);
    final Color surface = isDark ? const Color(0xFF1C261C) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0f172a);

    final formatCurrency = NumberFormat('#,###.##');
    double profit = _totalIncome - _totalExpense;

    return Scaffold(
      backgroundColor: background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : RefreshIndicator(
              onRefresh: _fetchAllData,
              color: primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // --- Header ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: _avatarUrl != null
                                  ? NetworkImage(_avatarUrl!)
                                  : null,
                              child: _avatarUrl == null
                                  ? const Icon(Icons.person, color: Colors.grey)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('สวัสดี',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14)),
                                Text(_userName,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: textColor)),
                              ],
                            ),
                          ],
                        ),
                        // ✅ ปุ่มลัดด้านขวา (เอาปุ่มระฆังออกแล้ว)
                        Row(
                          children: [
                            _buildQuickActionButton(
                              context,
                              icon: Icons.storefront,
                              color: Colors.orange,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) => const MarketPricePage())),
                            ),
                            const SizedBox(width: 8),
                            _buildQuickActionButton(
                              context,
                              icon: Icons.calendar_month,
                              color: Colors.green,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) => const CalendarPage())),
                            ),
                          ],
                        )
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- Weather Card ---
                    const WeatherCard(),

                    const SizedBox(height: 24),

                    // --- Summary Card (Profit) ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10)
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text('กำไรสุทธิ',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Text(
                            '฿${formatCurrency.format(profit)}',
                            style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: profit >= 0 ? textColor : Colors.red),
                          ),
                          const Divider(height: 40),
                          Row(
                            children: [
                              _buildMiniStat(true,
                                  formatCurrency.format(_totalIncome), isDark),
                              const SizedBox(width: 12),
                              _buildMiniStat(false,
                                  formatCurrency.format(_totalExpense), isDark),
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- Recent Transactions ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('รายการล่าสุด',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor)),
                        TextButton(
                          onPressed: () => setState(() => _currentIndex = 1),
                          child: const Text('ดูทั้งหมด',
                              style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    if (_recentTransactions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('ยังไม่มีรายการบันทึก',
                            style: TextStyle(color: Colors.grey)),
                      )
                    else
                      ..._recentTransactions.map((t) {
                        bool isIncome = t['type'] == 'income';
                        return _buildTransactionItem(
                          title: t['category'] ?? 'ทั่วไป',
                          time: DateFormat('dd MMM, HH:mm', 'th')
                              .format(DateTime.parse(t['transaction_date'])),
                          amount:
                              '${isIncome ? '+' : '-'} ${formatCurrency.format(t['amount'])}',
                          tag: isIncome ? 'รายรับ' : 'รายจ่าย',
                          icon: isIncome
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: isIncome ? Colors.green : Colors.red,
                          isDark: isDark,
                          surface: surface,
                          textColor: textColor,
                        );
                      }).toList(),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProduceEntryPage()),
          );
          _fetchAllData();
        },
        backgroundColor: primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28, color: Colors.black),
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context,
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onTap,
      ),
    );
  }

  Widget _buildMiniStat(bool isIncome, String amount, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isIncome
              ? (isDark
                  ? Colors.green[900]!.withOpacity(0.2)
                  : Colors.green[50])
              : (isDark ? Colors.red[900]!.withOpacity(0.2) : Colors.red[50]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 16, color: isIncome ? Colors.green : Colors.red),
                const SizedBox(width: 4),
                Text(isIncome ? 'รายรับ' : 'รายจ่าย',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

  Widget _buildTransactionItem({
    required String title,
    required String time,
    required String amount,
    required String tag,
    required IconData icon,
    required Color color,
    required bool isDark,
    required Color surface,
    required Color textColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1), shape: BoxShape.circle),
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
                        fontSize: 16,
                        color: textColor)),
                Text(time,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16, color: color)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
    );
  }
}
