import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple/login_gold/login.dart';
import 'package:simple/editprofile/edit.dart';

void main() {
  runApp(MaterialApp(home: ProfilePage()));
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Custom Color Palette ตาม Tailwind Config
    const Color primaryColor = Color(0xFF13ec13);
    final Color backgroundLight = const Color(0xFFf6f8f6);
    final Color backgroundDark = const Color(0xFF102210);
    final Color surfaceLight = Colors.white;
    final Color surfaceDark = const Color(0xFF1a2e1a);

    final Color textMain = isDark ? Colors.white : const Color(0xFF111811);
    final Color textSecondary = isDark
        ? Colors.grey[400]!
        : const Color(0xFF4e654e);

    return Scaffold(
      backgroundColor: isDark ? backgroundDark : backgroundLight,
      appBar: AppBar(
        backgroundColor: (isDark ? backgroundDark : backgroundLight)
            .withOpacity(0.9),
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textMain, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ข้อมูลส่วนตัว',
          style: TextStyle(
            color: textMain,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
  TextButton(
    onPressed: () {
      // ✅ เพิ่มคำสั่งนี้เพื่อเปิดหน้าแก้ไข
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditProfilePage()),
      );
    },
    child: const Text(
      'แก้ไข',
      style: TextStyle(
        color: Color(0xFF108510),
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  ),
  const SizedBox(width: 8),
],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
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
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey,
                          backgroundImage: NetworkImage(
                            'https://via.placeholder.com/150',
                          ), // เปลี่ยนเป็นรูปจริง
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
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
                          child: const Icon(
                            Icons.photo_camera,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'สมชาย ใจดี',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'เกษตรกรสวนผลไม้',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, size: 16, color: textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'เชียงใหม่, ไทย',
                        style: TextStyle(fontSize: 14, color: textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Section: Contact Info
            _buildSectionTitle('ข้อมูลติดต่อ', textMain),
            _buildInfoCard(isDark, surfaceLight, surfaceDark, [
              _buildInfoItem(
                Icons.call,
                'เบอร์โทรศัพท์',
                '081-234-5678',
                textMain,
                textSecondary,
                isDark,
              ),
              _buildInfoItem(
                Icons.mail,
                'อีเมล',
                'somchai@example.com',
                textMain,
                textSecondary,
                isDark,
              ),
              _buildInfoItem(
                Icons.location_on_outlined,
                'ที่อยู่',
                '123 หมู่ 4 ต.แม่เหียะ อ.เมือง จ.เชียงใหม่ 50100',
                textMain,
                textSecondary,
                isDark,
                isMultiLine: true,
              ),
            ]),

            const SizedBox(height: 24),

            // Section: Farm Info
            _buildSectionTitle('ข้อมูลฟาร์ม', textMain),
            _buildInfoCard(isDark, surfaceLight, surfaceDark, [
              _buildInfoItem(
                Icons.storefront_outlined,
                'ชื่อฟาร์ม',
                'สวนลุงสมชาย',
                textMain,
                textSecondary,
                isDark,
              ),
              _buildInfoItem(
                Icons.agriculture,
                'ประเภท',
                'สวนลำไย',
                textMain,
                textSecondary,
                isDark,
                trailingBadge: 'ผลไม้',
              ),
              _buildInfoItem(
                Icons.square_foot,
                'ขนาดพื้นที่',
                '15 ไร่',
                textMain,
                textSecondary,
                isDark,
                isLast: true,
              ),
            ]),

            // Logout Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    // ✅ คำสั่งออกจากระบบและล้างหน้าทั้งหมด
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  },
                  style: TextButton.styleFrom(
                    // 👇 ส่วนของ Style ที่ต้องใส่กลับมาเพื่อให้ปุ่มไม่หาย
                    backgroundColor: isDark
                        ? Colors.red[950]!.withOpacity(0.2)
                        : const Color(0xFFFEF2F2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isDark
                            ? Colors.red[900]!.withOpacity(0.5)
                            : const Color(0xFFFEE2E2),
                      ),
                    ),
                  ),
                  child: const Text(
                    'ออกจากระบบ',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    bool isDark,
    Color light,
    Color dark,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? dark : light,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    Color mainColor,
    Color secColor,
    bool isDark, {
    bool isMultiLine = false,
    bool isLast = false,
    String? trailingBadge,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white10
                      : Colors.black.withOpacity(0.05),
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: isMultiLine
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
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
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: secColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                  softWrap: true,
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
              child: Text(
                trailingBadge,
                style: const TextStyle(
                  color: Color(0xFF166534),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
