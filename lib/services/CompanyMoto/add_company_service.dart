// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';

class AddCompanyService {
  final String baseUrl = 'http://10.0.2.2:3000/api/companyMoto';
// Use this if running on a real device

  Future<bool> addCompanyMoto(String name, bool isHide) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'name': name,
          'isHide': isHide,
        }),
      );

      return response.statusCode == 201;
    } catch (error) {
      print("Error adding company motto: $error");
      return false;
    }
  }
}
