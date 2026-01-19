import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProduceEntryPage(),
    ),
  );
}

class ProduceEntryPage extends StatefulWidget {
  const ProduceEntryPage({super.key});

  @override
  State<ProduceEntryPage> createState() => _ProduceEntryPageState();
}

class _ProduceEntryPageState extends State<ProduceEntryPage> {
  // สถานะการสลับ รายเดือน(รายรับ) / รายปี(รายจ่าย) - อิงตามดีไซน์รูปภาพ
  bool _isIncome = true; 

  DateTime _selectedDate = DateTime.now();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _expenseController = TextEditingController();
  
  String? _selectedCategory;
  String _selectedUnit = 'กก.'; 

  // สูตรคำนวณรายรับ
  double get _calculatedIncome {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    double price = double.tryParse(_priceController.text) ?? 0.0;
    return amount * price;
  }

  // จำนวนเงินรวม (ถ้าเป็นรายรับใช้ค่าจากการคำนวณ ถ้ารายจ่ายใช้ค่าจากช่องกรอก)
  double get _totalValue => _isIncome ? _calculatedIncome : (double.tryParse(_expenseController.text) ?? 0.0);

  static const Color primaryColor = Color(0xFF13ec13); // สีเขียว
  static const Color expenseColor = Color(0xFFFF5252); // สีแดง
  static const Color backgroundDark = Color(0xFF102210);
  static const Color surfaceDark = Color(0xFF1a2e1a);
  static const Color borderDark = Color(0xFF2a422a);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? backgroundDark : const Color(0xFFf6f8f6),
      appBar: AppBar(
        backgroundColor: isDark ? surfaceDark : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'บันทึกข้อมูลการเกษตร',
          style: GoogleFonts.notoSansThai(
            fontWeight: FontWeight.bold, fontSize: 18,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- ปุ่มสลับ รายรับ/รายจ่าย (แบบในรูปภาพ) ---
            _buildToggleButton(isDark),
            
            const SizedBox(height: 24),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('ประเภทรายการ', isDark),
                _buildDropdownField(
                  hint: 'เลือกรายการ...',
                  value: _selectedCategory,
                  items: _isIncome 
                    ? ['ข้าวนาปี', 'ข้าวโพด', 'ทุเรียน', 'ยางพารา'] 
                    : ['ค่าปุ๋ย', 'ค่ายาฆ่าแมลง', 'ค่าแรงงาน', 'ค่าเมล็ดพันธุ์'],
                  onChanged: (val) => setState(() => _selectedCategory = val),
                  isDark: isDark,
                ),
                const SizedBox(height: 16),

                _buildLabel('วันที่บันทึก', isDark),
                _buildDatePicker(isDark),
                const SizedBox(height: 16),

                // แสดงช่องกรอกตามประเภทที่เลือก
                if (_isIncome) ...[
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('ปริมาณที่ได้', isDark),
                            _buildTextField(
                              controller: _amountController,
                              hint: '0.00',
                              isDark: isDark,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('หน่วย', isDark),
                            _buildDropdownField(
                              value: _selectedUnit,
                              items: ['กก.', 'ตัน', 'ลูก'], 
                              onChanged: (val) => setState(() => _selectedUnit = val!),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('ราคาต่อหน่วย (บาท)', isDark),
                  _buildTextField(
                    controller: _priceController,
                    hint: '0.00',
                    prefix: const Text('฿ ', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                    isDark: isDark,
                    keyboardType: TextInputType.number,
                  ),
                ] else ...[
                  _buildLabel('จำนวนเงินที่จ่าย (บาท)', isDark),
                  _buildTextField(
                    controller: _expenseController,
                    hint: '0.00',
                    prefix: const Text('฿ ', style: TextStyle(color: expenseColor, fontWeight: FontWeight.bold)),
                    isDark: isDark,
                    keyboardType: TextInputType.number,
                  ),
                ],

                const SizedBox(height: 32),
                
                // การ์ดสรุปยอด
                _buildSummaryCard(isDark),

                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isIncome ? primaryColor : expenseColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('บันทึกข้อมูล', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget ปุ่มสลับแบบในรูปภาพ ---
  Widget _buildToggleButton(bool isDark) {
    return Container(
      width: double.infinity,
      height: 60,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1a2e1a) : Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isIncome = true),
              child: Container(
                decoration: BoxDecoration(
                  color: _isIncome ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isIncome ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)] : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'รายรับ', // หรือ 'รายเดือน' ตามรูป
                  style: GoogleFonts.notoSansThai(
                    color: _isIncome ? primaryColor : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isIncome = false),
              child: Container(
                decoration: BoxDecoration(
                  color: !_isIncome ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !_isIncome ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)] : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'รายจ่าย', // หรือ 'รายปี' ตามรูป
                  style: GoogleFonts.notoSansThai(
                    color: !_isIncome ? expenseColor : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets ส่วนประกอบอื่นๆ (คงเดิมและปรับปรุง Error) ---

  Widget _buildLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, Widget? prefix, required bool isDark, required TextInputType keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (val) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefix != null ? Padding(padding: const EdgeInsets.all(14), child: prefix) : null,
        filled: true,
        fillColor: isDark ? surfaceDark : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdownField({required String? value, required List<String> items, required Function(String?) onChanged, String? hint, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isDark ? surfaceDark : Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
            const Spacer(),
            const Icon(Icons.calendar_month, color: primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(_isIncome ? 'รวมรายรับ' : 'รวมรายจ่าย', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('฿ ', style: TextStyle(color: _isIncome ? primaryColor : expenseColor, fontSize: 20, fontWeight: FontWeight.bold)),
              Text(
                NumberFormat('#,###.00').format(_totalValue), 
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ],
      ),
    );
  }
}