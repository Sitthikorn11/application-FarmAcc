import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:application_farmacc/services/supabase_service.dart';
import 'package:application_farmacc/login_gold/login.dart';
import 'package:application_farmacc/editprofile/edit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _service = SupabaseService();
  bool _isLoading = true;
  
  Map<String, dynamic>? _userProfile;
  String? _email;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // ✅ 1. ดึงข้อมูล: แยก Email จาก Auth และ Profile จาก Database
  Future<void> _fetchUserProfile() async {
    setState(() => _isLoading = true);
    try {
      // ดึง User Auth (เพื่อเอาอีเมลที่ถูกต้องที่สุด)
      final user = _service.client.auth.currentUser;
      
      // ดึงข้อมูล Profile จากตาราง public.profiles
      final profile = await _service.getUserProfile();
      
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _email = user?.email; // ใช้อีเมลจาก Auth เสมอ
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ✅ 2. อัปเดตรูป: อัปโหลดและรีโหลดหน้าจอ (แก้ไขแล้ว)
  Future<void> _updateAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    
    if (pickedFile != null) {
      setState(() => _isLoading = true);
      try {
        // ✅ แก้ไข: ส่ง pickedFile (XFile) ไปตรงๆ ไม่ต้องแปลงเป็น File
        await _service.updateProfile(imageFile: pickedFile);
        
        await _fetchUserProfile(); // รีโหลดข้อมูลใหม่หลังอัปรูป
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('อัปเดตรูปโปรไฟล์เรียบร้อย'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // ✅ 3. ออกจากระบบ
  Future<void> _handleLogout() async {
    await _service.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Custom Color Palette
    const Color primaryColor = Color(0xFF13ec13);
    final Color backgroundLight = const Color(0xFFf6f8f6);
    final Color backgroundDark = const Color(0xFF102210);
    final Color surfaceLight = Colors.white;
    final Color surfaceDark = const Color(0xFF1a2e1a);

    final Color textMain = isDark ? Colors.white : const Color(0xFF111811);
    final Color textSecondary = isDark ? Colors.grey[400]! : const Color(0xFF4e654e);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? backgroundDark : backgroundLight,
        body: const Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? backgroundDark : backgroundLight,
      appBar: AppBar(
        backgroundColor: (isDark ? backgroundDark : backgroundLight).withOpacity(0.9),
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textMain, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ข้อมูลส่วนตัว',
          style: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // ✅ ไปหน้าแก้ไข และรอให้กลับมา (await)
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfilePage()),
              );
              // ✅ รีโหลดข้อมูลเมื่อกลับมาจากหน้าแก้ไข
              _fetchUserProfile(); 
            },
            child: const Text(
              'แก้ไข',
              style: TextStyle(color: Color(0xFF108510), fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Profile Header ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark ? surfaceDark : surfaceLight,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _userProfile?['avatar_url'] != null
                              ? NetworkImage(_userProfile!['avatar_url'])
                              : null,
                          child: _userProfile?['avatar_url'] == null
                              ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _updateAvatar,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? backgroundDark : backgroundLight,
                                width: 4,
                              ),
                            ),
                            child: const Icon(Icons.photo_camera, size: 20, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // ชื่อ
                  Text(
                    _userProfile?['full_name'] ?? 'ผู้ใช้งาน',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textMain),
                  ),
                  const SizedBox(height: 4),
                  
                  // อาชีพ (Job) - แสดงเฉพาะถ้ามีข้อมูล
                  if (_userProfile?['job'] != null && _userProfile!['job'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        _userProfile!['job'],
                        style: TextStyle(fontSize: 16, color: primaryColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                    
                  // อีเมล
                  Text(
                    _email ?? '-',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textSecondary),
                  ),
                ],
              ),
            ),

            // --- Section: Contact Info ---
            _buildSectionTitle('ข้อมูลติดต่อ', textMain),
            _buildInfoCard(isDark, surfaceLight, surfaceDark, [
              _buildInfoItem(Icons.mail, 'อีเมล', _email ?? '-', textMain, textSecondary, isDark),
              _buildInfoItem(Icons.call, 'เบอร์โทรศัพท์', _userProfile?['phone'] ?? '-', textMain, textSecondary, isDark), 
              _buildInfoItem(Icons.location_on_outlined, 'ที่อยู่', _userProfile?['address'] ?? '-', textMain, textSecondary, isDark, isMultiLine: true),
            ]),

            const SizedBox(height: 24),

            // --- Section: Farm Info ---
            _buildSectionTitle('ข้อมูลฟาร์ม', textMain),
            _buildInfoCard(isDark, surfaceLight, surfaceDark, [
              _buildInfoItem(Icons.storefront_outlined, 'ชื่อฟาร์ม', _userProfile?['farm_name'] ?? '-', textMain, textSecondary, isDark),
              _buildInfoItem(Icons.agriculture, 'ประเภท', _userProfile?['farm_type'] ?? '-', textMain, textSecondary, isDark),
              _buildInfoItem(Icons.square_foot, 'ขนาดพื้นที่', _userProfile?['farm_size'] ?? '-', textMain, textSecondary, isDark, isLast: true),
            ]),

            // --- Logout Button ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _handleLogout,
                  style: TextButton.styleFrom(
                    backgroundColor: isDark ? Colors.red[950]!.withOpacity(0.2) : const Color(0xFFFEF2F2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark ? Colors.red[900]!.withOpacity(0.5) : const Color(0xFFFEE2E2),
                      ),
                    ),
                  ),
                  child: const Text(
                    'ออกจากระบบ',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark, Color light, Color dark, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? dark : light,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoItem(
    IconData icon, String label, String value, Color mainColor, Color secColor, bool isDark, {
    bool isMultiLine = false, bool isLast = false, String? trailingBadge
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05))),
      ),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF13ec13).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF108510)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13, color: secColor, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '-' : value, // ถ้าว่างให้โชว์ -
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: mainColor), 
                  softWrap: true
                ),
              ],
            ),
          ),
          if (trailingBadge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.green[900] : const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(trailingBadge, style: const TextStyle(color: Color(0xFF166534), fontSize: 10, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}