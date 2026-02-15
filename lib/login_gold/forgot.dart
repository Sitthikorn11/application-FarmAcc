import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // สีกำหนดเองตาม Tailwind Config
  static const Color primaryColor = Color(0xFF13ec13);
  static const Color backgroundLight = Color(0xFFf6f8f6);
  static const Color backgroundDark = Color(0xFF102210);
  static const Color surfaceDark = Color(0xFF1C2E1C);
  static const Color borderLight = Color(0xFFdbe6db);
  static const Color borderDark = Color(0xFF2A402A);

  // ตัวแปรรับค่าและสถานะโหลด
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // ✅ ฟังก์ชันส่งอีเมลรีเซ็ตรหัสผ่าน (แก้ไขแล้ว)
  Future<void> _handleResetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกอีเมลที่ใช้ลงทะเบียน')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ✅ ส่งคำขอไปที่ Supabase พร้อมระบุ redirectTo
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailController.text.trim(),
        redirectTo: 'farmacc://reset-callback', // ✅ ใส่บรรทัดนี้สำคัญมาก!
      );

      if (mounted) {
        // แสดง Dialog สำเร็จ
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).brightness == Brightness.dark ? surfaceDark : Colors.white,
            title: Text(
              'ตรวจสอบอีเมลของคุณ',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black
              ),
            ),
            content: Text(
              'เราได้ส่งลิงก์สำหรับตั้งรหัสผ่านใหม่ไปที่ ${_emailController.text} แล้ว\n\nกรุณาตรวจสอบ Inbox หรือ Junk/Spam',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : Colors.black87
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // ปิด Dialog
                  Navigator.pop(context); // กลับไปหน้า Login
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF111811)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Logo Section
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: isDark ? surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? borderDark : borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      color: primaryColor,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Headline
                Text(
                  'ลืมรหัสผ่าน',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF111811),
                  ),
                ),
                const SizedBox(height: 12),

                // Body Text
                Text(
                  'ไม่ต้องกังวล กรุณากรอกอีเมลที่คุณใช้ลงทะเบียน เพื่อรับลิงก์สำหรับตั้งค่ารหัสผ่านใหม่',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 16,
                    color: isDark ? Colors.grey[300] : const Color(0xFF111811).withOpacity(0.8),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 32),

                // Form Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        'อีเมล',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[200] : const Color(0xFF111811),
                        ),
                      ),
                    ),
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'example@mail.com',
                        hintStyle: TextStyle(color: isDark ? const Color(0xFF4A634A) : const Color(0xFF618961).withOpacity(0.6)),
                        prefixIcon: const Icon(Icons.mail_outline, color: Color(0xFF618961)),
                        filled: true,
                        fillColor: isDark ? surfaceDark : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 18),
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
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Primary Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: const Color(0xFF0a1f0a),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: primaryColor.withOpacity(0.3),
                      disabledBackgroundColor: primaryColor.withOpacity(0.5),
                    ),
                    child: _isLoading 
                      ? const SizedBox(
                          width: 24, 
                          height: 24, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : Text(
                          'ส่งลิงก์รีเซ็ตรหัสผ่าน',
                          style: GoogleFonts.notoSansThai(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 40),

                // Footer Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'นึกรหัสผ่านออกแล้ว?',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 16,
                        color: isDark ? Colors.grey[400] : const Color(0xFF111811),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'เข้าสู่ระบบ',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}