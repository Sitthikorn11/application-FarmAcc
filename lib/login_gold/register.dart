import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    MaterialApp(
      home: RegisterPage(),
    ),
  );
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isObscure = true;
  final Color slate900 = const Color(0xFF0f172a);
  final Color slate500 = const Color(0xFF64748b);
  final Color slate200 = const Color(0xFFe2e8f0);
  final Color slate700 = const Color(0xFF334155);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color primaryColor = Color(0xFF13ec13);

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: IconThemeData(color: isDark ? Colors.white : slate900)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Illustration Placeholder
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.spa, size: 60, color: primaryColor),
              ),
              const SizedBox(height: 24),
              Text('สร้างบัญชีใหม่', style: GoogleFonts.notoSansThai(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : slate900)),
              const SizedBox(height: 8),
              Text('เริ่มต้นบันทึกผลผลิตของคุณวันนี้', style: TextStyle(color: isDark ? Colors.grey : slate500, fontSize: 16)),
              const SizedBox(height: 32),

              _buildField("ชื่อผู้ใช้", "กรอกชื่อผู้ใช้ของคุณ", Icons.person_outline, isDark),
              const SizedBox(height: 20),
              _buildField("รหัสผ่าน", "••••••••", Icons.lock_outline, isDark, isPassword: true),
              const SizedBox(height: 20),
              _buildField("ยืนยันรหัสผ่าน", "••••••••", Icons.lock_outline, isDark, isPassword: true),
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: const Color(0xFF102210), shape: const StadiumBorder()),
                  child: const Text('ลงทะเบียน', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String hint, IconData icon, bool isDark, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : slate900)),
        const SizedBox(height: 8),
        TextField(
          obscureText: isPassword && _isObscure,
          style: TextStyle(color: isDark ? Colors.white : slate900),
          decoration: InputDecoration(
            hintText: hint, prefixIcon: Icon(icon, color: Colors.grey),
            filled: true, fillColor: isDark ? slate700.withOpacity(0.3) : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? slate700 : slate200)),
          ),
        ),
      ],
    );
  }
}