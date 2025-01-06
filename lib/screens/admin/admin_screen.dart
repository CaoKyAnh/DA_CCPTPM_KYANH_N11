import 'package:final_project_rent_moto_fe/widgets/admin/dashboard_admin_body.dart';
import 'package:flutter/material.dart';
// Make sure to import your DashboardAdmin screen.

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardAdmin(); // Replace the Placeholder with DashboardAdmin
  }
}
