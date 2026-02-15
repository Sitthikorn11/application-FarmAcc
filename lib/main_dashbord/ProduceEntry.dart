import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // ✅ เพิ่มเช็ค Web
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:application_farmacc/services/supabase_service.dart'; 

class ProduceEntryPage extends StatefulWidget {
  const ProduceEntryPage({super.key});

  @override
  State<ProduceEntryPage> createState() => _ProduceEntryPageState();
}

class _ProduceEntryPageState extends State<ProduceEntryPage> {
  // สถานะการสลับ รายเดือน(รายรับ) / รายปี(รายจ่าย)
  bool _isIncome = true;
  bool _isLoading = false; // สถานะโหลดขณะบันทึก

  DateTime _selectedDate = DateTime.now();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _expenseController = TextEditingController();

  String? _selectedCategory;
  String _selectedUnit = 'กก.';
  
  // ✅ แก้ไข 1: เปลี่ยนจาก File? เป็น XFile?
  XFile? _imageFile; 

  final _service = SupabaseService(); 

  // สูตรคำนวณรายรับ
  double get _calculatedIncome {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    double price = double.tryParse(_priceController.text) ?? 0.0;
    return amount * price;
  }

  // จำนวนเงินรวม
  double get _totalValue =>
      _isIncome ? _calculatedIncome : (double.tryParse(_expenseController.text) ?? 0.0);

  // สี Theme
  static const Color primaryColor = Color(0xFF13ec13); // สีเขียว
  static const Color expenseColor = Color(0xFFFF5252); // สีแดง
  static const Color backgroundDark = Color(0xFF102210);
  static const Color surfaceDark = Color(0xFF1a2e1a);

  @override
  void dispose() {
    _amountController.dispose();
    _priceController.dispose();
    _expenseController.dispose();
    super.dispose();
  }

  // ✅ ฟังก์ชันเลือกรูปภาพ (แก้ไขแล้ว)
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        // ✅ เก็บค่า XFile โดยตรง ไม่ต้องแปลงเป็น File
        _imageFile = pickedFile;
      });
    }
  }

  // ✅ ฟังก์ชันบันทึกข้อมูลลง Supabase
  Future<void> _saveData() async {
    // ตรวจสอบข้อมูลเบื้องต้น
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณาเลือกประเภทรายการ')));
      return;
    }
    if (_totalValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณากรอกจำนวนเงินให้ถูกต้อง')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // สร้างคำอธิบายรายละเอียด (Description) อัตโนมัติ
      String description = '';
      if (_isIncome) {
        description = '${_amountController.text} $_selectedUnit x ${_priceController.text} บาท';
      } else {
        description = 'รายจ่ายหมวดหมู่ $_selectedCategory';
      }

      // เรียก Service บันทึกข้อมูล
      await _service.addTransaction(
        type: _isIncome ? 'income' : 'expense',
        amount: _totalValue,
        category: _selectedCategory!, 
        description: description,
        imageFile: _imageFile, // ✅ ส่ง XFile ไปได้เลย
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกข้อมูลสำเร็จ!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // กลับไปหน้าหลัก
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? backgroundDark : const Color(0xFFf6f8f6),
      appBar: AppBar(
        backgroundColor: isDark ? surfaceDark : Colors.white,
        elevation: 0,
        centerTitle: true,
        // ปุ่มย้อนกลับ
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'บันทึกข้อมูลการเกษตร',
          style: GoogleFonts.notoSansThai(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- ปุ่มสลับ รายรับ/รายจ่าย ---
            _buildToggleButton(isDark),

            const SizedBox(height: 24),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel('ประเภทรายการ', isDark),
                _buildDropdownField(
                  hint: 'เลือกรายการ...',
                  value: _selectedCategory,
                  // รายการตัวเลือกเปลี่ยนไปตามโหมด (รับ/จ่าย)
                  items: _isIncome
                      ? ['ข้าวนาปี', 'ข้าวโพด', 'ทุเรียน', 'ยางพารา', 'มันสำปะหลัง', 'อื่นๆ']
                      : ['ค่าปุ๋ย', 'ค่ายาฆ่าแมลง', 'ค่าแรงงาน', 'ค่าเมล็ดพันธุ์', 'ค่าน้ำมัน', 'ค่าซ่อมแซม', 'อื่นๆ'],
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
                              items: ['กก.', 'ตัน', 'ลูก', 'ลิตร', 'ถัง'],
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
                    prefix: const Text('฿ ',
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                    isDark: isDark,
                    keyboardType: TextInputType.number,
                  ),
                ] else ...[
                  _buildLabel('จำนวนเงินที่จ่าย (บาท)', isDark),
                  _buildTextField(
                    controller: _expenseController,
                    hint: '0.00',
                    prefix: const Text('฿ ',
                        style: TextStyle(color: expenseColor, fontWeight: FontWeight.bold)),
                    isDark: isDark,
                    keyboardType: TextInputType.number,
                  ),
                ],

                const SizedBox(height: 32),

                // การ์ดสรุปยอด
                _buildSummaryCard(isDark),

                const SizedBox(height: 20),

                // ✅ ส่วนเพิ่มรูปภาพ (ใบเสร็จ/สลิป)
                _buildImagePicker(isDark),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveData, // ✅ เชื่อมฟังก์ชันบันทึก
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isIncome ? primaryColor : expenseColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('บันทึกข้อมูล',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Widgets Components ---

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
                  boxShadow: _isIncome
                      ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'รายรับ',
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
                  boxShadow: !_isIncome
                      ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'รายจ่าย',
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

  Widget _buildLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black)),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hint,
      Widget? prefix,
      required bool isDark,
      required TextInputType keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (val) => setState(() {}),
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: prefix != null
            ? Padding(padding: const EdgeInsets.all(14), child: prefix)
            : null,
        filled: true,
        fillColor: isDark ? surfaceDark : Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdownField(
      {required String? value,
      required List<String> items,
      required Function(String?) onChanged,
      String? hint,
      required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: hint != null
              ? Text(hint, style: TextStyle(color: Colors.grey[400]))
              : null,
          isExpanded: true,
          dropdownColor: isDark ? surfaceDark : Colors.white,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDatePicker(bool isDark) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100));
        if (date != null) setState(() => _selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: isDark ? surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Text(DateFormat('dd/MM/yyyy').format(_selectedDate),
                style: TextStyle(color: isDark ? Colors.white : Colors.black)),
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
        boxShadow: [
          BoxShadow(color: (_isIncome ? primaryColor : expenseColor).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        children: [
          Text(_isIncome ? 'รวมรายรับสุทธิ' : 'รวมรายจ่ายสุทธิ',
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('฿ ',
                  style: TextStyle(
                      color: _isIncome ? primaryColor : expenseColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text(
                NumberFormat('#,###.00').format(_totalValue),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget เลือกรูปภาพ (แก้ไขแล้ว)
  Widget _buildImagePicker(bool isDark) {
    // 🖼️ เตรียม ImageProvider (แสดงรูป Preview)
    ImageProvider? imageProvider;
    if (_imageFile != null) {
      if (kIsWeb) {
        // Web: ใช้ NetworkImage (blob url)
        imageProvider = NetworkImage(_imageFile!.path);
      } else {
        // Mobile: ใช้ FileImage (path ในเครื่อง)
        imageProvider = FileImage(File(_imageFile!.path));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('หลักฐาน / ใบเสร็จ (ถ้ามี)', isDark),
        GestureDetector(
          onTap: () => _showImageSourceModal(context),
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: isDark ? surfaceDark : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              image: imageProvider != null
                  ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                  : null,
            ),
            child: _imageFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, color: Colors.grey[400], size: 40),
                      const SizedBox(height: 8),
                      Text('แตะเพื่อเพิ่มรูปภาพ', style: TextStyle(color: Colors.grey[400])),
                    ],
                  )
                : null,
          ),
        ),
        if (_imageFile != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => setState(() => _imageFile = null),
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              label: const Text('ลบรูปภาพ', style: TextStyle(color: Colors.red)),
            ),
          )
      ],
    );
  }

  void _showImageSourceModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('เลือกจากอัลบั้ม'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('ถ่ายภาพ'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}