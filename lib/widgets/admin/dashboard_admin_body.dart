import 'package:final_project_rent_moto_fe/screens/CategoryMoto/list_category_screen.dart';
import 'package:final_project_rent_moto_fe/screens/CompanyMoto/list_company_screen.dart';
import 'package:final_project_rent_moto_fe/screens/MotorCycle/motorcycles_list_by_admin_screen.dart';
import 'package:final_project_rent_moto_fe/screens/dashboard.dart';
import 'package:final_project_rent_moto_fe/screens/promo/promo_list_screen.dart';
import 'package:final_project_rent_moto_fe/screens/promoByCompany/promobycompany_list_screen.dart';
import 'package:final_project_rent_moto_fe/screens/promoByCompany/promobycompay_add_screen.dart';
import 'package:final_project_rent_moto_fe/screens/users/user_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardAdmin extends StatelessWidget {
  DashboardAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[dashBg, content(context)],
      ),
    );
  }

  // Updated Background gradient with blue colors
  get dashBg => Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF49C21), // Primary blue
                    Color(0xFFF49C21), // Light blue
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(color: Colors.transparent),
          ),
        ],
      );

  // Main content including header and grid
  Widget content(BuildContext context) => Container(
        child: Column(
          children: <Widget>[
            header(context), // Pass context to header
            grid(context),
          ],
        ),
      );

  // Header section with back button
  Widget header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: ListTile(
        leading: IconButton(
          icon: const Icon(Icons.login_outlined, color: Colors.black),
          onPressed: () async {
            // Navigator.pushAndRemoveUntil with proper context usage
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLogin', false);
            await FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
            );
          },
        ),
        title: const Text(
          'Trang chủ Admin',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // List of actions for grid items
  final List<String> itemNames = [
    'Hảng xe',
    'Loại xe',
    'Xe',
    'Tài khoản',
    'Khuyến mãi',
    'Khuyến mãi theo loại xe',
    // 'Profile',
    // 'Revenue',
  ];

  final List<Widget> itemsPages = [
    const ListCompanyScreen(),
    const ListCategoryScreen(),
    const MotorcyclesListByAdminScreen(),
    const UserListScreen(),
    const PromoListScreen(),
    const PromobycompanyListScreen(),
    // const ProductList(),
  ];

  // Grid of items
  Widget grid(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            crossAxisCount: 2,
            childAspectRatio: .85,
            children: List.generate(itemNames.length, (index) {
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => itemsPages[index],
                      ),
                    );
                  },
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.dashboard,
                          size: 40,
                          color: Colors.orange[300],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          itemNames[index],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      );
}
