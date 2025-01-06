// ignore_for_file: library_private_types_in_public_api, unused_field, avoid_print

import 'package:flutter/material.dart';
import 'package:final_project_rent_moto_fe/screens/companyMoto/add_company_moto.dart';
import 'package:final_project_rent_moto_fe/screens/companyMoto/update_company_screen.dart';
import 'package:final_project_rent_moto_fe/services/companyMoto/fetch_company_service.dart';
import 'package:final_project_rent_moto_fe/services/companyMoto/update_company_service.dart';

class ListCompanyScreen extends StatefulWidget {
  const ListCompanyScreen({super.key});

  @override
  _ListCompanyScreenState createState() => _ListCompanyScreenState();
}

class _ListCompanyScreenState extends State<ListCompanyScreen> {
  final FetchCompanyService _fetchService = FetchCompanyService();
  final UpdateCompanyService _updateService = UpdateCompanyService();

  late Future<List<Map<String, dynamic>>> _companyMotosFuture;

  @override
  void initState() {
    super.initState();
    // Khởi tạo Future ban đầu để tải danh sách
    _companyMotosFuture = _fetchCompanyMotos();
  }

  void _showUpdateDialog(Map<String, dynamic> company) {
    final String? id = company['id'] as String?;

    if (id == null) {
      print("Error: 'id' is null for company: $company");
      return; // Exit the function or show a message
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return UpdateCompanyScreen(
          id: company['id'],
          currentName: company['name'],
          currentIsHide: company['isHide'],
          onUpdate: (id, name, isHide) async {
            try {
              // Cập nhật công ty moto qua service
              await _updateService.updateCompanyMoto(id, name, isHide);

              // Sau khi cập nhật thành công, làm mới lại danh sách
              if (mounted) {
                setState(() {
                  // Làm mới Future của danh sách công ty bằng cách gọi lại _fetchCompanyMotos()
                  _companyMotosFuture = _fetchCompanyMotos();
                });

                // Hiển thị thông báo thành công
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Updated company moto',
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
              // Làm mới lại danh sách sau khi cập nhật
              if (mounted) {
                setState(() {
                  // Làm mới Future của danh sách công ty bằng cách gọi lại _fetchCompanyMotos()
                  _companyMotosFuture = _fetchCompanyMotos();
                });
              }
            } catch (e) {
              // Handle error
              print("Error updating company: $e");
            }
          },
        );
      },
    );
  }

  // Method to fetch company motos
  Future<List<Map<String, dynamic>>> _fetchCompanyMotos() async {
    try {
      return await _fetchService
          .fetchCompanies(); // Fetch data from the service
    } catch (error) {
      print("Error fetching companies: $error");
      return []; // Return empty list in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'List Company Motos',
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                // Sử dụng FutureBuilder
                future: _companyMotosFuture, // Fetch company motos từ service
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'No company motos available.',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  }

                  // If data is available, display the list
                  final companyMotos = snapshot.data!;
                  return ListView.builder(
                    itemCount: companyMotos.length,
                    itemBuilder: (ctx, index) {
                      final company = companyMotos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          title: Text(
                            company['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showUpdateDialog(company),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Add the button at the bottom
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddCompanyMotoPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                ),
                child: const Text(
                  'Add Company Moto',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
