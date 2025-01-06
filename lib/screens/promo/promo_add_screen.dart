// lib/screens/promo_add_screen.dart

import 'package:final_project_rent_moto_fe/services/promo/add_promo_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart'; // For handling file paths
import 'package:firebase_storage/firebase_storage.dart';

class PromoAddScreen extends StatefulWidget {
  const PromoAddScreen({super.key});

  @override
  State<PromoAddScreen> createState() => _PromoAddScreenState();
}

class _PromoAddScreenState extends State<PromoAddScreen> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _discountController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  late DateTime selectedStartDate = DateTime.now();
  late DateTime selectedEndDate = DateTime.now().add(Duration(days: 1));

  File? _imageFile;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _imageUrlController.dispose();
    _discountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime initialDate =
        isStartDate ? selectedStartDate : selectedEndDate;
    final DateTime firstDate = DateTime.now();
    final DateTime lastDate = isStartDate
        ? DateTime(2100)
        : selectedStartDate.add(Duration(days: 365));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          selectedStartDate = picked;
          _startDateController.text =
              "${selectedStartDate.day}/${selectedStartDate.month}/${selectedStartDate.year}";
        } else {
          selectedEndDate = picked;
          _endDateController.text =
              "${selectedEndDate.day}/${selectedEndDate.month}/${selectedEndDate.year}";
        }
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = basename(file.path); // Get the file name

      try {
        // Upload the image to Firebase Storage
        final storageRef =
            FirebaseStorage.instance.ref().child('promotions/$fileName');
        final uploadTask = storageRef.putFile(file);
        final snapshot = await uploadTask.whenComplete(() {});

        final downloadUrl =
            await snapshot.ref.getDownloadURL(); // Get the download URL

        setState(() {
          _imageFile = file;
          _imageUrlController.text = downloadUrl; // Store the Firebase URL
        });
      } catch (error) {
        print('Error uploading image: $error');
      }
    }
  }

  Future<void> _addPromotion(BuildContext context) async {
    final name = _nameController.text;
    final code = _codeController.text;
    final image = _imageUrlController.text;
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final startDate = selectedStartDate.toIso8601String();
    final endDate = selectedEndDate.toIso8601String();

    final success = await addPromotion(
      name: name,
      code: code,
      image: image,
      discount: discount,
      startDate: startDate,
      endDate: endDate,
    );

    if (success) {
      // Navigate back if promotion was added successfully
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      print('Failed to add promotion.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Khuyến Mãi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Tên Khuyến Mãi'),
              ),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Mã Khuyến Mãi'),
              ),
              GestureDetector(
                onTap: _pickImage,
                child: AbsorbPointer(
                  child: TextField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(labelText: 'Ảnh URL'),
                  ),
                ),
              ),
              if (_imageFile != null)
                Image.file(
                  _imageFile!,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                ),
              TextField(
                controller: _discountController,
                decoration: const InputDecoration(labelText: 'Giảm Giá (%)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _startDateController,
                decoration: const InputDecoration(labelText: 'Ngày Bắt Đầu'),
                readOnly: true,
                onTap: () => _selectDate(context, true),
              ),
              TextField(
                controller: _endDateController,
                decoration: const InputDecoration(labelText: 'Ngày Kết Thúc'),
                readOnly: true,
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _addPromotion(context);
                },
                child: const Text('Thêm Khuyến Mãi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
