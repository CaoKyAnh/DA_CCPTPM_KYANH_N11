// services/image_picker_service.dart
// ignore_for_file: avoid_print

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker imagePicker = ImagePicker();

  Future<List<File>> pickImages() async {
    List<File> selectedImages = [];
    try {
      final List<XFile> pickedImages = await imagePicker.pickMultiImage();

      if (pickedImages != null && pickedImages.isNotEmpty) {
        selectedImages = pickedImages.map((e) => File(e.path)).toList();
      }
    } catch (error) {
      print("Error picking images: $error");
    }
    return selectedImages;
  }

  Future<String> uploadImageToFirebase(File image) async {
    try {
      // Create a unique file name for each image
      String fileName =
          "${DateTime.now().millisecondsSinceEpoch}.jpg";

      // Create a reference to Firebase Storage
      Reference storageRef =
          FirebaseStorage.instance.ref().child('motorcycle_images/$fileName');

      // Upload the image to Firebase Storage
      await storageRef.putFile(image);

      // Get the URL of the uploaded image
      String downloadURL = await storageRef.getDownloadURL();

      // Return the download URL
      return downloadURL;
    } catch (e) {
      print("Error uploading image: $e");
      throw Exception("Error uploading image");
    }
  }

  static Widget buildCurrentImages(List<String> imageUrls) {
    if (imageUrls.isEmpty) {
      return Text("No images available");
    } else {
      List<Widget> imageWidgets = [];

      // Iterate through the image URLs in pairs
      for (int i = 0; i < imageUrls.length; i += 2) {
        imageWidgets.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.network(
                imageUrls[i],
                height: 100,
                width: 100,
              ),
              if (i + 1 < imageUrls.length) // Check if there is a second image
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Image.network(
                    imageUrls[i + 1],
                    height: 100,
                    width: 100,
                  ),
                ),
            ],
          ),
        );
      }

      return Column(
        children: imageWidgets,
      );
    }
  }
}
