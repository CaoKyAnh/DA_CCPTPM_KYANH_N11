import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> editPromoByCompany({
  required String promoId, // ID of the promo you want to edit
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
    // Make the HTTP PUT request to edit the promotion by ID
    final response = await http.put(
      Uri.parse(
          'http://10.0.2.2:3000/api/promoByCompany/promo/$promoId'), // Use promoId in the URL
      headers: {
        'Content-Type': 'application/json', // Set the content type to JSON
      },
      body: jsonEncode(promoData), // Send the promotion data as JSON
    );

    // Check if the request was successful
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true; // Successfully edited the promotion
    } else {
      print('Error editing promotion: ${response.body}');
      return false; // Something went wrong, return false
    }
  } catch (error) {
    // Handle any errors during the API call
    print('Error calling API: $error');
    return false; // Return false if there was an error
  }
}
