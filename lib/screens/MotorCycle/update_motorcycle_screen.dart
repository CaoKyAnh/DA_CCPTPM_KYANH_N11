// ignore_for_file: library_private_types_in_public_api, avoid_print
import 'dart:io';
import 'package:final_project_rent_moto_fe/screens/motorCycle/update_motorcycle_logic.dart';
import 'package:final_project_rent_moto_fe/services/MotorCycle/image_picker_service.dart';
import 'package:final_project_rent_moto_fe/services/MotorCycle/update_motorcycle_service.dart';
import 'package:final_project_rent_moto_fe/widgets/modals/search_location.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UpdateMotorcycleScreen extends StatefulWidget {
  final Map<String, dynamic> motorcycle;

  const UpdateMotorcycleScreen({super.key, required this.motorcycle});

  @override
  _UpdateMotorcycleScreenState createState() => _UpdateMotorcycleScreenState();
}

class _UpdateMotorcycleScreenState extends State<UpdateMotorcycleScreen> {
  List<String> companyMotoList = [];
  List<String> categoryList = [];
  final UpdateMotorcycleService updateMotorcycleService =
      UpdateMotorcycleService();
  final ImagePickerService imagePickerService = ImagePickerService();

  String? selectedCompanyMoto;
  String? selectedCategory;

  final _formKey = GlobalKey<FormState>();

  late TextEditingController numberPlateController;
  late TextEditingController nameMotoController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;
  late TextEditingController energyController;
  late TextEditingController vehicleMassController;
  final TextEditingController locationController = TextEditingController();
  final TextEditingController streetNameController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  List<File> selectedImages = [];
  List<String> imageUrls = []; // To store image URLs from Firebase
  final ImagePicker imagePicker = ImagePicker();
  bool isActive = false;
  bool isHide = false;

  @override
  void initState() {
    super.initState();

    // Khởi tạo controller với giá trị hiện tại của chiếc xe
    numberPlateController =
        TextEditingController(text: widget.motorcycle['numberPlate']);
    nameMotoController = TextEditingController(
        text: widget.motorcycle['informationMoto']['nameMoto']);
    priceController = TextEditingController(
        text: widget.motorcycle['informationMoto']['price'].toString());
    descriptionController = TextEditingController(
        text: widget.motorcycle['informationMoto']['description']);
    energyController = TextEditingController(
        text: widget.motorcycle['informationMoto']['energy']);
    vehicleMassController = TextEditingController(
        text: widget.motorcycle['informationMoto']['vehicleMass'].toString());

    // Fetch image URLs from Firestore
    if (widget.motorcycle['informationMoto']['images'] != null) {
      imageUrls =
          List<String>.from(widget.motorcycle['informationMoto']['images']);
    }
    selectedCompanyMoto = widget.motorcycle['companyMoto']['name'];
    selectedCategory = widget.motorcycle['category']['name'];
    isActive = widget.motorcycle['isActive'] ?? false;
    isHide = widget.motorcycle['isHide'] ?? false;

    // Initialize address-related controllers with existing address data
    streetNameController.text =
        widget.motorcycle['address']['streetName'] ?? '';
    districtController.text = widget.motorcycle['address']['district'] ?? '';
    cityController.text = widget.motorcycle['address']['city'] ?? '';
    countryController.text = widget.motorcycle['address']['country'] ?? '';

    // Fetch data for dropdowns
    fetchCompanyMotos();
    fetchCategories();
  }

  void _selectLocation(BuildContext context) async {
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchLocation(),
      ),
    );

    if (selectedLocation != null) {
      setState(() {
        locationController.text = selectedLocation;
        final addressParts = selectedLocation.split(',');

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

  // Method to pick multiple images
  Future<void> pickImages() async {
    final pickedImages =
        await imagePickerService.pickImages(); // Use the new service
    if (pickedImages.isNotEmpty) {
      setState(() {
        selectedImages = pickedImages;
      });
    }
  }

  Future<void> fetchCompanyMotos() async {
    List<String> companyMotos =
        await updateMotorcycleService.fetchCompanyMotos();
    if (mounted) {
      setState(() {
        companyMotoList = companyMotos;
        if (companyMotoList.isNotEmpty && selectedCompanyMoto == null) {
          selectedCompanyMoto = companyMotoList[0];
        }
      });
    }
  }

  Future<void> fetchCategories() async {
    List<String> categories = await updateMotorcycleService.fetchCategories();
    setState(() {
      categoryList = categories;
      if (categoryList.isNotEmpty && selectedCategory == null) {
        selectedCategory = categoryList[0];
      }
    });
  }

  @override
  void dispose() {
    numberPlateController.dispose();
    nameMotoController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    energyController.dispose();
    vehicleMassController.dispose();
    locationController.dispose();
    streetNameController.dispose();
    districtController.dispose();
    cityController.dispose();
    countryController.dispose();
    super.dispose();
  }

  Future<void> updateMotorcycle() async {
    await updateMotorcycleLogic(
      context: context,
      motorcycleId: widget.motorcycle['id'],
      numberPlateController: numberPlateController,
      nameMotoController: nameMotoController,
      priceController: priceController,
      descriptionController: descriptionController,
      energyController: energyController,
      vehicleMassController: vehicleMassController,
      selectedImages: selectedImages,
      imageUrls: imageUrls,
      imagePickerService: imagePickerService,
      selectedCompanyMoto: selectedCompanyMoto,
      selectedCategory: selectedCategory,
      isActive: isActive,
      isHide: isHide,
      streetName: streetNameController.text,
      district: districtController.text,
      city: cityController.text,
      country: countryController.text,
      existingStreetName: widget.motorcycle['address']['streetName'] ?? '',
      existingDistrict: widget.motorcycle['address']['district'] ?? '',
      existingCity: widget.motorcycle['address']['city'] ?? '',
      existingCountry: widget.motorcycle['address']['country'] ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Motorcycle'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location input field
              Card(
                elevation: 5,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                  child: TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      hintText:
                          'Enter the location where you want to rent a motorbike',
                    ),
                    readOnly: true,
                    onTap: () => _selectLocation(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a location.';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              // Number Plate Input with Icon
              Card(
                elevation: 5,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                  child: TextField(
                    controller: numberPlateController,
                    decoration: InputDecoration(
                      labelText: 'Number Plate',
                      prefixIcon: Icon(Icons.card_travel),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),

              // Company Moto Dropdown
              UpdateMotorcycleService.buildDropdown(
                  companyMotoList, selectedCompanyMoto, 'Company Moto',
                  (value) {
                setState(() {
                  selectedCompanyMoto = value;
                });
              }),

              // Category Dropdown
              UpdateMotorcycleService.buildDropdown(
                  categoryList, selectedCategory, 'Category', (value) {
                setState(() {
                  selectedCategory = value;
                });
              }),

              // Name Moto Input with Icon
              Card(
                elevation: 5,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                  child: TextField(
                    controller: nameMotoController,
                    decoration: InputDecoration(
                      labelText: 'Name Moto',
                      prefixIcon: Icon(Icons.motorcycle),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),

              // Price Input with Icon
              Card(
                elevation: 5,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                  child: TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      prefixIcon: Icon(Icons.monetization_on),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),

              // Description Input with Icon
              Card(
                elevation: 5,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                  child: TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),

              // Energy Input with Icon
              Card(
                elevation: 5,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                  child: TextField(
                    controller: energyController,
                    decoration: InputDecoration(
                      labelText: 'Energy',
                      prefixIcon: Icon(Icons.energy_savings_leaf),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),

              // Vehicle Mass Input with Icon
              Card(
                elevation: 5,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                  child: TextField(
                    controller: vehicleMassController,
                    decoration: InputDecoration(
                      labelText: 'Vehicle Mass',
                      prefixIcon: Icon(Icons.fitness_center),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),

              // Current Images Section
              ImagePickerService.buildCurrentImages(imageUrls),

              // Select Images Button
              Center(
                child: ElevatedButton(
                  onPressed: pickImages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Text(
                    'Select Images',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              // Display selected images
              selectedImages.isNotEmpty
                  ? Column(
                      children: selectedImages.map((imageFile) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Image.file(
                            imageFile,
                            height: 100,
                            width: 100,
                          ),
                        );
                      }).toList(),
                    )
                  : Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text('No images selected'),
                    ),

              // Is Active Switch
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Colors.teal, size: 24), // Icon next to the label
                    SizedBox(width: 10), // Spacing between icon and text
                    Text(
                      'Is Active',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w500, // Slightly bold for readability
                      ),
                    ),
                    Spacer(), // This makes sure the switch is pushed to the right side
                    Switch(
                      value: isActive,
                      onChanged: (value) {
                        setState(() {
                          isActive = value;
                        });
                      },
                      activeColor: Colors.teal,
                      inactiveTrackColor:
                          Colors.grey, // Inactive color for clarity
                      inactiveThumbColor: Colors.grey, // Inactive thumb color
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.visibility_off,
                        color: Colors.teal, size: 24), // Icon for visibility
                    SizedBox(width: 10), // Spacing between icon and text
                    Text(
                      'Is Hidden',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w500, // Slightly bold for readability
                      ),
                    ),
                    Spacer(), // Push the switch to the right side
                    Switch(
                      value: isHide,
                      onChanged: (value) {
                        setState(() {
                          isHide = value;
                        });
                      },
                      activeColor: Colors.teal,
                      inactiveTrackColor: Colors.grey,
                      inactiveThumbColor: Colors.grey,
                    ),
                  ],
                ),
              ),

              // Update Button
              Center(
                child: ElevatedButton(
                  onPressed: updateMotorcycle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Text(
                    'Update Motorcycle',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
