import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// แพ็กเกจสำหรับการทำ PDF
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.light),
    darkTheme: ThemeData(brightness: Brightness.dark),
    home: const SummaryReportPage(),
  ));
}

class SummaryReportPage extends StatefulWidget {
  const SummaryReportPage({super.key});

  @override
  State<SummaryReportPage> createState() => _SummaryReportPageState();
}

class _SummaryReportPageState extends State<SummaryReportPage> {
  String _selectedPeriod = 'monthly'; // 'monthly' หรือ 'yearly'
  
  // --- Color Palette ---
  static const Color primaryColor = Color(0xFF13ec13);
  static const Color dangerColor = Color(0xFFef4444);
  static const Color backgroundLight = Color(0xFFf6f8f6);
  static const Color backgroundDark = Color(0xFF102210);
  static const Color cardDark = Color(0xFF1a2e1a);

  // --- ฟังก์ชันสร้าง PDF ---
  Future<void> _exportToPdf() async {
    final pdf = pw.Document();
    
    // โหลด Font ภาษาไทยสำหรับ PDF (สำคัญมาก)
    final ThaiFontRegular = await PdfGoogleFonts.promptRegular();
    final ThaiFontBold = await PdfGoogleFonts.promptBold();

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
                  pw.Text('รายงานสรุปผลประกอบการ', style: pw.TextStyle(font: ThaiFontBold, fontSize: 22)),
                  pw.Text(DateTime.now().toString().split(' ')[0], style: pw.TextStyle(font: ThaiFontRegular, fontSize: 12)),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                _selectedPeriod == 'monthly' ? 'ประเภท: รายเดือน (ตุลาคม 2566)' : 'ประเภท: รายปี (2566)',
                style: pw.TextStyle(font: ThaiFontRegular, fontSize: 16),
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
                    _pdfRow('กำไรสุทธิ', _selectedPeriod == 'monthly' ? '35,000' : '420,000', ThaiFontBold, isBold: true),
                    pw.SizedBox(height: 10),
                    _pdfRow('รายรับ', _selectedPeriod == 'monthly' ? '50,000' : '600,000', ThaiFontRegular),
                    _pdfRow('รายจ่าย', _selectedPeriod == 'monthly' ? '15,000' : '180,000', ThaiFontRegular),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Text('หมายเหตุ: รายงานฉบับนี้สร้างขึ้นโดยระบบอัตโนมัติ', 
                style: pw.TextStyle(font: ThaiFontRegular, fontSize: 10, color: PdfColors.grey600)),
            ],
          );
        },
      ),
    );

    // แสดงหน้าต่าง Preview และสั่งพิมพ์/บันทึก
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'report_${_selectedPeriod}.pdf',
    );
  }

  pw.Widget _pdfRow(String label, String value, pw.Font font, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: font, fontSize: isBold ? 16 : 14)),
          pw.Text('฿$value', style: pw.TextStyle(font: font, fontSize: isBold ? 16 : 14)),
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
      body: _buildSummaryContent(isDark, cardBg, textMain, textSec),
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
                        // ปุ่มส่งออก PDF
                        IconButton(
                          icon: const Icon(Icons.picture_as_pdf, color: dangerColor), 
                          onPressed: _exportToPdf,
                        ),
                        IconButton(icon: Icon(Icons.calendar_month, color: textMain), onPressed: () {}),
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
        onTap: () => setState(() => _selectedPeriod = value),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Text(
                  _selectedPeriod == 'monthly' ? 'ตุลาคม 2566' : 'ปีงบประมาณ 2566', 
                  style: GoogleFonts.prompt(fontSize: 24, fontWeight: FontWeight.bold, color: textMain)
                ),
                Text(
                  _selectedPeriod == 'monthly' ? 'ข้อมูลล่าสุด: 31 ต.ค. 2566' : 'รวมข้อมูลมกราคม - ธันวาคม', 
                  style: GoogleFonts.prompt(color: textSec, fontSize: 13)
                ),
              ],
            ),
          ),

          if (_selectedPeriod == 'monthly') ...[
            _buildProfitCard(isDark, cardBg, textMain, textSec, "35,000", "50,000", "15,000"),
            _buildRatioCard(isDark, cardBg, textMain, textSec, 0.75),
            _buildDetailSection(isDark, cardBg, textMain, textSec),
          ] else ...[
            _buildProfitCard(isDark, cardBg, textMain, textSec, "420,000", "600,000", "180,000"),
            _buildYearlyChart(isDark, cardBg, textMain),
            _buildQuarterlySection(isDark, cardBg, textMain, textSec),
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
            style: GoogleFonts.notoSans(fontSize: 36, fontWeight: FontWeight.w900, color: primaryColor)),
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
          Text('แนวโน้มผลประกอบการ', style: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: textMain)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(40, "ม.ค."), _buildBar(60, "ก.พ."), _buildBar(90, "มี.ค."),
              _buildBar(50, "เม.ย."), _buildBar(70, "พ.ค."), _buildBar(100, "มิ.ย."),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, String label) {
  return Column(
    children: [
      Container(
        width: 15, 
        height: height,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.7), 
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(height: 8), // ใส่ const ตรงนี้ได้เพราะเลข 8 ไม่เปลี่ยนแปลง
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)), // ลบ const หน้า Text ออก
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
            )
          ),
        ]
      ),
    );
  }

  Widget _buildDetailSection(bool isDark, Color cardBg, Color textMain, Color textSec) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12), 
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('รายการล่าสุด', style: GoogleFonts.prompt(fontSize: 18, fontWeight: FontWeight.bold, color: textMain))
        )
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          _buildDetailItem(Icons.agriculture, 'ขายผลผลิตลำไย', '15 ต.ค.', '+฿25,000', primaryColor),
          const Divider(height: 1),
          _buildDetailItem(Icons.water_drop, 'ค่าน้ำ/ค่าไฟฟาร์ม', '12 ต.ค.', '-฿5,000', dangerColor),
        ]),
      ),
    ]);
  }

  Widget _buildQuarterlySection(bool isDark, Color cardBg, Color textMain, Color textSec) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12), 
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('สรุปตามไตรมาส', style: GoogleFonts.prompt(fontSize: 18, fontWeight: FontWeight.bold, color: textMain))
        )
      ),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          _buildDetailItem(Icons.pie_chart, 'ไตรมาส 1 (ม.ค. - มี.ค.)', 'กำไรสะสม', '฿120,000', primaryColor),
          const Divider(height: 1),
          _buildDetailItem(Icons.pie_chart, 'ไตรมาส 2 (เม.ย. - มิ.ย.)', 'กำไรสะสม', '฿150,000', primaryColor),
        ]),
      ),
    ]);
  }

  Widget _buildDetailItem(IconData icon, String title, String subtitle, String amount, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8), 
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), 
        child: Icon(icon, color: color, size: 20)
      ),
      title: Text(title, style: GoogleFonts.prompt(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: GoogleFonts.prompt(fontSize: 12, color: Colors.grey)),
      trailing: Text(amount, style: GoogleFonts.notoSans(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }
}