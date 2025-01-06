// lib/screens/company_moto_update.dart

// ignore_for_file: library_private_types_in_public_api

import 'package:final_project_rent_moto_fe/services/companyMoto/update_company_service.dart';
import 'package:flutter/material.dart';

class UpdateCompanyScreen extends StatefulWidget {
  final String id;
  final String currentName;
  final bool currentIsHide;
  final Function(String, String, bool) onUpdate;

  const UpdateCompanyScreen({
    super.key,
    required this.id,
    required this.currentName,
    required this.currentIsHide,
    required this.onUpdate,
  });

  @override
  _UpdateCompanyScreenState createState() => _UpdateCompanyScreenState();
}

class _UpdateCompanyScreenState extends State<UpdateCompanyScreen> {
  late TextEditingController nameController;
  late bool isHide;
  final UpdateCompanyService _updateCompanyService = UpdateCompanyService();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    isHide = widget.currentIsHide; // Initialize the state variable
  }

  @override
  void dispose() {
    nameController
        .dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    try {
      // Call the update service
      await _updateCompanyService.updateCompanyMoto(
          widget.id, nameController.text, isHide);

      // If successful, show a success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Company motto updated successfully!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }

      // Call the onUpdate callback to notify the parent widget
      widget.onUpdate(widget.id, nameController.text, isHide);
      Navigator.of(context).pop(); // Close the dialog after updating
    } catch (e) {
      // Handle any errors and show an error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update: $e',
              style: const TextStyle(fontSize: 16),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Update Company Motto',
        style: TextStyle(color: Colors.blue), // Set the title color to blue
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Motto Name'),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text(
              'Hidden',
              style: TextStyle(color: Colors.blue),
            ),
            value: isHide,
            onChanged: (value) {
              setState(() {
                isHide = value; // Update the state variable
              });
            },
            activeColor: Colors.blue, // Optional: active color customization
            inactiveThumbColor: Colors.grey, // Optional: inactive color
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cancel the dialog
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            backgroundColor:
                Colors.grey[300], // Background color for Cancel button
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Cancel',
            style:
                TextStyle(color: Colors.blue), // Text color for Cancel button
          ),
        ),
        TextButton(
          onPressed: _handleUpdate, // Call the update function
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            backgroundColor: Colors.blue, // Background color for Update button
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Update',
            style:
                TextStyle(color: Colors.white), // Text color for Update button
          ),
        ),
      ],
    );
  }
}
