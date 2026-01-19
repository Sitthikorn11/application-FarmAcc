import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // --- ส่วนของ Controllers สำหรับเก็บข้อมูลที่แก้ ---
  // ข้อมูลพื้นฐาน
  final _nameController = TextEditingController(text: 'สมชาย ใจดี');
  final _jobController = TextEditingController(text: 'เกษตรกรสวนผลไม้');
  final _locationCityController = TextEditingController(text: 'เชียงใหม่, ไทย');
  
  // ข้อมูลติดต่อ
  final _phoneController = TextEditingController(text: '081-234-5678');
  final _emailController = TextEditingController(text: 'somchai@example.com');
  final _addressController = TextEditingController(text: '123 หมู่ 4 ต.แม่เหียะ อ.เมือง จ.เชียงใหม่ 50100');
  
  // ข้อมูลฟาร์ม
  final _farmNameController = TextEditingController(text: 'สวนลุงสมชาย');
  final _farmTypeController = TextEditingController(text: 'สวนลำไย');
  final _farmSizeController = TextEditingController(text: '15 ไร่');

  @override
  void dispose() {
    // ล้างหน่วยความจำเมื่อเลิกใช้งาน
    _nameController.dispose();
    _jobController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _farmNameController.dispose();
    _farmTypeController.dispose();
    _farmSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color primaryColor = Color(0xFF13ec13);
    final Color textMain = isDark ? Colors.white : const Color(0xFF111811);
    final Color surfaceColor = isDark ? const Color(0xFF1a2e1a) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF102210) : const Color(0xFFf6f8f6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: textMain),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'แก้ไขข้อมูล',
          style: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: บันทึกข้อมูลลง Database หรือ Provider
              Navigator.pop(context);
            },
            child: const Text(
              'บันทึก',
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนเปลี่ยนรูปภาพ
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: const NetworkImage('https://via.placeholder.com/150'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: primaryColor,
                      child: const Icon(Icons.camera_alt, size: 18, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- กลุ่มข้อมูลส่วนตัว ---
            _buildSectionLabel("ข้อมูลส่วนตัว", isDark),
            _buildEditField("ชื่อ-นามสกุล", _nameController, isDark, surfaceColor),
            _buildEditField("อาชีพ", _jobController, isDark, surfaceColor),
            _buildEditField("จังหวัด/ประเทศ", _locationCityController, isDark, surfaceColor),
            
            const SizedBox(height: 25),

            // --- กลุ่มข้อมูลติดต่อ ---
            _buildSectionLabel("ข้อมูลติดต่อ", isDark),
            _buildEditField("เบอร์โทรศัพท์", _phoneController, isDark, surfaceColor, keyboardType: TextInputType.phone),
            _buildEditField("อีเมล", _emailController, isDark, surfaceColor, keyboardType: TextInputType.emailAddress),
            _buildEditField("ที่อยู่", _addressController, isDark, surfaceColor, isMultiLine: true),

            const SizedBox(height: 25),

            // --- กลุ่มข้อมูลฟาร์ม ---
            _buildSectionLabel("ข้อมูลฟาร์ม", isDark),
            _buildEditField("ชื่อฟาร์ม", _farmNameController, isDark, surfaceColor),
            _buildEditField("ประเภทฟาร์ม (เช่น สวนลำไย)", _farmTypeController, isDark, surfaceColor),
            _buildEditField("ขนาดพื้นที่", _farmSizeController, isDark, surfaceColor),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget ช่วยสร้างหัวข้อกลุ่ม
  Widget _buildSectionLabel(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? const Color(0xFF13ec13) : const Color(0xFF108510),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Widget ช่วยสร้างช่องกรอกข้อมูล
  Widget _buildEditField(String label, TextEditingController controller, bool isDark, Color surface, {TextInputType? keyboardType, bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: isMultiLine ? 3 : 1,
        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14),
          filled: true,
          fillColor: surface,
          alignLabelWithHint: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF13ec13), width: 2),
          ),
        ),
      ),
    );
  }
}