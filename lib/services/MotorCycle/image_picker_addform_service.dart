// ignore_for_file: avoid_print

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerAddformService {
  final ImagePicker imagePicker = ImagePicker();

  Future<List<XFile>> pickImages() async {
    try {
      final List<XFile> selectedImages = await imagePicker.pickMultiImage();
      return selectedImages ?? [];
    } catch (error) {
      print("Error picking images: $error");
      return [];
    }
  }

  Future<List<String>> uploadImagesToFirebase(List<XFile> images) async {
    List<String> downloadUrls = [];

    for (var image in images) {
      try {
        File file = File(image.path);
        print("Uploading image from path: ${image.path}");

        // Generate a unique file name with a timestamp
        String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference ref =
            FirebaseStorage.instance.ref().child('motorcycle_images/$fileName');

        // Upload the file to Firebase Storage
        await ref.putFile(file);

        // Retrieve and store the download URL
        String downloadUrl = await ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
        print("Uploaded image URL: $downloadUrl");
      } catch (error) {
        print("Error uploading image: $error");
      }
    }

    return downloadUrls;
  }
}
