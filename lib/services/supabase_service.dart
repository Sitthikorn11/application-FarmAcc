import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p; // ตั้งชื่อเล่นให้ path เพื่อไม่ให้ชนกัน
import 'package:image_picker/image_picker.dart'; // ✅ เพิ่ม: สำหรับ XFile
import 'package:flutter/foundation.dart' show kIsWeb; // ✅ เพิ่ม: สำหรับเช็ค Web

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  // ----------------------------------------------------------------
  // 1. ระบบสมาชิก (Auth) & โปรไฟล์
  // ----------------------------------------------------------------

  Future<AuthResponse> register(String email, String password, String fullName) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<AuthResponse> login(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await client.auth.signOut();
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = client.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle(); 
      return data;
    } catch (e) {
      print('Error fetching profile: $e');
      return null;
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? job,
    String? phone,
    String? address,
    String? farmName,
    String? farmType,
    String? farmSize,
    XFile? imageFile, // ✅ แก้: เปลี่ยนเป็น XFile
  }) async {
    final user = client.auth.currentUser;
    if (user == null) return;

    final updates = <String, dynamic>{
      'id': user.id,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (fullName != null) updates['full_name'] = fullName;
    if (job != null) updates['job'] = job;
    if (phone != null) updates['phone'] = phone;
    if (address != null) updates['address'] = address;
    if (farmName != null) updates['farm_name'] = farmName;
    if (farmType != null) updates['farm_type'] = farmType;
    if (farmSize != null) updates['farm_size'] = farmSize;

    if (imageFile != null) {
      // ✅ เรียกใช้ฟังก์ชันอัปโหลดตัวใหม่ที่รองรับ Web
      final imageUrl = await _uploadImage(imageFile, 'profiles', 'avatars');
      updates['avatar_url'] = imageUrl;
    }

    await client.from('profiles').upsert(updates);
  }

  // ----------------------------------------------------------------
  // 2. ระบบรายรับ-รายจ่าย (Transactions)
  // ----------------------------------------------------------------

  Future<void> addTransaction({
    required String type,
    required double amount,
    required String category,
    String? description,
    XFile? imageFile, // ✅ แก้: เปลี่ยนเป็น XFile
  }) async {
    final user = client.auth.currentUser;
    if (user == null) return;

    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile, 'transaction_slips', 'farm_images');
    }

    await client.from('transactions').insert({
      'user_id': user.id,
      'type': type,
      'amount': amount,
      'category': category,
      'description': description,
      'image_url': imageUrl,
      'transaction_date': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getTransactions({
    DateTime? startDate, 
    DateTime? endDate
  }) async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    dynamic query = client
        .from('transactions')
        .select()
        .eq('user_id', user.id);

    if (startDate != null && endDate != null) {
      query = query
          .gte('transaction_date', startDate.toIso8601String())
          .lte('transaction_date', endDate.toIso8601String());
    }

    return await query.order('transaction_date', ascending: false);
  }

  // ----------------------------------------------------------------
  // 3. ระบบคลังของ (Inventory)
  // ----------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getInventory() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    return await client
        .from('inventory')
        .select()
        .eq('user_id', user.id)
        .order('item_name', ascending: true);
  }

  Future<void> addInventoryItem({
    required String itemName,
    required String category,
    required double quantity,
    required String unit,
    XFile? imageFile, // ✅ แก้: เปลี่ยนเป็น XFile
  }) async {
    final user = client.auth.currentUser;
    if (user == null) return;

    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile, 'inventory_items', 'farm_images');
    }

    await client.from('inventory').insert({
      'user_id': user.id,
      'item_name': itemName,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'image_url': imageUrl,
    });
  }

  Future<void> deleteInventoryItem(int id) async {
    await client.from('inventory').delete().eq('id', id);
  }

  // ----------------------------------------------------------------
  // 4. ระบบราคากลาง (เรียกผ่าน API Edge Function)
  // ----------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getMarketProducts() async {
    try {
      final response = await Supabase.instance.client.functions.invoke('get-market-prices');
      
      final data = response.data;
      
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching market products from API: $e');
      return [];
    }
  }

  // ----------------------------------------------------------------
  // 5. ระบบพยากรณ์อากาศ (API: get-weather)
  // ----------------------------------------------------------------

  Future<Map<String, dynamic>> getWeather({double? lat, double? long}) async {
    try {
      final body = (lat != null && long != null) ? {'lat': lat, 'long': long} : {};

      final response = await Supabase.instance.client.functions.invoke(
        'get-weather',
        body: body,
      );
      
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      } else {
        return {};
      }
    } catch (e) {
      print('Error fetching weather: $e');
      return {};
    }
  }

  // ----------------------------------------------------------------
  // 6. ระบบปฏิทินกิจกรรม (Calendar Events)
  // ----------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getCalendarEvents() async {
    final user = client.auth.currentUser;
    if (user == null) return [];

    try {
      final data = await client
          .from('calendar_events')
          .select()
          .eq('user_id', user.id)
          .order('event_date', ascending: true); 
          
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

  Future<void> addCalendarEvent({
    required String title,
    required DateTime date,
    String? description,
    String eventType = 'general',
  }) async {
    final user = client.auth.currentUser;
    if (user == null) return;

    await client.from('calendar_events').insert({
      'user_id': user.id,
      'title': title,
      'description': description,
      'event_date': date.toIso8601String(),
      'event_type': eventType,
    });
  }

  Future<void> deleteCalendarEvent(int id) async {
    await client.from('calendar_events').delete().eq('id', id);
  }

  // ----------------------------------------------------------------
  // ✅ ฟังก์ชันอัปโหลดรูป (แก้ไขใหม่ รองรับ Web + Mobile)
  // ----------------------------------------------------------------
  Future<String> _uploadImage(XFile file, String folderName, String bucketName) async {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // หา Extension ไฟล์ (ใช้ name แทน path เพื่อความปลอดภัยบนเว็บ)
    final fileExt = file.name.split('.').last; 
    final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final path = '$folderName/$fileName';

    if (kIsWeb) {
      // 👉 ถ้าเป็นเว็บ: แปลงเป็น Bytes ก่อนส่ง (แก้ Error _Namespace)
      final bytes = await file.readAsBytes();
      await client.storage.from(bucketName).uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: 'image/$fileExt'),
      );
    } else {
      // 👉 ถ้าเป็นมือถือ: ใช้ File path ได้ปกติ
      await client.storage.from(bucketName).upload(
        path,
        File(file.path),
        fileOptions: FileOptions(contentType: 'image/$fileExt'),
      );
    }

    // ดึง URL รูป
    return client.storage.from(bucketName).getPublicUrl(path);
  }
}