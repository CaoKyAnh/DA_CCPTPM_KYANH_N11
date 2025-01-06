import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> addPromoByCompany({
  required String companyMoto,
  required String promoName,
  required double percentage,
  required String startDate,
  required String endDate,
  required bool isHide,
}) async {
  // Prepare the promotion data
  final promoData = {
    'companyMoto': companyMoto,
    'promoName': promoName,
    'percentage': percentage,
    'startDate': startDate,
    'endDate': endDate,
    'isHide': isHide,
  };

  try {
    // Make the HTTP POST request
    final response = await http.post(
      Uri.parse(
          'http://10.0.2.2:3000/api/promoByCompany/promo'), // Update with your API URL
      headers: {
        'Content-Type': 'application/json', // Set the content type to JSON
      },
      body: jsonEncode(promoData), // Send the promotion data as JSON
    );

    // Check if the request was successful
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true; // Successfully added the promotion
    } else {
      print('Error adding promotion: ${response.body}');
      return false; // Something went wrong, return false
    }
  } catch (error) {
    // Handle any errors during the API call
    print('Error calling API: $error');
    return false; // Return false if there was an error
  }
}
