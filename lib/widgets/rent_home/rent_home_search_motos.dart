// ignore_for_file: avoid_print

import 'package:final_project_rent_moto_fe/screens/search_moto/search_moto_screen.dart';
import 'package:final_project_rent_moto_fe/widgets/modals/search_location.dart';
import 'package:final_project_rent_moto_fe/widgets/notification/error_notification.dart';
import 'package:flutter/material.dart';
import 'package:final_project_rent_moto_fe/widgets/modals/calendar_rental.dart';
import 'package:intl/intl.dart';

class RentHomeSearchMotos extends StatefulWidget {
  const RentHomeSearchMotos({super.key});

  @override
  State<RentHomeSearchMotos> createState() => _RentHomeSearchMotosState();
}

class _RentHomeSearchMotosState extends State<RentHomeSearchMotos> {
  // Khai báo các biến DateTime cho giờ nhận và giờ trả
  late DateTime pickupDate;
  late DateTime returnDate;
  String pickupTime = "21:00";
  String returnTime = "22:00";
  // Khai báo TextEditingController để gán chuỗi hiển thị
  final TextEditingController rentalPeriodController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  void _selectLocation(BuildContext context) async {
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchLocation(),
      ),
    );

    if (selectedLocation != null) {
      // Cập nhật controller với địa điểm đã chọn (subtitle)
      setState(() {
        locationController.text =
            selectedLocation ?? 'Unknown'; // Cập nhật với subtitle
        print(locationController.text);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // Định dạng chuỗi theo mẫu yêu cầu và gán vào rentalPeriodController
    pickupDate = DateTime.now();
    returnDate = pickupDate.add(const Duration(days: 1));

    // Định dạng chuỗi theo mẫu yêu cầu và gán vào rentalPeriodController
    rentalPeriodController.text =
        "$pickupTime, ${DateFormat('dd/MM/yyyy').format(pickupDate)} - $returnTime, ${DateFormat('dd/MM/yyyy').format(returnDate)}";
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 170,
      left: 20,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(2, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                color: Color.fromARGB(255, 254, 180, 42),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.motorcycle_outlined,
                    color: Colors.white,
                    size: 25,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Tìm kiếm xe máy",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black54,
                          width: 0.8,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Colors.black54,
                              size: 18,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Địa điểm',
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 12),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 12),
                          height:
                              20, // Cố định chiều cao để không cho TextFormField xuống dòng
                          child: GestureDetector(
                            onTap: () {
                              _selectLocation(
                                  context); // Trigger location selection
                            },
                            child: Text(
                              locationController.text.isNotEmpty
                                  ? locationController.text
                                  : 'Nhập địa chỉ xe bạn muốn thuê',
                              overflow: TextOverflow
                                  .ellipsis, // Hiển thị dấu ba chấm khi chuỗi quá dài
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              color: Colors.black54,
                              size: 18,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Thời gian thuê',
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 12),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 7, left: 12),
                          height: 20,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingScreen(
                                    // Truyền rentalPeriod
                                    pickupDate: pickupDate,
                                    returnDate: returnDate,
                                    pickupTime: pickupTime,
                                    returnTime: returnTime,
                                    onDateSelected: (DateTime newPickupDate,
                                        DateTime newReturnDate,
                                        String newPickupTime,
                                        String newReturnTime) {
                                      setState(() {
                                        // Cập nhật pickupDateTime và returnDateTime
                                        pickupDate = newPickupDate;
                                        returnDate = newReturnDate;
                                        pickupTime =
                                            newPickupTime; // Cập nhật pickupTime
                                        returnTime =
                                            newReturnTime; // Cập nhật returnTime
                                        rentalPeriodController.text =
                                            "$pickupTime, ${DateFormat('dd/MM/yyyy').format(pickupDate)} - $returnTime, ${DateFormat('dd/MM/yyyy').format(returnDate)}"; // Cập nhật rentalPeriodController
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                            child: TextFormField(
                              controller:
                                  rentalPeriodController, // Gán giá trị đã định dạng
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none),
                              ),
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500),
                              readOnly: true,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          width: 330,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFAD15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: () {
                              if (!locationController.text.trim().isEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchMotoScreen(
                                      location: locationController.text.trim(),
                                      time: rentalPeriodController.text.trim(),
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  ErrorNotification(
                                    text: 'Hãy nhập địa chỉ để tìm kiếm',
                                  ).buildSnackBar(),
                                );
                              }
                            },
                            child: const Text(
                              'TÌM XE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
