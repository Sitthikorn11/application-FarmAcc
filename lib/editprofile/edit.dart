import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:application_farmacc/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _service = SupabaseService();
  bool _isLoading = false;
  String? _avatarUrl;

  // --- Controllers ---
  final _nameController = TextEditingController();
  final _jobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController(); // จะถูกล็อคห้ามแก้
  final _addressController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _farmTypeController = TextEditingController();
  final _farmSizeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
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

  // ✅ 1. โหลดข้อมูล: อีเมลจาก Auth / ข้อมูลอื่นจาก DB
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = _service.client.auth.currentUser;
      final profile = await _service.getUserProfile();
      
      if (mounted) {
        setState(() {
          // 🔒 ล็อคอีเมล: ดึงจาก Auth เท่านั้น
          _emailController.text = user?.email ?? '';

          // ข้อมูลอื่นๆ ดึงจาก Database
          if (profile != null) {
            _nameController.text = profile['full_name'] ?? '';
            _avatarUrl = profile['avatar_url'];
            _jobController.text = profile['job'] ?? '';
            _phoneController.text = profile['phone'] ?? '';
            _addressController.text = profile['address'] ?? '';
            _farmNameController.text = profile['farm_name'] ?? '';
            _farmTypeController.text = profile['farm_type'] ?? '';
            _farmSizeController.text = profile['farm_size'] ?? '';
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ✅ 2. บันทึกข้อมูล: ไม่ส่งอีเมลไปอัปเดต
  Future<void> _saveData() async {
    setState(() => _isLoading = true);
    try {
      await _service.updateProfile(
        fullName: _nameController.text.trim(),
        job: _jobController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        farmName: _farmNameController.text.trim(),
        farmType: _farmTypeController.text.trim(),
        farmSize: _farmSizeController.text.trim(),
        // ❌ ไม่ส่ง email ไปอัปเดต
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // กลับไปหน้า Profile
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ✅ 3. อัปโหลดรูป (แก้ไขแล้ว)
  Future<void> _updatePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    
    if (pickedFile != null) {
      setState(() => _isLoading = true);
      try {
        // ✅ ส่ง pickedFile (XFile) ไปตรงๆ เลย (ไม่ต้องแปลงเป็น File)
        await _service.updateProfile(imageFile: pickedFile);
        
        // โหลดข้อมูลใหม่เพื่ออัปเดตรูป
        final profile = await _service.getUserProfile();
        if (mounted && profile != null) {
          setState(() {
            _avatarUrl = profile['avatar_url'];
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload Error: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color primaryColor = Color(0xFF13ec13);
    final Color textMain = isDark ? Colors.white : const Color(0xFF111811);
    final Color surfaceColor = isDark ? const Color(0xFF1a2e1a) : Colors.white;

    // สีพื้นหลังสำหรับช่อง ReadOnly (สีเทาอ่อนๆ)
    final Color disabledColor = isDark ? Colors.white10 : Colors.grey.shade200;

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
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
          else
            TextButton(
              onPressed: _saveData,
              child: const Text(
                'บันทึก',
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading && _nameController.text.isEmpty
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ส่วนรูปโปรไฟล์ ---
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _avatarUrl != null 
                              ? NetworkImage(_avatarUrl!) 
                              : const NetworkImage('https://via.placeholder.com/150'),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _updatePhoto,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: primaryColor,
                              child: const Icon(Icons.camera_alt, size: 18, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildSectionLabel("ข้อมูลส่วนตัว", isDark),
                  
                  // ✅ ช่องอีเมล (ห้ามแก้ไข)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      controller: _emailController,
                      readOnly: true, // 👈 ล็อคห้ามพิมพ์
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600], fontSize: 15),
                      decoration: InputDecoration(
                        labelText: "อีเมล (แก้ไขไม่ได้)",
                        labelStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
                        filled: true,
                        fillColor: disabledColor, // 👈 พื้นหลังสีเทา แสดงสถานะ Disabled
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.lock_outline, color: isDark ? Colors.grey : Colors.grey[500], size: 20), // ไอคอนแม่กุญแจ
                      ),
                    ),
                  ),

                  _buildEditField("ชื่อ-นามสกุล", _nameController, isDark, surfaceColor),
                  _buildEditField("อาชีพ", _jobController, isDark, surfaceColor),
                  
                  const SizedBox(height: 25),

                  _buildSectionLabel("ข้อมูลติดต่อ", isDark),
                  _buildEditField("เบอร์โทรศัพท์", _phoneController, isDark, surfaceColor, keyboardType: TextInputType.phone),
                  _buildEditField("ที่อยู่", _addressController, isDark, surfaceColor, isMultiLine: true),

                  const SizedBox(height: 25),

                  _buildSectionLabel("ข้อมูลฟาร์ม", isDark),
                  _buildEditField("ชื่อฟาร์ม", _farmNameController, isDark, surfaceColor),
                  _buildEditField("ประเภทฟาร์ม", _farmTypeController, isDark, surfaceColor),
                  _buildEditField("ขนาดพื้นที่", _farmSizeController, isDark, surfaceColor),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

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