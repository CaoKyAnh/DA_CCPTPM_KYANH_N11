// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously, unused_element

import 'package:final_project_rent_moto_fe/widgets/notification/error_notification.dart';
import 'package:final_project_rent_moto_fe/widgets/notification/success_notification.dart';
import 'package:flutter/material.dart';
import 'package:final_project_rent_moto_fe/screens/categoryMoto/list_category_screen.dart';
import 'package:final_project_rent_moto_fe/services/categoryMoto/add_category_service.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  final bool _isHide = false;
  final AddCategoryService _service = AddCategoryService();

  Future<void> _addCategoryMoto() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      bool success = await _service.addCategoryMoto(_name, _isHide);

      if (success) {
        const SuccessNotification(text: "Category moto added!").buildSnackBar();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ListCategoryScreen()),
        ); // Optionally navigate back after adding
      } else {
        const ErrorNotification(text: "Failed to add company moto.!")
            .buildSnackBar();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Category Moto',
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () {
            // Navigate to CompanyMotoListPage when back icon is pressed
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const ListCategoryScreen()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a Category name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _name = value!;
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: _addCategoryMoto,
                    child: const Text(
                      'Add Category Moto',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
