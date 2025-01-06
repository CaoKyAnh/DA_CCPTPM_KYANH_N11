import 'dart:convert';
import 'package:http/http.dart' as http;

class Getallbookings {
  final String apiUrl = 'http://10.0.2.2:3000/api/bookingMoto';
  Future<List<dynamic>> fetchBookings() async {
    try {
      // Gọi API để lấy danh sách booking
      final response = await http.get(Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'});

      // Kiểm tra mã trạng thái của phản hồi
      if (response.statusCode == 200) {
        // Parse dữ liệu trả về từ API
        var data = json.decode(response.body);

        // Kiểm tra nếu dữ liệu là một danh sách
        if (data is List) {
          return data; // Trả về danh sách booking
        } else if (data is Map<String, dynamic> && data['data'] != null) {
          return List.from(data['data']); // Trả về danh sách từ trường 'data'
        } else {
          throw Exception('Data format error: List of bookings not found');
        }
      } else {
        throw Exception('Failed to load booking data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
