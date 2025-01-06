// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class MomoService {
  // Phương thức này gọi API backend để lấy deeplink và trả về orderId
  Future<String?> initiateMoMoPayment({
    required String amount,
  }) async {
    const String apiUrl =
        'http://10.0.2.2:3000/api/payWithMoMo'; // API URL của bạn
    final Map<String, String> headers = {'Content-Type': 'application/json'};

    // Dữ liệu cần gửi đến backend
    final Map<String, dynamic> body = {
      "amount": amount, // Số tiền cần thanh toán
    };

    try {
      // Gửi yêu cầu POST đến API backend
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(body), // Gửi dữ liệu đến backend
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        print('Payment initialized. deeplink: ${responseBody['qrCodeUrl']}');

        // Lấy deeplink và orderId từ response
        String payUrl = responseBody['qrCodeUrl'];
        String orderId = responseBody['requestId'];

        // Kiểm tra và mở deeplink trong trình duyệt
        final Uri uri = Uri.parse(payUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          print('Không thể mở deeplink: $payUrl');
        }

        // Trả về orderId để kiểm tra trạng thái giao dịch
        return orderId;
      } else {
        final responseBody = json.decode(response.body);
        print('Lỗi khi khởi tạo thanh toán: ${responseBody['message']}');
        return null;
      }
    } catch (e) {
      print('Lỗi: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkTransactionStatus(
      {required String orderId}) async {
    const String apiUrl = 'http://10.0.2.2:3000/api/check-status-transaction';
    final Map<String, String> headers = {'Content-Type': 'application/json'};

    final Map<String, dynamic> body = {
      "orderId": orderId,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body); // Return the response if successful
      } else {
        return null; // Return null if the response is not successful
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
