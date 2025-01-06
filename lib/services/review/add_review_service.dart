import 'dart:convert';
import 'package:http/http.dart' as http;

class AddReviewService {
  final String baseUrl =
      'http://10.0.2.2:3000/api/review'; // Địa chỉ API của bạn

  // Hàm gọi API để thêm đánh giá
  Future<Map<String, dynamic>> addReview(
      String email, String numberPlate, int numberStars, String comment) async {
    try {
      // Tạo dữ liệu cho request
      final reviewData = {
        'email': email,
        'numberPlate': numberPlate,
        'numberStars': numberStars,
        'comment': comment,
      };

      // Gửi request POST đến API
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(reviewData), // Chuyển dữ liệu thành JSON
      );

      // Kiểm tra phản hồi từ API
      if (response.statusCode == 200) {
        // Nếu thành công, trả về dữ liệu đánh giá
        return json.decode(response.body);
      } else {
        // Nếu có lỗi từ server
        throw Exception(
            'Failed to add review. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error while adding review: $error');
      throw Exception('Could not add review');
    }
  }
}
