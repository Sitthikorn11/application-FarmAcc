import 'dart:io'; // ใช้สำหรับ File บน Mobile
import 'package:flutter/foundation.dart' show kIsWeb; // ✅ เพิ่มเช็ค Web
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:application_farmacc/services/supabase_service.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: InventoryPage(),
  ));
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

  final _service = SupabaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _inventoryItems = [];
  String _selectedCategory = 'ทั้งหมด';

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  // ✅ ดึงข้อมูล
  Future<void> _fetchInventory() async {
    try {
      final data = await _service.getInventory();
      if (mounted) {
        setState(() {
          _inventoryItems = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print('Error fetching inventory: $e');
    }
  }

  // ✅ ฟังก์ชันลบรายการ (มีแจ้งเตือน)
  Future<void> _confirmDelete(int id) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบสินค้านี้ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              await _service.deleteInventoryItem(id);
              _fetchInventory();
            },
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ✅ ฟังก์ชันเพิ่มรายการ (พร้อมรูปภาพ)
  void _showAddItemModal() {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    String selectedCat = 'fertilizer';
    String selectedUnit = 'กระสอบ';
    
    // ✅ แก้ไข 1: เปลี่ยนจาก File? เป็น XFile?
    XFile? selectedImage; 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder( 
          builder: (BuildContext context, StateSetter setModalState) {
            
            // ฟังก์ชันเลือกรูปใน Modal
            Future<void> pickImage() async {
              final picker = ImagePicker();
              final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
              if (picked != null) {
                setModalState(() {
                  // ✅ แก้ไข 2: เก็บค่า picked (XFile) โดยตรง ไม่ต้องแปลงเป็น File
                  selectedImage = picked; 
                });
              }
            }

            // 🖼️ เตรียม ImageProvider ตาม Platform
            ImageProvider? imageProvider;
            if (selectedImage != null) {
              if (kIsWeb) {
                // ถ้าเป็น Web ใช้ NetworkImage (path ของ XFile บนเว็บคือ Blob URL)
                imageProvider = NetworkImage(selectedImage!.path);
              } else {
                // ถ้าเป็น Mobile ใช้ FileImage ปกติ
                imageProvider = FileImage(File(selectedImage!.path));
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20, right: 20, top: 20
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('เพิ่มสินค้าเข้าคลัง', style: GoogleFonts.prompt(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // ส่วนเลือกรูปภาพ
                  Center(
                    child: GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                          // ✅ แก้ไข 3: ใช้ imageProvider ที่เตรียมไว้
                          image: imageProvider != null 
                            ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                            : null
                        ),
                        child: selectedImage == null 
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, color: Colors.grey),
                                Text('เพิ่มรูป', style: TextStyle(color: Colors.grey, fontSize: 12))
                              ],
                            )
                          : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'ชื่อสินค้า', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: qtyController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'จำนวน', border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedUnit,
                          items: ['กระสอบ', 'ขวด', 'กก.', 'ลิตร', 'ซอง', 'อัน', 'กล่อง'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) => selectedUnit = val!,
                          decoration: const InputDecoration(labelText: 'หน่วย', border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCat,
                    items: const [
                      DropdownMenuItem(value: 'fertilizer', child: Text('ปุ๋ย')),
                      DropdownMenuItem(value: 'seed', child: Text('เมล็ดพันธุ์')),
                      DropdownMenuItem(value: 'chemical', child: Text('สารเคมี/ยา')),
                      DropdownMenuItem(value: 'other', child: Text('อื่นๆ')),
                    ],
                    onChanged: (val) => selectedCat = val!,
                    decoration: const InputDecoration(labelText: 'หมวดหมู่', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                      onPressed: () async {
                        if (nameController.text.isEmpty || qtyController.text.isEmpty) return;
                        Navigator.pop(context);
                        
                        setState(() => _isLoading = true);
                        
                        // บันทึกลง Supabase
                        await _service.addInventoryItem(
                          itemName: nameController.text,
                          category: selectedCat,
                          quantity: double.tryParse(qtyController.text) ?? 0,
                          unit: selectedUnit,
                          imageFile: selectedImage, // ✅ ส่ง XFile ไปได้เลย
                        );
                        _fetchInventory();
                      },
                      child: const Text('บันทึก', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getCategoryName(String key) {
    switch (key) {
      case 'fertilizer': return 'ปุ๋ย';
      case 'seed': return 'เมล็ดพันธุ์';
      case 'chemical': return 'สารเคมี';
      case 'other': return 'อื่นๆ';
      default: return 'ทั่วไป';
    }
  }

  String _getCategoryKey(String label) {
    switch (label) {
      case 'ปุ๋ย': return 'fertilizer';
      case 'เมล็ดพันธุ์': return 'seed';
      case 'สารเคมี': return 'chemical';
      case 'อื่นๆ': return 'other';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredItems = _selectedCategory == 'ทั้งหมด'
        ? _inventoryItems
        : _inventoryItems.where((item) => item['category'] == _getCategoryKey(_selectedCategory)).toList();

    return Scaffold(
      backgroundColor: backgroundGrey,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryChips(),
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: primaryColor)) 
                : _buildInventoryList(filteredItems),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemModal,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.black),
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
            style: GoogleFonts.prompt(fontSize: 22, fontWeight: FontWeight.bold, color: textMain),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['ทั้งหมด', 'เมล็ดพันธุ์', 'ปุ๋ย', 'สารเคมี', 'อื่นๆ'];
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategory == categories[index];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(categories[index]),
              selected: isSelected,
              onSelected: (val) {
                setState(() => _selectedCategory = categories[index]);
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

  Widget _buildInventoryList(List<Map<String, dynamic>> items) {
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text('สินค้า', style: GoogleFonts.prompt(color: Colors.grey, fontSize: 12))),
                        Expanded(flex: 2, child: Center(child: Text('ปริมาณ', style: GoogleFonts.prompt(color: Colors.grey, fontSize: 12)))),
                        Expanded(flex: 1, child: Text('จัดการ', textAlign: TextAlign.right, style: GoogleFonts.prompt(color: Colors.grey, fontSize: 12))),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: items.isEmpty
                    ? Center(child: Text('ไม่พบรายการ', style: GoogleFonts.prompt(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) => _buildInventoryRow(items[index]),
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

  Widget _buildInventoryRow(Map<String, dynamic> item) {
    double qty = (item['quantity'] as num).toDouble();
    bool isWarning = qty < 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade50))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    image: item['image_url'] != null 
                      ? DecorationImage(image: NetworkImage(item['image_url']), fit: BoxFit.cover)
                      : null,
                  ),
                  child: item['image_url'] == null 
                    ? const Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 20)
                    : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['item_name'], style: GoogleFonts.prompt(fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      Text(_getCategoryName(item['category']), style: GoogleFonts.prompt(fontSize: 10, color: isWarning ? Colors.orange : Colors.grey)),
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
                  color: isWarning ? Colors.orange.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$qty ${item['unit']}',
                  style: GoogleFonts.prompt(
                    color: isWarning ? Colors.orange : Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                onPressed: () => _confirmDelete(item['id']),
              ),
            ),
          ),
        ],
      ),
    );
  }
}