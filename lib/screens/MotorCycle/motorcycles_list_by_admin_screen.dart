// ignore_for_file: library_private_types_in_public_api

import 'package:final_project_rent_moto_fe/screens/MotorCycle/motorcycles_list_screen.dart';
import 'package:final_project_rent_moto_fe/screens/MotorCycle/update_motorcycle_screen.dart';
import 'package:final_project_rent_moto_fe/services/MotorCycle/fetch_motorcycle_by_admin_service.dart';
import 'package:flutter/material.dart';

class MotorcyclesListByAdminScreen extends StatefulWidget {
  const MotorcyclesListByAdminScreen({super.key});

  @override
  _MotorcyclesListByAdminScreenState createState() =>
      _MotorcyclesListByAdminScreenState();
}

class _MotorcyclesListByAdminScreenState
    extends State<MotorcyclesListByAdminScreen> {
  late Future<List<dynamic>> motorcycles; // Future to hold list of motorcycles

  @override
  void initState() {
    super.initState();
    motorcycles = FetchMotorcycleByAdminService()
        .fetchMotorcycle(); // Fetch the list of motorcycles
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Icon quay lại
          onPressed: () {
            Navigator.pop(context); // Quay lại trang trước đó
          },
        ),
        title: Text(
          'Danh sách tất cả các xe',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Căn giữa tiêu đề
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // Danh sách xe
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future:
                  motorcycles, // The future that will be used to build the list
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                    ),
                  );
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
                    ),
                  );
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
                    ),
                  );
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
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 20),
                            title: Text(
                              motorcycle['numberPlate'] ?? 'Unknown Plate',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              motorcycle['companyMoto']['name'] ??
                                  'Unknown Company',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[700]),
                            ),
                            leading: Icon(Icons.motorcycle,
                                color: Colors.teal, size: 30),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UpdateMotorcycleScreen(
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
          ),

          // Nút chuyển hướng ở dưới cùng
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MotorcyclesListScreen(), // Chuyển hướng
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Màu nền của nút
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              child: Text(
                'Danh sách xe cần duyệt',
                style:
                    TextStyle(color: Colors.white), // Đặt màu chữ thành trắng
              ),
            ),
          ),
        ],
      ),
    );
  }
}
