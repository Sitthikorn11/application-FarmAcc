import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// แพ็กเกจสำหรับการทำ PDF
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Service Supabase
import 'package:application_farmacc/services/supabase_service.dart';

class SummaryReportPage extends StatefulWidget {
  const SummaryReportPage({super.key});

  @override
  State<SummaryReportPage> createState() => _SummaryReportPageState();
}

class _SummaryReportPageState extends State<SummaryReportPage> {
  final _service = SupabaseService();
  
  String _selectedPeriod = 'monthly'; // 'monthly' หรือ 'yearly'
  int _selectedYear = DateTime.now().year; // ปีที่เลือกดู
  bool _isLoading = true;

  // ตัวแปรเก็บข้อมูล
  double _income = 0;
  double _expense = 0;
  double _profit = 0;
  Map<int, double> _monthlyIncomeMap = {}; // เก็บรายรับรายเดือนสำหรับกราฟ

  // --- Color Palette ---
  static const Color primaryColor = Color(0xFF13ec13);
  static const Color dangerColor = Color(0xFFef4444);
  static const Color backgroundLight = Color(0xFFf6f8f6);
  static const Color backgroundDark = Color(0xFF102210);
  static const Color cardDark = Color(0xFF1a2e1a);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // ✅ ฟังก์ชันดึงและคำนวณข้อมูลจริง
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);

    DateTime startDate;
    DateTime endDate;
    final now = DateTime.now();

    if (_selectedPeriod == 'monthly') {
      // รายเดือน: เอาเดือนปัจจุบันของปีที่เลือก
      startDate = DateTime(_selectedYear, now.month, 1);
      // หาวันสุดท้ายของเดือน
      endDate = DateTime(_selectedYear, now.month + 1, 0, 23, 59, 59);
    } else {
      // รายปี: ทั้งปีมกรา - ธันวา
      startDate = DateTime(_selectedYear, 1, 1);
      endDate = DateTime(_selectedYear, 12, 31, 23, 59, 59);
    }

    try {
      // 1. ดึงข้อมูลตามช่วงเวลาสำหรับแสดงตัวเลขรวม
      final transactions = await _service.getTransactions(startDate: startDate, endDate: endDate);
      
      double inc = 0;
      double exp = 0;
      for (var t in transactions) {
        double amount = (t['amount'] as num).toDouble();
        if (t['type'] == 'income') inc += amount;
        else exp += amount;
      }

      // 2. ดึงข้อมูลทั้งปีสำหรับทำกราฟ (เฉพาะตอนเลือกรายปี หรือเพื่อโชว์เทรนด์)
      final yearData = await _service.getTransactions(
        startDate: DateTime(_selectedYear, 1, 1),
        endDate: DateTime(_selectedYear, 12, 31, 23, 59, 59)
      );
      
      Map<int, double> monthlyMap = {};
      for (var t in yearData) {
        if (t['type'] == 'income') {
          DateTime d = DateTime.parse(t['transaction_date']);
          // รวมยอดตามเดือน (1-12)
          monthlyMap[d.month] = (monthlyMap[d.month] ?? 0) + (t['amount'] as num).toDouble();
        }
      }

      if (mounted) {
        setState(() {
          _income = inc;
          _expense = exp;
          _profit = inc - exp;
          _monthlyIncomeMap = monthlyMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print('Error: $e');
    }
  }

  // --- ฟังก์ชันสร้าง PDF (ใช้ข้อมูลจริง) ---
  Future<void> _exportToPdf() async {
    final pdf = pw.Document();
    
    // โหลด Font ไทยจาก Google Fonts โดยตรงเพื่อให้แสดงผลใน PDF ได้
    final thaiFontRegular = await PdfGoogleFonts.sarabunRegular();
    final thaiFontBold = await PdfGoogleFonts.sarabunBold();

    final formatCurrency = NumberFormat('#,###.00');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('รายงานสรุปผลประกอบการ', style: pw.TextStyle(font: thaiFontBold, fontSize: 22)),
                  pw.Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()), style: pw.TextStyle(font: thaiFontRegular, fontSize: 12)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'ประจำปี $_selectedYear (${_selectedPeriod == 'monthly' ? 'เดือนปัจจุบัน' : 'ทั้งปี'})',
                style: pw.TextStyle(font: thaiFontRegular, fontSize: 16),
              ),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 20),
              
              // สรุปตัวเลข
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                ),
                child: pw.Column(
                  children: [
                    _pdfRow('กำไรสุทธิ', formatCurrency.format(_profit), thaiFontBold, isBold: true),
                    pw.SizedBox(height: 10),
                    _pdfRow('รายรับ', formatCurrency.format(_income), thaiFontRegular),
                    _pdfRow('รายจ่าย', formatCurrency.format(_expense), thaiFontRegular),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Text('หมายเหตุ: ข้อมูลจาก Application FarmAcc', 
                style: pw.TextStyle(font: thaiFontRegular, fontSize: 10, color: PdfColors.grey600)),
            ],
          );
        },
      ),
    );

    // สั่งพิมพ์หรือแชร์ไฟล์
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'report_${_selectedYear}_$_selectedPeriod.pdf',
    );
  }

  pw.Widget _pdfRow(String label, String value, pw.Font font, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: isBold ? 16 : 14)),
          pw.Text('฿$value', style: pw.TextStyle(font: font, fontSize: isBold ? 16 : 14, color: label == 'รายจ่าย' ? PdfColors.red : PdfColors.black)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textMain = isDark ? const Color(0xFFe0e6e0) : const Color(0xFF111811);
    final Color textSec = isDark ? const Color(0xFF8fa88f) : const Color(0xFF618961);
    final Color cardBg = isDark ? cardDark : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? backgroundDark : backgroundLight,
      appBar: _buildAppBar(isDark, cardBg, textMain),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryColor))
        : _buildSummaryContent(isDark, cardBg, textMain, textSec),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark, Color cardBg, Color textMain) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(130),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('สรุปผลประกอบการ', 
                      style: GoogleFonts.prompt(fontSize: 18, fontWeight: FontWeight.bold, color: textMain)),
                    Row(
                      children: [
                        // ปุ่ม PDF
                        IconButton(
                          icon: const Icon(Icons.picture_as_pdf, color: dangerColor), 
                          onPressed: _exportToPdf, // กดเพื่อสร้าง PDF
                        ),
                        // ปุ่มเลือกปี
                        DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedYear,
                            dropdownColor: cardBg,
                            icon: Icon(Icons.arrow_drop_down, color: textMain),
                            style: GoogleFonts.prompt(color: textMain, fontWeight: FontWeight.bold),
                            items: [2023, 2024, 2025, 2026, 2027].map((year) => DropdownMenuItem(value: year, child: Text('$year'))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedYear = val);
                                _fetchData();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 45,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildToggleButton('รายเดือน', 'monthly', isDark),
                      _buildToggleButton('รายปี', 'yearly', isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, String value, bool isDark) {
    bool isSelected = _selectedPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedPeriod = value);
          _fetchData(); // โหลดข้อมูลใหม่เมื่อเปลี่ยน Tab
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? (isDark ? Colors.grey[800] : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected && !isDark ? [BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
          ),
          child: Text(label, 
            style: GoogleFonts.prompt(
              fontSize: 14, 
              fontWeight: FontWeight.bold, 
              color: isSelected ? primaryColor : Colors.grey
            )),
        ),
      ),
    );
  }

  Widget _buildSummaryContent(bool isDark, Color cardBg, Color textMain, Color textSec) {
    final formatCurrency = NumberFormat('#,###');
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Text(
                  _selectedPeriod == 'monthly' ? 'เดือนปัจจุบัน ($_selectedYear)' : 'ปีงบประมาณ $_selectedYear', 
                  style: GoogleFonts.prompt(fontSize: 24, fontWeight: FontWeight.bold, color: textMain)
                ),
                Text(
                  _selectedPeriod == 'monthly' ? 'ข้อมูลเฉพาะเดือนนี้' : 'รวมข้อมูล ม.ค. - ธ.ค.', 
                  style: GoogleFonts.prompt(color: textSec, fontSize: 13)
                ),
              ],
            ),
          ),

          // แสดงข้อมูลตาม Tab ที่เลือก
          if (_selectedPeriod == 'monthly') ...[
            _buildProfitCard(isDark, cardBg, textMain, textSec, formatCurrency.format(_profit), formatCurrency.format(_income), formatCurrency.format(_expense)),
            _buildRatioCard(isDark, cardBg, textMain, textSec, (_income + _expense) == 0 ? 0 : _income / (_income + _expense)),
          ] else ...[
            _buildProfitCard(isDark, cardBg, textMain, textSec, formatCurrency.format(_profit), formatCurrency.format(_income), formatCurrency.format(_expense)),
            _buildYearlyChart(isDark, cardBg, textMain),
          ],
        ],
      ),
    );
  }

  Widget _buildProfitCard(bool isDark, Color cardBg, Color textMain, Color textSec, String profit, String income, String expense) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg, 
        borderRadius: BorderRadius.circular(24), 
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))
      ),
      child: Column(
        children: [
          Text('กำไรสุทธิ${_selectedPeriod == 'yearly' ? 'รวม' : ''}', 
            style: GoogleFonts.prompt(color: textSec, fontSize: 14)),
          const SizedBox(height: 8),
          Text('฿$profit', 
            style: GoogleFonts.notoSans(fontSize: 36, fontWeight: FontWeight.w900, color: _profit >= 0 ? primaryColor : dangerColor)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),
          Row(
            children: [
              _buildMiniStat('รายรับ', '฿$income', primaryColor, textMain, textSec),
              _buildMiniStat('รายจ่าย', '฿$expense', dangerColor, textMain, textSec),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color, Color textMain, Color textSec) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), 
            const SizedBox(width: 8), 
            Text(label, style: GoogleFonts.prompt(color: textSec, fontSize: 12))
          ]),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.notoSans(color: textMain, fontSize: 18, fontWeight: FontWeight.bold)),
        ]
      ),
    );
  }

  Widget _buildYearlyChart(bool isDark, Color cardBg, Color textMain) {
    // หาค่าสูงสุดเพื่อเทียบสัดส่วนกราฟ
    double maxVal = 1;
    _monthlyIncomeMap.forEach((_, val) { if(val > maxVal) maxVal = val; });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('แนวโน้มรายรับ (ม.ค.-มิ.ย.)', style: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: textMain)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar((_monthlyIncomeMap[1] ?? 0) / maxVal * 100, "ม.ค."),
              _buildBar((_monthlyIncomeMap[2] ?? 0) / maxVal * 100, "ก.พ."),
              _buildBar((_monthlyIncomeMap[3] ?? 0) / maxVal * 100, "มี.ค."),
              _buildBar((_monthlyIncomeMap[4] ?? 0) / maxVal * 100, "เม.ย."),
              _buildBar((_monthlyIncomeMap[5] ?? 0) / maxVal * 100, "พ.ค."),
              _buildBar((_monthlyIncomeMap[6] ?? 0) / maxVal * 100, "มิ.ย."),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double heightPercentage, String label) {
    // กำหนดความสูงขั้นต่ำ 2 เพื่อให้เห็นกราฟแม้ค่าน้อย
    double h = heightPercentage < 2 ? 2 : heightPercentage;
    return Column(
      children: [
        Container(
          width: 15, 
          height: h, // ความสูงตาม % ของยอดขาย
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.7), 
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8), 
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildRatioCard(bool isDark, Color cardBg, Color textMain, Color textSec, double ratio) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Text('สัดส่วนรายรับ vs รายจ่าย', style: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: textMain)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10), 
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 12,
              backgroundColor: dangerColor,
              valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
        ]
      ),
    );
  }
}