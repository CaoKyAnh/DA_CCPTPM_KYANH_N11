// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UpdateMotorcycleService {
  // API endpoint của bạn (Node.js backend)
  final String apiUrl = 'http://10.0.2.2:3000/api/motorcycle';

  // Hàm cập nhật thông tin xe máy
  Future<Map<String, dynamic>> updateMotorcycle(
      String id, Map<String, dynamic> updates) async {
    // Tạo URL với ID của xe máy cần cập nhật
    final url = Uri.parse('$apiUrl/$id');

    try {
      // Gửi yêu cầu PATCH với dữ liệu updates
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updates), // Chuyển đổi updates thành JSON
      );

      // Kiểm tra phản hồi từ server
      if (response.statusCode == 200) {
        // Nếu thành công, trả về dữ liệu đã cập nhật từ server
        return json.decode(response.body);
      } else {
        // Nếu có lỗi, throw exception
        throw Exception('Failed to update motorcycle: ${response.body}');
      }
    } catch (e) {
      // Xử lý lỗi nếu không thể gửi yêu cầu
      throw Exception('Error: $e');
    }
  }

  Future<List<String>> fetchCompanyMotos() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('companyMotos').get();
      return querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (error) {
      print("Error fetching company motos: $error");
      return [];
    }
  }

  // Method to fetch categories from Firestore
  Future<List<String>> fetchCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('categoryMotos').get();
      return querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (error) {
      print("Error fetching categories: $error");
      return [];
    }
  }

  static Widget buildDropdown(
    List<String> items,
    String? selectedItem,
    String labelText,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: DropdownButtonFormField<String>(
            value: selectedItem,
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.teal,
              ),
              prefixIcon: Icon(
                Icons.arrow_drop_down,
                color: Colors.teal,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.teal),
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 12.0),
            ),
            onChanged: onChanged,
            validator: (value) =>
                value == null ? 'Please select a $labelText' : null,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget buildDropdownHide(
    List<String> items,
    String? selectedItem,
    String labelText,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          borderRadius: BorderRadius.circular(10), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 6,
              offset: Offset(0, 2), // Shadow position
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: DropdownButtonFormField<String>(
            value: selectedItem,
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.teal, // Change label color to teal
              ),
              prefixIcon: Icon(
                Icons.arrow_drop_down,
                color: Colors.teal, // Icon color
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.teal), // Border color
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 12.0),
            ),
            onChanged: null,
            validator: (value) =>
                value == null ? 'Please select a $labelText' : null,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
