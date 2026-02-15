import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ✅ import Supabase

// ✅ import หน้า Dashboard และ Main เพื่อเชื่อมโยง
import 'package:application_farmacc/main_dashbord/main.dart';

void main() {
  runApp(
    const MaterialApp(
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
  bool _isLoading = false; // ✅ ตัวแปรสถานะโหลด

  // ✅ Controllers รับค่า
  final _usernameController = TextEditingController(); // ชื่อผู้ใช้ (Full Name)
  final _emailController = TextEditingController();    // อีเมล (Supabase บังคับใช้)
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Theme Colors
  final Color slate900 = const Color(0xFF0f172a);
  final Color slate500 = const Color(0xFF64748b);
  final Color slate200 = const Color(0xFFe2e8f0);
  final Color slate700 = const Color(0xFF334155);

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ✅ ฟังก์ชันสมัครสมาชิก
  Future<void> _handleRegister() async {
    // 1. ตรวจสอบข้อมูลเบื้องต้น
    if (_usernameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รหัสผ่านไม่ตรงกัน')),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. ส่งข้อมูลไป Supabase
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {'full_name': _usernameController.text.trim()}, // เก็บชื่อผู้ใช้ลง Metadata
      );

      // 3. เช็คผลลัพธ์
      if (mounted) {
        if (res.user != null) {
          // ถ้าปิด Confirm Email ใน Supabase -> ล็อกอินได้เลย -> ไป Dashboard
          if (res.session != null) {
             Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const FarmerDashboard()),
              (route) => false,
            );
          } else {
            // ถ้าเปิด Confirm Email -> แจ้งให้ไปเช็คอีเมล
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('สมัครสมาชิกสำเร็จ'),
                content: const Text('กรุณาตรวจสอบอีเมลของคุณเพื่อยืนยันตัวตนก่อนเข้าสู่ระบบ'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // ปิด Dialog
                      Navigator.pop(context); // กลับไปหน้า Login
                    },
                    child: const Text('ตกลง', style: TextStyle(color: Color(0xFF13ec13))),
                  ),
                ],
              ),
            );
          }
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.message}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color primaryColor = Color(0xFF13ec13);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        iconTheme: IconThemeData(color: isDark ? Colors.white : slate900)
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Illustration Placeholder
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.person_add_alt_1, size: 50, color: primaryColor),
              ),
              const SizedBox(height: 24),
              Text('สร้างบัญชีใหม่', style: GoogleFonts.notoSansThai(fontSize: 28, fontWeight: FontWeight.bold, color: isDark ? Colors.white : slate900)),
              const SizedBox(height: 8),
              Text('เริ่มต้นบันทึกผลผลิตของคุณวันนี้', style: TextStyle(color: isDark ? Colors.grey : slate500, fontSize: 16)),
              const SizedBox(height: 32),

              _buildField("ชื่อผู้ใช้", "กรอกชื่อผู้ใช้ของคุณ", Icons.person_outline, isDark, controller: _usernameController),
              const SizedBox(height: 20),
              
              // ✅ ช่องอีเมล
              _buildField("อีเมล", "example@email.com", Icons.email_outlined, isDark, controller: _emailController),
              const SizedBox(height: 20),

              _buildField("รหัสผ่าน", "••••••••", Icons.lock_outline, isDark, isPassword: true, controller: _passwordController),
              const SizedBox(height: 20),
              _buildField("ยืนยันรหัสผ่าน", "••••••••", Icons.lock_outline, isDark, isPassword: true, controller: _confirmPasswordController),
              
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister, // ✅ เชื่อมฟังก์ชัน
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, 
                    foregroundColor: const Color(0xFF102210), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('ลงทะเบียน', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Widget สร้างช่องกรอกข้อมูล
  Widget _buildField(String label, String hint, IconData icon, bool isDark, {bool isPassword = false, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : slate900)),
        const SizedBox(height: 8),
        TextField(
          controller: controller, // ✅ ใส่ Controller
          obscureText: isPassword && _isObscure,
          style: TextStyle(color: isDark ? Colors.white : slate900),
          decoration: InputDecoration(
            hintText: hint, prefixIcon: Icon(icon, color: Colors.grey),
            filled: true, fillColor: isDark ? const Color(0xFF1e293b).withOpacity(0.5) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? slate700 : slate200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? slate700 : slate200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF13ec13), width: 2)),
            
            // ปุ่มดูรหัสผ่าน
            suffixIcon: isPassword ? IconButton(
              icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
              onPressed: () => setState(() => _isObscure = !_isObscure),
            ) : null,
          ),
        ),
      ],
    );
  }
}