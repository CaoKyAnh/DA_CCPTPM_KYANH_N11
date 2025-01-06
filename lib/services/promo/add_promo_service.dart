// lib/services/add_promo_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> addPromotion({
  required String name,
  required String code,
  required String image,
  required double discount,
  required String startDate,
  required String endDate,
}) async {
  final promotion = {
    'name': name,
    'code': code,
    'startDate': startDate,
    'endDate': endDate,
    'image': image,
    'isHide': false, // Default value
    'discount': discount,
  };

  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/api/promotion'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(promotion),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true; // Successfully added promotion
    } else {
      print('Error adding promotion: ${response.body}');
      return false;
    }
  } catch (error) {
    print('Error calling API: $error');
    return false;
  }
}
