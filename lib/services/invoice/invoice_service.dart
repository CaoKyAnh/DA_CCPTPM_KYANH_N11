import 'dart:convert';
import 'package:http/http.dart' as http;

// Define the URL for your backend API
const String apiUrl =
    'http://10.0.2.2:3000/api/invoices'; // Replace with your actual server URL

class InvoiceService {
  static Future<String> addInvoice(String bookingId, String totalAmount,
      String motorbikeRentalDeposit, String email) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'bookingId': bookingId,
          'totalAmount': totalAmount,
          'motorbikeRentalDeposit': motorbikeRentalDeposit,
          'email': email
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['invoiceId']; // Return the invoiceId
      } else {
        throw Exception('Failed to add invoice');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getInvoicesByEmail(String email) async {
    try {
      // Construct the URL with the email parameter
      final response = await http.get(Uri.parse('$apiUrl?email=$email'));

      // Check if the response status code is 200 (OK)
      if (response.statusCode == 200) {
        // Parse the response body as JSON
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Check if the response contains invoices
        if (data['invoices'] != null) {
          // Return the list of invoices
          return List<Map<String, dynamic>>.from(data['invoices']);
        } else {
          throw Exception('No invoices found for this email');
        }
      } else {
        throw Exception('Failed to load invoices');
      }
    } catch (error) {
      // Handle any errors that occur during the HTTP request
      throw Exception('Error fetching invoices: $error');
    }
  }
}
