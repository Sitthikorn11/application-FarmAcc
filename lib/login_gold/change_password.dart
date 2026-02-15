import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:application_farmacc/login_gold/login.dart'; // import เพื่อกลับไปหน้า Login

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  // สีกำหนดเอง
  static const Color primaryColor = Color(0xFF13ec13);
  static const Color backgroundLight = Color(0xFFf6f8f6);
  static const Color backgroundDark = Color(0xFF102210);
  static const Color surfaceDark = Color(0xFF1C2E1C);
  static const Color borderLight = Color(0xFFdbe6db);
  static const Color borderDark = Color(0xFF2A402A);

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isObscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ✅ ฟังก์ชันอัปเดตรหัสผ่าน
  Future<void> _updatePassword() async {
    // 1. ตรวจสอบความถูกต้อง
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณากรอกรหัสผ่านใหม่')));
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('รหัสผ่านไม่ตรงกัน')));
      return;
    }
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. ส่งคำขอไปเปลี่ยนรหัสที่ Supabase
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordController.text.trim()),
      );

      if (mounted) {
        // 3. แสดงข้อความสำเร็จ
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).brightness == Brightness.dark ? surfaceDark : Colors.white,
            title: const Text('สำเร็จ!'),
            content: const Text('เปลี่ยนรหัสผ่านเรียบร้อยแล้ว กรุณาเข้าสู่ระบบด้วยรหัสผ่านใหม่'),
            actions: [
              TextButton(
                onPressed: () {
                  // เคลียร์ Stack แล้วกลับไปหน้า Login
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                },
                child: const Text('ตกลง', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
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

    return Scaffold(
      backgroundColor: isDark ? backgroundDark : backgroundLight,
      appBar: AppBar(
        title: const Text('ตั้งรหัสผ่านใหม่'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSansThai(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_reset, size: 60, color: primaryColor),
              ),
              const SizedBox(height: 30),

              // Fields
              _buildLabel("รหัสผ่านใหม่", isDark),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: _inputDecoration(
                  hint: "กรอกรหัสผ่านใหม่",
                  isDark: isDark,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildLabel("ยืนยันรหัสผ่านใหม่", isDark),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _isObscure,
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                decoration: _inputDecoration(
                  hint: "กรอกรหัสผ่านอีกครั้ง",
                  isDark: isDark,
                ),
              ),
              const SizedBox(height: 40),

              // Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'บันทึกรหัสผ่านใหม่',
                          style: GoogleFonts.notoSansThai(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.notoSansThai(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required bool isDark}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: isDark ? const Color(0xFF1e293b).withOpacity(0.5) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? borderDark : borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? borderDark : borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    );
  }
}