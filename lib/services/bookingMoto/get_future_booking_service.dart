import 'dart:convert';
import 'package:http/http.dart' as http;

class GetFutureBookingService {
  Future<List<Map<String, dynamic>>> fetchFutureBookings(
      String numberPlate) async {
    final Uri url = Uri.parse(
        'http://10.0.2.2:3000/api/bookingMoto/emptytime/$numberPlate');

    try {
      // Gửi yêu cầu GET tới API
      final response = await http.get(url);

      // Kiểm tra mã trạng thái HTTP
      if (response.statusCode == 200) {
        // Nếu thành công, phân tích dữ liệu JSON trả về
        try {
          final data = json.decode(response.body);
          if (data['bookings'] != null) {
            // Trả về danh sách booking dưới dạng Map thay vì đối tượng
            List<dynamic> bookingsJson = data['bookings'];
            return List<Map<String, dynamic>>.from(bookingsJson);
          } else {
            // Nếu không có trường 'bookings' trong dữ liệu
            throw Exception('No bookings found in the response');
          }
        } catch (e) {
          // Xử lý lỗi nếu không thể phân tích JSON
          throw Exception('Failed to parse JSON: $e');
        }
      } else {
        // Nếu không thành công, ném lỗi
        throw Exception(
            'Failed to load bookings. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Xử lý các lỗi ngoài việc gửi HTTP request (network errors, timeout, etc.)
      print('Error fetching bookings: $error');
      throw Exception('Error fetching bookings: $error');
    }
  }
}
