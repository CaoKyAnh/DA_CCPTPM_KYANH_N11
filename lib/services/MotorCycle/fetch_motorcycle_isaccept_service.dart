import 'dart:convert';
import 'package:http/http.dart' as http;

class FetchMotorcycleIsacceptService {
  final String apiUrl = 'http://10.0.2.2:3000/api/homepage';

  // Hàm lấy danh sách xe máy từ API
  Future<List<dynamic>> fetchMotorcycle({String? id}) async {
    final url = id != null ? Uri.parse('$apiUrl/$id') : Uri.parse(apiUrl);

    try {
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        // Kiểm tra nếu trả về có chứa danh sách xe máy
        if (data is List) {
          return data;
        } else if (data is Map<String, dynamic> && data['data'] != null) {
          return List.from(data['data']);
        } else {
          throw Exception('Data format error: List of motorcycles not found');
        }
      } else {
        throw Exception('Failed to load motorcycle data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
