import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:application_farmacc/services/supabase_service.dart';

class MarketPricePage extends StatefulWidget {
  const MarketPricePage({super.key});

  @override
  State<MarketPricePage> createState() => _MarketPricePageState();
}

class _MarketPricePageState extends State<MarketPricePage> {
  final _service = SupabaseService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _products = [];
  String _selectedCategory = 'ทั้งหมด';

  // สี Theme
  static const Color primaryColor = Color(0xFF13ec13);
  static const Color background = Color(0xFFf6f8f6);

  @override
  void initState() {
    super.initState();
    _fetchMarketData();
  }

  Future<void> _fetchMarketData() async {
    final data = await _service.getMarketProducts();
    if (mounted) {
      setState(() {
        _products = data;
        _isLoading = false;
      });
    }
  }

  // แปลงหมวดหมู่เป็นภาษาไทย
  String _getCategoryName(String key) {
    switch (key) {
      case 'fertilizer': return 'ปุ๋ย';
      case 'seed': return 'เมล็ดพันธุ์';
      case 'chemical': return 'สารเคมี';
      default: return 'อื่นๆ';
    }
  }

  @override
  Widget build(BuildContext context) {
    // กรองข้อมูลตามหมวดหมู่
    final filteredProducts = _selectedCategory == 'ทั้งหมด'
        ? _products
        : _products.where((p) => _getCategoryName(p['category']) == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: Text('เช็คราคากลาง', style: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 1. หมวดหมู่สินค้า (Chips)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['ทั้งหมด', 'ปุ๋ย', 'เมล็ดพันธุ์', 'สารเคมี'].map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (val) => setState(() => _selectedCategory = cat),
                      selectedColor: primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      backgroundColor: Colors.grey[100],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 2. รายการสินค้า (Grid)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryColor))
                : filteredProducts.isEmpty
                    ? Center(child: Text('ไม่พบข้อมูลสินค้า', style: GoogleFonts.prompt(color: Colors.grey)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // แสดง 2 แถว
                          childAspectRatio: 0.75, // สัดส่วนการ์ด (สูงกว่ากว้าง)
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final item = filteredProducts[index];
                          return _buildProductCard(item);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // การ์ดแสดงสินค้า
  Widget _buildProductCard(Map<String, dynamic> item) {
    final formatCurrency = NumberFormat('#,###');
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // รูปภาพ (ถ้าไม่มีใช้รูปไอคอนแทน)
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: item['image_url'] != null && item['image_url'].toString().isNotEmpty
                    ? DecorationImage(image: NetworkImage(item['image_url']), fit: BoxFit.cover)
                    : null,
              ),
              child: item['image_url'] == null || item['image_url'].toString().isEmpty
                  ? Icon(Icons.image_not_supported, color: Colors.grey[400], size: 40)
                  : null,
            ),
          ),
          
          // ข้อมูลสินค้า
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // หมวดหมู่ (Tag)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getCategoryName(item['category']),
                    style: TextStyle(fontSize: 10, color: Colors.green[800], fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                
                // ชื่อสินค้า
                Text(
                  item['name'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.prompt(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
                // ราคา
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '฿${formatCurrency.format(item['price'])}',
                      style: GoogleFonts.prompt(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                    Text(
                      '/${item['unit']}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}