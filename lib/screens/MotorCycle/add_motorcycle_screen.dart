// // ignore_for_file: library_private_types_in_public_api
// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously, unnecessary_nullable_for_final_variable_declarations
import 'dart:io';
import 'package:final_project_rent_moto_fe/services/MotorCycle/image_picker_addform_service.dart';
import 'package:final_project_rent_moto_fe/services/MotorCycle/update_motorcycle_service.dart';
import 'package:final_project_rent_moto_fe/widgets/modals/search_location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_project_rent_moto_fe/services/MotorCycle/add_motorcycle_service.dart';
import 'package:image_picker/image_picker.dart';

class AddMotorcycleScreen extends StatefulWidget {
  const AddMotorcycleScreen({super.key});

  @override
  _AddMotorcycleScreenState createState() => _AddMotorcycleScreenState();
}

class _AddMotorcycleScreenState extends State<AddMotorcycleScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController numberPlateController = TextEditingController();
  final TextEditingController nameMotoController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController energyController = TextEditingController();
  final TextEditingController vehicleMassController = TextEditingController();

  // New controllers for address
  final TextEditingController streetNameController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  String? selectedCompanyMoto;
  String? selectedCategory;
  List<String> companyMotoList = [];
  List<String> categoryList = [];
  List<XFile>? imagesMoto = [];

  final AddMotorcycleService addMotorcycleService = AddMotorcycleService();
  final UpdateMotorcycleService updateMotorcycleService =
      UpdateMotorcycleService();
  final ImagePickerAddformService imagePickerAddformService =
      ImagePickerAddformService();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    companyMotoList = await updateMotorcycleService.fetchCompanyMotos();
    categoryList = await updateMotorcycleService.fetchCategories();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> pickImages() async {
    final selectedImages = await imagePickerAddformService.pickImages();
    if (selectedImages.isNotEmpty) {
      setState(() {
        imagesMoto = selectedImages;
      });
    }
  }

  Future<List<String>> uploadImagesToFirebase(List<XFile> images) async {
    return await imagePickerAddformService.uploadImagesToFirebase(images);
  }

  final TextEditingController locationController = TextEditingController();

  void _selectLocation(BuildContext context) async {
    // Open the SearchLocation widget and await the selected address
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchLocation(),
      ),
    );

    // If the user selected a location, update the locationController and address fields
    if (selectedLocation != null) {
      setState(() {
        locationController.text = selectedLocation;
        print(locationController.text); // Check if it's updated

        // Assuming selectedLocation contains a string with components: "street, district, city, country"
        final addressParts = selectedLocation
            .split(','); // Example: "street, district, city, country"

        if (addressParts.length >= 4) {
          streetNameController.text = addressParts[0].trim();
          districtController.text = addressParts[1].trim();
          cityController.text = addressParts[2].trim();
          countryController.text = addressParts[3].trim();
        } else {
          print('Error: Selected location does not contain expected parts.');
        }
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      final String email = currentUser?.email ?? '';

      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email is required to submit form.')),
        );
        return;
      }

      // Get values from the form
      final String numberPlate = numberPlateController.text;
      final String companyMotoName = selectedCompanyMoto!;
      final String categoryName = selectedCategory!;
      final String nameMoto = nameMotoController.text;
      final double price = double.tryParse(priceController.text) ?? 0.0;
      final String description = descriptionController.text;
      final String energy = energyController.text;
      final double vehicleMass =
          double.tryParse(vehicleMassController.text) ?? 0.0;

      // Get address data
      final String streetName = streetNameController.text;
      final String district = districtController.text;
      final String city = cityController.text;
      final String country = countryController.text;

      // Upload images and obtain their URLs
      List<String> imageUrls = await uploadImagesToFirebase(imagesMoto!);
      print("Uploaded image URLs: $imageUrls");

      // Try adding the motorcycle using the service
      try {
        bool success = await addMotorcycleService.addMotorcycle(
          numberPlate: numberPlate,
          companyMotoName: companyMotoName,
          categoryName: categoryName,
          nameMoto: nameMoto,
          price: price,
          description: description,
          energy: energy,
          vehicleMass: vehicleMass,
          imagesMoto: imageUrls,
          email: email,
          streetName: streetName,
          district: district,
          city: city,
          country: country,
          // Pass email to addMotorcycle
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Motorcycle added successfully!')),
          );
          _formKey.currentState!.reset();
          setState(() {
            imagesMoto = [];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add motorcycle.')),
          );
        }
      } catch (error) {
        print("Error in submitting form: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error submitting motorcycle data.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String email = currentUser?.email ?? '';
    // Corrected access to email here
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Đăng xe',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 239, 125, 63),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: email,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(
                          255, 255, 178, 71), // Change the label text color
                      fontWeight: FontWeight.bold, // Make the label bold
                    ),
                    hintText: 'Email sẽ được hiển thị ở đây',
                    hintStyle: TextStyle(
                        color:
                            Colors.grey), // Hint style for better readability
                    filled: true, // Add a background color to the field
                    fillColor: Colors.grey[200], // Light grey background
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 255, 217, 196),
                          width: 1.5), // Border color when not focused
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(255, 165, 246, 252),
                          width: 2), // Border color when focused
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.black, // Text color
                    fontSize: 16, // Adjust font size for better readability
                  ),
                  readOnly:
                      true, // Make the field read-only so users cannot edit the email
                ),

                TextFormField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Địa điểm',
                    hintText: 'Hãy nhập địa điểm của bạn',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  readOnly: true,
                  onTap: () =>
                      _selectLocation(context), // Open the location picker
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập địa điểm.';
                    }
                    return null;
                  },
                ),
                // Other address fields

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.grey[200],
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Thông tin xe",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 181, 69),
                          ),
                        ),
                        const Divider(
                          color: Color.fromARGB(
                              255, 106, 79, 40), // Chỉnh màu sắc của Divider
                          thickness: 2, // Điều chỉnh độ dày của Divider
                        ),
                        // Biển số xe with icon
                        TextFormField(
                          controller: nameMotoController,
                          decoration: const InputDecoration(
                            labelText: 'Tên xe',
                            prefixIcon:
                                Icon(Icons.assignment), // Add motorcycle icon
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Vui lòng nhập tên xe' : null,
                        ),
                        TextFormField(
                          controller: numberPlateController,
                          decoration: const InputDecoration(
                            labelText: 'Biển số xe',
                            prefixIcon: Icon(Icons.assignment), // Add car icon
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Vui lòng nhập biển số xe'
                              : null,
                        ),
                        // Hãng xe with icon
                        DropdownButtonFormField<String>(
                          value: selectedCompanyMoto,
                          decoration: const InputDecoration(
                            labelText: 'Tên Hãng Xe',
                            prefixIcon:
                                Icon(Icons.business), // Add business icon
                          ),
                          items: companyMotoList.isEmpty
                              ? [
                                  const DropdownMenuItem(
                                      child: Text("Hãng xe không khả dụng"))
                                ]
                              : companyMotoList
                                  .map((String company) =>
                                      DropdownMenuItem<String>(
                                          value: company, child: Text(company)))
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCompanyMoto = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Vui lòng chọn hãng xe' : null,
                        ),
                        // Loại xe with icon
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Loại xe',
                            prefixIcon:
                                Icon(Icons.motorcycle), // Add category icon
                          ),
                          items: categoryList.isEmpty
                              ? [
                                  const DropdownMenuItem(
                                      child: Text("Loại xe không khả dụng"))
                                ]
                              : categoryList
                                  .map((String category) =>
                                      DropdownMenuItem<String>(
                                          value: category,
                                          child: Text(category)))
                                  .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Vui lòng chọn loại xe' : null,
                        ),
                        // Tên xe with icon
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: Colors.grey[200],
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Thông tin bổ sung",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 181, 69),
                          ),
                        ),
                        const Divider(
                          color: Color.fromARGB(
                              255, 106, 79, 40), // Chỉnh màu sắc của Divider
                          thickness: 2, // Điều chỉnh độ dày của Divider
                        ),

                        // Price
                        TextFormField(
                          controller: priceController,
                          decoration: const InputDecoration(
                            labelText: 'Giá',
                            prefixIcon: Icon(
                                Icons.monetization_on), // Icon cho trường Giá
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) return 'Vui lòng nhập giá';
                            if (double.tryParse(value) == null)
                              return 'Vui lòng nhập giá hợp lệ';
                            return null;
                          },
                        ),
                        // Description
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Mô tả',
                            prefixIcon: Icon(
                                Icons.description), // Icon cho trường Mô tả
                          ),
                          validator: (value) =>
                              value!.isEmpty ? 'Vui lòng nhập mô tả' : null,
                        ),
                        // Energy Type
                        TextFormField(
                          controller: energyController,
                          decoration: const InputDecoration(
                            labelText: 'Nhiên liệu',
                            prefixIcon: Icon(Icons
                                .local_gas_station), // Icon cho trường Nhiên liệu
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Vui lòng nhập nhiên liệu'
                              : null,
                        ),
                        // Vehicle Mass
                        TextFormField(
                          controller: vehicleMassController,
                          decoration: const InputDecoration(
                            labelText: 'Phân khối',
                            prefixIcon: Icon(
                                Icons.motorcycle), // Icon cho trường Phân khối
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty)
                              return 'Vui lòng nhập phân khối';
                            if (double.tryParse(value) == null)
                              return 'Vui lòng nhập phân khối hợp lệ';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Image Picker Section
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // Center-aligns children horizontally
                    children: [
                      const Text(
                        "Tải hình xe",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 181, 69),
                        ),
                      ),
                      const Divider(),
                      ElevatedButton.icon(
                        onPressed: pickImages,
                        icon: const Icon(Icons.photo_library),
                        label: const Text(
                          'Chọn ảnh',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      imagesMoto!.isEmpty
                          ? const Text('Chưa có ảnh nào được chọn')
                          : SizedBox(
                              height: 120,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: imagesMoto!.map((image) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.file(
                                        File(image.path),
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                      const SizedBox(height: 20),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[300], // Button color
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16), // Padding around the text
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12), // Rounded corners
                          ),
                          elevation: 4, // Shadow effect for depth
                        ),
                        child: const Text(
                          'Hoàn Tất',
                          style: TextStyle(
                            fontSize: 18, // Larger font size for visibility
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Text color
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
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
