import 'package:flutter/material.dart';
import 'package:application_farmacc/services/supabase_service.dart';
import 'package:intl/intl.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  final _service = SupabaseService();
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    // อนาคต: สามารถใส่ lat, long จริงๆ จาก GPS เครื่องได้ตรงนี้
    // ตอนนี้ปล่อยว่างไว้ เพื่อให้ API ใช้ค่า Default (กรุงเทพฯ) ไปก่อน
    final data = await _service.getWeather();
    
    if (mounted) {
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    }
  }

  // ฟังก์ชันแปลงชื่อไอคอนจาก API เป็น Icon ของ Flutter
  IconData _getWeatherIcon(String? iconName) {
    switch (iconName) {
      case 'sunny': return Icons.wb_sunny_rounded;
      case 'cloudy': return Icons.cloud_rounded;
      case 'fog': return Icons.foggy;
      case 'rainy_light': return Icons.grain_rounded;
      case 'rainy': 
      case 'rainy_heavy': return Icons.thunderstorm_rounded;
      case 'thunderstorm': return Icons.flash_on_rounded;
      default: return Icons.wb_cloudy_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_weatherData == null || _weatherData!.isEmpty) {
      return const SizedBox.shrink(); // ถ้าโหลดไม่ได้ ให้ซ่อนไปเลย
    }

    // ดึงค่ามาใส่ตัวแปรให้ใช้ง่ายๆ
    final double temp = (_weatherData!['temperature'] ?? 0).toDouble();
    final int humidity = (_weatherData!['humidity'] ?? 0).toInt();
    final double rain = (_weatherData!['rain'] ?? 0).toDouble();
    final String condition = _weatherData!['condition_text'] ?? '-';
    final String iconName = _weatherData!['icon'] ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // ไล่สีพื้นหลังสวยๆ (สีท้องฟ้า)
        gradient: const LinearGradient(
          colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4FACFE).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ส่วนหัว: วันที่และตำแหน่ง
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('EEEE, d MMM', 'th').format(DateTime.now()),
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text("กรุงเทพฯ", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
          const SizedBox(height: 15),

          // ส่วนเนื้อหา: อุณหภูมิ และ ไอคอน
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$temp°",
                    style: const TextStyle(
                      fontSize: 48, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    condition,
                    style: const TextStyle(
                      fontSize: 16, 
                      color: Colors.white, 
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
              Icon(
                _getWeatherIcon(iconName),
                size: 60,
                color: Colors.white.withOpacity(0.9),
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          // ส่วนล่าง: รายละเอียด (ฝน/ความชื้น)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem(Icons.water_drop, "$rain มม.", "ปริมาณฝน"),
                Container(width: 1, height: 25, color: Colors.white.withOpacity(0.3)),
                _buildDetailItem(Icons.water, "$humidity%", "ความชื้น"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 5),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
      ],
    );
  }
}