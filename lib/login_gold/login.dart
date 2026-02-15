import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ อัปเดต import ให้ตรงกับโครงสร้างไฟล์
import 'package:application_farmacc/main_dashbord/main.dart'; 
import 'package:application_farmacc/login_gold/register.dart';
import 'package:application_farmacc/login_gold/forgot.dart';
// ✅ อย่าลืมสร้างไฟล์นี้ตามที่ผมให้ไปก่อนหน้านี้นะครับ
import 'package:application_farmacc/login_gold/change_password.dart'; 

void main() {
  runApp(const KasetTrackApp());
}

class KasetTrackApp extends StatelessWidget {
  const KasetTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KasetTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF13ec13),
        scaffoldBackgroundColor: const Color(0xFFf6f8f6),
        textTheme: GoogleFonts.notoSansThaiTextTheme(),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF13ec13),
        scaffoldBackgroundColor: const Color(0xFF102210),
        textTheme: GoogleFonts.notoSansThaiTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscure = true;
  bool _isLoading = false; 

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final Color slate900 = const Color(0xFF0f172a);
  final Color slate700 = const Color(0xFF334155);
  final Color slate500 = const Color(0xFF64748b);
  final Color slate400 = const Color(0xFF94a3b8);
  final Color slate200 = const Color(0xFFe2e8f0);

  // ✅✅✅ เพิ่มส่วนนี้: ดักจับลิงก์จากอีเมล ✅✅✅
  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    // ดักฟังเหตุการณ์ Auth
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      
      // ถ้าเป็นเหตุการณ์ "กู้คืนรหัสผ่าน" (Password Recovery)
      if (event == AuthChangeEvent.passwordRecovery) {
        if (mounted) {
          // พาไปหน้าตั้งรหัสผ่านใหม่
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const ChangePasswordPage())
          );
        }
      }
    });
  }
  // ✅✅✅ จบส่วนที่เพิ่ม ✅✅✅

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกอีเมลและรหัสผ่าน')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted && res.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const FarmerDashboard(),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เข้าสู่ระบบไม่สำเร็จ: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 60),

              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(isDark ? 0.1 : 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.agriculture,
                    size: 48,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'ยินดีต้อนรับ',
                style: GoogleFonts.notoSansThai(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : slate900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'จัดการบัญชีฟาร์มของคุณได้ง่ายๆ ที่นี่',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? slate400 : slate500,
                ),
              ),
              const SizedBox(height: 40),

              _buildLabel("อีเมล", isDark),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                style: TextStyle(color: isDark ? Colors.white : slate900),
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(
                  hint: "กรอกอีเมลของคุณ",
                  prefixIcon: Icons.email_outlined,
                  isDark: isDark,
                ),
              ),
              const SizedBox(height: 20),

              _buildLabel("รหัสผ่าน", isDark),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _isObscure,
                style: TextStyle(color: isDark ? Colors.white : slate900),
                decoration: _inputDecoration(
                  hint: "กรอกรหัสผ่าน",
                  prefixIcon: Icons.lock_outline,
                  isDark: isDark,
                ).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility_off : Icons.visibility,
                      color: slate400,
                    ),
                    onPressed: () =>
                        setState(() => _isObscure = !_isObscure),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  child: Text(
                    'ลืมรหัสผ่าน?',
                    style: TextStyle(
                      color: isDark ? slate400 : slate500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: const Color(0xFF102210),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(
                        height: 24, 
                        width: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      )
                    : const Text(
                        'เข้าสู่ระบบ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(color: isDark ? slate700 : slate200),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "หรือ",
                        style: TextStyle(color: slate400, fontSize: 14),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: isDark ? slate700 : slate200),
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isDark ? slate700 : slate200),
                    backgroundColor: isDark
                        ? slate700.withOpacity(0.3)
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'ลงทะเบียนใหม่',
                    style: TextStyle(
                      color: isDark ? Colors.white : slate900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
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
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : slate900,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    required bool isDark,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: slate400),
      prefixIcon: Icon(prefixIcon, color: slate400),
      filled: true,
      fillColor: isDark
          ? const Color(0xFF1e293b).withOpacity(0.5)
          : Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? slate700 : slate200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF13ec13), width: 2),
      ),
    );
  }
}