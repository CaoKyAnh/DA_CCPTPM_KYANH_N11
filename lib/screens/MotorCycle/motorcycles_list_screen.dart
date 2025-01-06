// ignore_for_file: library_private_types_in_public_api

import 'package:final_project_rent_moto_fe/screens/MotorCycle/accept_motor_rental_post_screen.dart';
import 'package:final_project_rent_moto_fe/services/MotorCycle/fetch_motorcycle_service.dart';
import 'package:flutter/material.dart';

class MotorcyclesListScreen extends StatefulWidget {
  const MotorcyclesListScreen({super.key});

  @override
  _MotorcyclesListScreenState createState() => _MotorcyclesListScreenState();
}

class _MotorcyclesListScreenState extends State<MotorcyclesListScreen> {
  late Future<List<dynamic>> motorcycles; // Future to hold list of motorcycles

  @override
  void initState() {
    super.initState();
    motorcycles = FetchMotorcycleService()
        .fetchMotorcycle(); // Fetch the list of motorcycles
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Danh sách xe cần duyệt"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: motorcycles, // The future that will be used to build the list
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
            )); // Show loading indicator with color
          } else if (snapshot.hasError) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 40),
                SizedBox(height: 10),
                Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
            ));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.motorcycle, color: Colors.grey, size: 50),
                SizedBox(height: 10),
                Text(
                  'No motorcycles found',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ],
            ));
          } else {
            var motorcycleList = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: motorcycleList.length,
                itemBuilder: (context, index) {
                  var motorcycle = motorcycleList[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      title: Text(
                        motorcycle['numberPlate'] ?? 'Unknown Plate',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        motorcycle['companyMoto']['name'] ?? 'Unknown Company',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      leading:
                          Icon(Icons.motorcycle, color: Colors.teal, size: 30),
                      onTap: () {
                        // Navigate to the UpdateMotorcycleScreen when tapping anywhere else
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AcceptMotorRentalPostScreen(
                              motorcycle:
                                  motorcycle, // Pass the motorcycle data
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
