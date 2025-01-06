// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:final_project_rent_moto_fe/screens/companyMoto/list_company_screen.dart';
import 'package:final_project_rent_moto_fe/services/companyMoto/add_company_service.dart';

class AddCompanyMotoPage extends StatefulWidget {
  const AddCompanyMotoPage({super.key});

  @override
  _AddCompanyMotoPageState createState() => _AddCompanyMotoPageState();
}

class _AddCompanyMotoPageState extends State<AddCompanyMotoPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  final bool _isHide = false;
  final AddCompanyService _service = AddCompanyService();

  Future<void> _addCompanyMotto() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      bool success = await _service.addCompanyMoto(_name, _isHide);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Company motto added!',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ListCompanyScreen()),
        ); // Optionally navigate back after adding
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Failed to add company motto.',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Company Motto',
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
                  builder: (context) => const ListCompanyScreen()),
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
                    labelText: 'Motto Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a motto name';
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
                    onPressed: _addCompanyMotto,
                    child: const Text(
                      'Add Company Moto',
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
