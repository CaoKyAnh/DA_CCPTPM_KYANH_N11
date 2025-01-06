// ignore_for_file: library_private_types_in_public_api
import 'package:final_project_rent_moto_fe/screens/MotorCycle/motorcycles_list_by_admin_screen.dart';
import 'package:final_project_rent_moto_fe/screens/motorCycle/deny_motor_rental_post_screen.dart';
import 'package:final_project_rent_moto_fe/services/MotorCycle/image_picker_service.dart';
import 'package:final_project_rent_moto_fe/services/MotorCycle/update_motorcycle_service.dart';
import 'package:flutter/material.dart';

class AcceptMotorRentalPostScreen extends StatefulWidget {
  final Map<String, dynamic> motorcycle;

  const AcceptMotorRentalPostScreen({super.key, required this.motorcycle});

  @override
  _AcceptMotorRentalPostScreenState createState() =>
      _AcceptMotorRentalPostScreenState();
}

class _AcceptMotorRentalPostScreenState
    extends State<AcceptMotorRentalPostScreen> {
  final UpdateMotorcycleService updateMotorcycleService =
      UpdateMotorcycleService();
  final ImagePickerService imagePickerService = ImagePickerService();
  List<String> companyMotoList = [];
  List<String> categoryList = [];

  // Selected values for dropdowns
  String? selectedCompanyMoto;
  String? selectedCategory;

  final _formKey = GlobalKey<FormState>();

  late TextEditingController numberPlateController;
  late TextEditingController nameMotoController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;
  late TextEditingController energyController;
  late TextEditingController vehicleMassController;
  late TextEditingController emailController;

  // List<File> selectedImages = [];
  List<String> imageUrls = []; // To store image URLs from Firebase

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
    emailController = TextEditingController(text: widget.motorcycle['email']);
    print(emailController.text);
    // Fetch image URLs from Firestore
    if (widget.motorcycle['informationMoto']['images'] != null) {
      imageUrls =
          List<String>.from(widget.motorcycle['informationMoto']['images']);
    }
    selectedCompanyMoto = widget.motorcycle['companyMoto']['name'];
    selectedCategory = widget.motorcycle['category']['name'];
    isActive = widget.motorcycle['isActive'] ?? false;
    isHide = widget.motorcycle['isHide'] ?? false;
    // Fetch data for dropdowns
    fetchCompanyMotos();
    fetchCategories();
  }

  Future<void> fetchCompanyMotos() async {
    List<String> companyMotos =
        await updateMotorcycleService.fetchCompanyMotos();
    setState(() {
      companyMotoList = companyMotos;
      if (companyMotoList.isNotEmpty && selectedCompanyMoto == null) {
        selectedCompanyMoto = companyMotoList[0];
      }
    });
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
    // imagesController.dispose();
    super.dispose();
  }

  Future<void> updateMotorcycle() async {
    // Prepare the `updates` map to only contain `isHide`
    final updates = {
      'isHide': isHide,
    };

    try {
      // Call UpdateMotorcycleService to update only `isHide`
      await UpdateMotorcycleService().updateMotorcycle(
        widget.motorcycle['id'],
        updates,
      );

      // Display a success message after updating
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Motorcycle visibility updated successfully!')),
        );
      }
    } catch (e) {
      // Display an error message if the update fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update motorcycle visibility: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết xe'),
        backgroundColor: Colors.teal,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MotorcyclesListByAdminScreen(),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Number Plate Input with Icon
              Card(
                elevation: 5,
                margin: EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                  child: TextField(
                    enabled: false, // Disable this text field
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
              updateMotorcycleService.buildDropdownHide(
                companyMotoList,
                selectedCompanyMoto,
                'Company Moto',
                (value) {
                  setState(() {
                    selectedCompanyMoto = value;
                  });
                },
              ),

              // Category Dropdown
              updateMotorcycleService.buildDropdownHide(
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
                    enabled: false, // Disable this text field
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
                    enabled: false, // Disable this text field
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
                    enabled: false, // Disable this text field
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
                    enabled: false, // Disable this text field
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
                    enabled: false, // Disable this text field
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

              // Is Active Switch
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
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Căn giữa hai nút
                  children: [
                    // Accept Posting button
                    ElevatedButton(
                      onPressed: updateMotorcycle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: Text(
                        'Chấp nhận',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                    SizedBox(width: 20), // Khoảng cách giữa hai nút

                    // Reject button
                    ElevatedButton(
                      onPressed: () {
                        // Handle the reject action here
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DenyMotorRentalPostScreen(
                                      email: emailController.text,
                                    )));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.red, // Đổi màu nút từ chối thành đỏ
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: Text(
                        'Từ chối',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
