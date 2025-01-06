// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'dart:convert';

class AddMotorcycleService {
  // Base URL for your motorcycle API endpoint
  final String baseUrl = 'http://10.0.2.2:3000/api/motorcycle';

  Future<bool> addMotorcycle({
    required String numberPlate,
    required String companyMotoName,
    required String categoryName,
    required String nameMoto,
    required double price,
    required String description,
    required String energy,
    required double vehicleMass,
    required List<String> imagesMoto,
    required String email,
    bool isActive = true,
    bool isHide = true,
    required String streetName,
    required String district,
    required String city,
    required String country,
  }) async {
    // Prepare the request body
    final Map<String, dynamic> requestBody = {
      'numberPlate': numberPlate,
      'companyMoto': {'name': companyMotoName},
      'category': {'name': categoryName},
      'informationMoto': {
        'nameMoto': nameMoto,
        'price': price,
        'description': description,
        'energy': energy,
        'vehicleMass': vehicleMass,
        'imagesMoto': imagesMoto,
      },
      'email': email,
      'isActive': isActive,
      'isHide': isHide,
      'address': {
        'streetName': streetName,
        'district': district,
        'city': city,
        'country': country,
      },
    };

    // if (streetName != null &&
    //     district != null &&
    //     city != null &&
    //     country != null) {
    //   requestBody['address'] = {
    //     'streetName': streetName,
    //     'district': district,
    //     'city': city,
    //     'country': country,
    //   };
    // } else {
    //   print('Address fields missing');
    // }

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      // Debugging: Print the response
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print("Error adding motorcycle: $error");
      return false;
    }
  }
}
