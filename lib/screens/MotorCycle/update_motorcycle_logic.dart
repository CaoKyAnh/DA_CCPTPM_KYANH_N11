// update_motorcycle_logic.dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'package:final_project_rent_moto_fe/services/MotorCycle/image_picker_service.dart';
import 'package:final_project_rent_moto_fe/services/MotorCycle/update_motorcycle_service.dart';
import 'package:flutter/material.dart';

Future<void> updateMotorcycleLogic({
  required BuildContext context,
  required String motorcycleId,
  required TextEditingController numberPlateController,
  required TextEditingController nameMotoController,
  required TextEditingController priceController,
  required TextEditingController descriptionController,
  required TextEditingController energyController,
  required TextEditingController vehicleMassController,
  required List<File> selectedImages,
  required List<String> imageUrls,
  required ImagePickerService imagePickerService,
  required String? selectedCompanyMoto,
  required String? selectedCategory,
  required bool isActive,
  required bool isHide,
  required String streetName,
  required String district,
  required String city,
  required String country,
  required String existingStreetName,
  required String existingDistrict,
  required String existingCity,
  required String existingCountry,
}) async {
  List<String> finalImageUrls = [];

  // Handle image upload
  if (selectedImages.isNotEmpty) {
    for (var imageFile in selectedImages) {
      try {
        String imageUrl =
            await imagePickerService.uploadImageToFirebase(imageFile);
        finalImageUrls.add(imageUrl);
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
  } else {
    finalImageUrls = List.from(imageUrls);
  }

  Map<String, dynamic> addressToUpdate = {};
  if (streetName != existingStreetName)
    addressToUpdate['streetName'] = streetName;
  if (district != existingDistrict) addressToUpdate['district'] = district;
  if (city != existingCity) addressToUpdate['city'] = city;
  if (country != existingCountry) addressToUpdate['country'] = country;

  // Prepare updates
  final updates = {
    'numberPlate': numberPlateController.text,
    'companyMoto': {'name': selectedCompanyMoto},
    'category': {'name': selectedCategory},
    'informationMoto': {
      'nameMoto': nameMotoController.text,
      'price': double.tryParse(priceController.text) ?? 0.0,
      'description': descriptionController.text,
      'energy': energyController.text,
      'vehicleMass': double.tryParse(vehicleMassController.text) ?? 0.0,
      'images': finalImageUrls,
    },
    'isActive': isActive,
    'isHide': isHide,
    if (addressToUpdate.isNotEmpty) 'address': addressToUpdate,
  };

  try {
    await UpdateMotorcycleService().updateMotorcycle(motorcycleId, updates);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Motorcycle updated successfully!')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update motorcycle: $e')),
      );
    }
  }
}
