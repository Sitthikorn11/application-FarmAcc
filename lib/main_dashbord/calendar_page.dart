import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:application_farmacc/services/supabase_service.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final _service = SupabaseService();
  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  // ตัวแปรเก็บข้อมูลกิจกรรม (Key: วันที่, Value: รายการกิจกรรม)
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchEvents();
  }

  // ดึงข้อมูลจาก Supabase แล้วจัดกลุ่มตามวันที่
  Future<void> _fetchEvents() async {
    final data = await _service.getCalendarEvents();
    
    Map<DateTime, List<Map<String, dynamic>>> groupedEvents = {};

    for (var event in data) {
      // แปลง String วันที่กลับเป็น DateTime (ตัดเวลาทิ้งเอาแต่วัน)
      DateTime date = DateTime.parse(event['event_date']);
      DateTime dateKey = DateTime(date.year, date.month, date.day);

      if (groupedEvents[dateKey] == null) {
        groupedEvents[dateKey] = [];
      }
      groupedEvents[dateKey]!.add(event);
    }

    if (mounted) {
      setState(() {
        _events = groupedEvents;
        _isLoading = false;
      });
    }
  }

  // ฟังก์ชันดึงรายการของวันนั้นๆ
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    // Normalise date (ตัดเวลาทิ้ง) เพื่อให้ map key ตรงกัน
    DateTime dateKey = DateTime(day.year, day.month, day.day);
    return _events[dateKey] ?? [];
  }

  // ฟังก์ชันเพิ่มกิจกรรม
  void _showAddEventDialog() {
    final titleController = TextEditingController();
    String selectedType = 'general'; // general, planting, harvest, care

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มกิจกรรมใหม่'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'ชื่อกิจกรรม (เช่น ใส่ปุ๋ย)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(labelText: 'ประเภท', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'general', child: Text('ทั่วไป 📌')),
                DropdownMenuItem(value: 'planting', child: Text('เพาะปลูก 🌱')),
                DropdownMenuItem(value: 'care', child: Text('ดูแลรักษา 💧')),
                DropdownMenuItem(value: 'harvest', child: Text('เก็บเกี่ยว 🌾')),
              ],
              onChanged: (val) => selectedType = val!,
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ยกเลิก')),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isEmpty) return;
              
              await _service.addCalendarEvent(
                title: titleController.text,
                date: _selectedDay!,
                eventType: selectedType,
              );
              
              Navigator.pop(context);
              _fetchEvents(); // รีโหลดข้อมูล
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันลบ
  void _deleteEvent(int id) async {
    await _service.deleteCalendarEvent(id);
    _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ปฏิทินการเกษตร'),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // 1. ตัวปฏิทิน
              TableCalendar(
                locale: 'th_TH', // ภาษาไทย
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                
                // รูปแบบการเลือกวัน
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                
                // โหลดจุดสีๆ (Event Marker)
                eventLoader: _getEventsForDay,
                
                // ปรับแต่งหน้าตา
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  markerDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                ),
                headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                
                onFormatChanged: (format) {
                  if (_calendarFormat != format) setState(() => _calendarFormat = format);
                },
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              ),
              
              const SizedBox(height: 8.0),
              const Divider(),
              
              // 2. รายการกิจกรรมของวันที่เลือก
              Expanded(
                child: ListView(
                  children: _getEventsForDay(_selectedDay!).map((event) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: ListTile(
                        leading: _buildEventIcon(event['event_type']),
                        title: Text(event['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormat('dd MMM yyyy', 'th').format(DateTime.parse(event['event_date']))),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteEvent(event['id']),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ไอคอนสวยๆ ตามประเภท
  Widget _buildEventIcon(String type) {
    switch (type) {
      case 'planting': return const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.eco, color: Colors.white));
      case 'harvest': return const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons. agriculture, color: Colors.white));
      case 'care': return const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.water_drop, color: Colors.white));
      default: return const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.push_pin, color: Colors.white));
    }
  }
}