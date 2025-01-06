import 'package:final_project_rent_moto_fe/widgets/rent_home/rent_home_featured_location.dart';
import 'package:final_project_rent_moto_fe/widgets/rent_home/rent_home_infor_user.dart';
import 'package:flutter/material.dart';
import 'package:final_project_rent_moto_fe/widgets/rent_home/rent_home_background.dart';
import 'package:final_project_rent_moto_fe/widgets/rent_home/rent_home_infor_motos.dart';
import 'package:final_project_rent_moto_fe/widgets/rent_home/rent_home_moto_rental.dart';
import 'package:final_project_rent_moto_fe/widgets/rent_home/rent_home_promo.dart';
import 'package:final_project_rent_moto_fe/widgets/rent_home/rent_home_search_motos.dart';

class RentHomeScreen extends StatefulWidget {
  const RentHomeScreen({super.key});

  @override
  State<RentHomeScreen> createState() => _RentHomeScreenState();
}

class _RentHomeScreenState extends State<RentHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Stack(
          children: [
            const RentHomeBackground(),
            const RentHomeInforUser(),
            const RentHomeSearchMotos(),
            Container(
              margin: const EdgeInsets.only(top: 400, left: 20),
              child: Column(
                children: [
                  const RentHomePromo(),
                  const RentHomeInforMotos(),
                  RentHomeFeaturedLocation(),
                  const RentHomeMotoRental(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
