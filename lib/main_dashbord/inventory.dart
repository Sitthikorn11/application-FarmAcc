import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: InventoryPage(),
  ));
}

// 1. สร้าง Model สำหรับเก็บข้อมูลสินค้า (เพื่อรักษารายละเอียดสินค้าแต่ละตัว)
class InventoryItemData {
  final String title;
  final String subtitle;
  final String amount;
  final String location;
  final String category; // เพิ่มหมวดหมู่เพื่อใช้กรอง
  final bool isWarning;

  InventoryItemData({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.location,
    required this.category,
    this.isWarning = false,
  });
}

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  static const Color primaryColor = Color(0xFF13ec13);
  static const Color backgroundGrey = Color(0xFFf6f8f6);
  static const Color textMain = Color(0xFF111811);

  // 2. ตัวแปรเก็บหมวดหมู่ที่กำลังเลือก (Default: ทั้งหมด)
  String _selectedCategory = 'ทั้งหมด';

  // 3. ข้อมูลสินค้าทั้งหมด (รักษารายละเอียดเดิมของคุณไว้ทั้งหมด)
  final List<InventoryItemData> _allItems = [
    InventoryItemData(title: 'เมล็ดมะเขือเทศ', subtitle: 'พันธุ์ผสม', amount: '50 ซอง', location: 'โรงเก็บ A', category: 'เมล็ดพันธุ์'),
    InventoryItemData(title: 'ปุ๋ย NPK', subtitle: 'ใกล้หมด', amount: '3 กระสอบ', location: 'ยุ้งฉาง 1', category: 'ปุ๋ย', isWarning: true),
    InventoryItemData(title: 'น้ำมันเครื่องรถไถ', subtitle: 'หล่อลื่น', amount: '5 ลิตร', location: 'โรงรถ', category: 'อื่นๆ'),
    InventoryItemData(title: 'จอบขุดดิน', subtitle: 'งานหนัก', amount: '4 เล่ม', location: 'โรงเก็บ B', category: 'อื่นๆ'),
    InventoryItemData(title: 'อาหารไก่ไข่', subtitle: 'กระสอบใหญ่', amount: '20 กระสอบ', location: 'ยุ้งฉาง 2', category: 'อาหารสัตว์'),
  ];

  @override
  Widget build(BuildContext context) {
    // 4. ตรรกะการกรองข้อมูล: ถ้าเลือก 'ทั้งหมด' ให้โชว์หมด ถ้าไม่ใช่ให้โชว์ตามหมวดหมู่
    List<InventoryItemData> filteredItems = _selectedCategory == 'ทั้งหมด'
        ? _allItems
        : _allItems.where((item) => item.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryChips(), // ส่วนกดเลือกประเภท
            Expanded(
              child: _buildInventoryList(filteredItems), // ส่งข้อมูลที่กรองแล้วไปแสดง
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'การจัดการสินค้าคงคลัง',
            style: GoogleFonts.prompt(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['ทั้งหมด', 'เมล็ดพันธุ์', 'ปุ๋ย', 'อาหารสัตว์', 'อื่นๆ'];
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          // ตรวจสอบว่าปุ่มไหนกำลังถูกเลือก
          bool isSelected = _selectedCategory == categories[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(categories[index]),
              selected: isSelected,
              onSelected: (val) {
                // อัปเดตสถานะเมื่อมีการกดเลือกหมวดหมู่
                setState(() {
                  _selectedCategory = categories[index];
                });
              },
              labelStyle: GoogleFonts.prompt(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              selectedColor: const Color(0xFF1c2635),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade200),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInventoryList(List<InventoryItemData> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('สินค้าในคลัง ($_selectedCategory)', style: GoogleFonts.prompt(fontWeight: FontWeight.bold)),
                Text('${items.length} รายการ', style: GoogleFonts.prompt(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  // Table Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text('สินค้า', style: GoogleFonts.prompt(color: Colors.grey, fontSize: 12))),
                        Expanded(flex: 2, child: Center(child: Text('ปริมาณ', style: GoogleFonts.prompt(color: Colors.grey, fontSize: 12)))),
                        Expanded(flex: 2, child: Text('สถานที่', textAlign: TextAlign.right, style: GoogleFonts.prompt(color: Colors.grey, fontSize: 12))),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Table Items (สร้างรายการแบบ Dynamic จากข้อมูลที่กรองมา)
                  Expanded(
                    child: items.isEmpty 
                    ? Center(child: Text('ไม่พบรายการ', style: GoogleFonts.prompt(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _buildInventoryRow(item);
                        },
                      ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // แยก Widget สำหรับแถวข้อมูลเพื่อให้โค้ดอ่านง่ายและไม่ตัดเนื้อหา
  Widget _buildInventoryRow(InventoryItemData item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade50)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 20),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: GoogleFonts.prompt(fontSize: 13, fontWeight: FontWeight.bold)),
                      Text(item.subtitle, style: GoogleFonts.prompt(fontSize: 10, color: item.isWarning ? Colors.orange : Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.isWarning ? Colors.orange.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.amount,
                  style: GoogleFonts.prompt(
                    color: item.isWarning ? Colors.orange : Colors.green, 
                    fontSize: 11, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.location,
              textAlign: TextAlign.right,
              style: GoogleFonts.prompt(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}