// ignore_for_file: avoid_print, use_build_context_synchronously, annotate_overrides
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_rent_moto_fe/screens/dashboard.dart';
import 'package:final_project_rent_moto_fe/screens/booking/future_bookings_widget.dart';

import 'package:final_project_rent_moto_fe/screens/map/location_of-moto.dart';
import 'package:final_project_rent_moto_fe/services/MotorCycle/get_user_data_service.dart';
import 'package:final_project_rent_moto_fe/services/bookingMoto/addbookingService.dart';
import 'package:final_project_rent_moto_fe/services/fcm/fcm_service.dart';
import 'package:final_project_rent_moto_fe/services/notification/notification_service.dart';
import 'package:final_project_rent_moto_fe/services/promo/apply_promo_service.dart';
import 'package:final_project_rent_moto_fe/services/promoByCompany/applyPromoByCompany.dart';
import 'package:final_project_rent_moto_fe/widgets/detail_moto/detail_moto_review.dart';
import 'package:final_project_rent_moto_fe/widgets/detail_moto/detail_moto_appbar.dart';
import 'package:final_project_rent_moto_fe/widgets/modals/calendar_rental.dart';
import 'package:final_project_rent_moto_fe/widgets/notification/error_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class DetailMotoScreen extends StatefulWidget {
  final Map<String, dynamic> motorcycle; // Thêm một tham số để nhận dữ liệu

  const DetailMotoScreen({super.key, required this.motorcycle});
  @override
  State<DetailMotoScreen> createState() => _DetailMotoScreenState();
}

class _DetailMotoScreenState extends State<DetailMotoScreen> {
  // Nhận dữ liệu từ constructor
  String _selectedPickupOption = 'self_pickup'; // Default pickup option

  late DateTime pickupDate; // Khai báo ngày nhận
  late DateTime returnDate; // Khai báo ngày trả
  String pickupTime = "21:00";
  String returnTime = "22:00";
  int totalAmount = 0;
  int originalTotalAmount = 0;
  DateTime? pickupDateTime;
  DateTime? returnDateTime;
  final _addBookingService = AddBookingService();
  final ApplyPromoByCompanyService promoService = ApplyPromoByCompanyService();
  LatLng? _mapCoordinates;
  String? appliedPromoCode;
  Map<String, dynamic>? userData;
  final FCMService fcmService = FCMService();
  double averageRating = 0.0;
  int totalTrips = 0;
  double priceIsDiscount = 0.0;
  double originalPrice = 0.0;
  double percentage = 0.0;
  bool isLoading = true;
  void initState() {
    super.initState();
    pickupDate = DateTime.now();
    returnDate = pickupDate.add(const Duration(days: 1));
    _updateDateTimes(); // Cập nhật giá trị pickupDateTime và returnDateTime ngay khi khởi tạo
    _calculateTotalAmount();
    _fetchCoordinates();
    String email = widget.motorcycle['email'] ?? 'Không có email';
    getUserData(email);
    fetchAverageRating();
    fetchTotalTrips();
    _applyPromo();
  }

  Future<void> _applyPromo() async {
    try {
      var motorcycleId = widget.motorcycle['id']; // Assuming you have an 'id'
      double discountedPrice = await promoService.applyPromotion(motorcycleId);
      setState(() {
        percentage = discountedPrice != originalPrice
            ? ((originalPrice - discountedPrice) / originalPrice) * 100
            : 0.0;
        priceIsDiscount = discountedPrice;
      });
    } catch (e) {
      print("Error applying promotion: $e");
    }
  }

  Future<void> fetchTotalTrips() async {
    try {
      print('fetchTotalTrips() được gọi'); // Debug xem hàm có chạy không
      // Truy vấn bookings để lấy danh sách bookingId theo numberPlate
      final bookingsQuery = await FirebaseFirestore.instance
          .collection('bookings')
          .where('numberPlate', isEqualTo: widget.motorcycle['numberPlate'])
          .get();

      if (bookingsQuery.docs.isNotEmpty) {
        // Lấy danh sách bookingId
        final bookingIds = bookingsQuery.docs.map((doc) => doc.id).toList();

        int count = 0;
        // Kiểm tra từng bookingId trong invoices
        for (String bookingId in bookingIds) {
          final invoiceQuery = await FirebaseFirestore.instance
              .collection('invoices')
              .where('bookingId', isEqualTo: bookingId)
              .get();

          if (invoiceQuery.docs.isNotEmpty) {
            count++;
          }
        }

        setState(() {
          totalTrips = count;
          isLoading = false;
        });
      } else {
        // Không có bookings nào
        setState(() {
          totalTrips = 0;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching trips: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchAverageRating() async {
    try {
      // Lấy danh sách reviews dựa trên numberPlate
      final querySnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('numberPlate', isEqualTo: widget.motorcycle['numberPlate'])
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final ratings = querySnapshot.docs
            .map((doc) => doc.data()['numberStars'] as int)
            .toList();

        // Tính trung bình số sao
        final totalStars = ratings.fold(0, (sum, star) => sum + star);
        setState(() {
          averageRating = totalStars / ratings.length;
          isLoading = false;
        });
      } else {
        // Không có đánh giá
        setState(() {
          averageRating = 5.0;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching reviews: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Phương thức cập nhật pickupDateTime và returnDateTime
  void _updateDateTimes() {
    List<String> pickupTimeParts = pickupTime.split(":");
    List<String> returnTimeParts = returnTime.split(":");

    pickupDateTime = DateTime(
      pickupDate.year,
      pickupDate.month,
      pickupDate.day,
      int.parse(pickupTimeParts[0]), // Giờ
      int.parse(pickupTimeParts[1]),
    );

    returnDateTime = DateTime(
      returnDate.year,
      returnDate.month,
      returnDate.day,
      int.parse(returnTimeParts[0]), // Giờ
      int.parse(returnTimeParts[1]),
    );
  }

  // Tính tổng tiền
  void _calculateTotalAmount() async {
    if (pickupDateTime != null && returnDateTime != null) {
      // Tính số ngày thuê
      int rentalDays = returnDateTime!.difference(pickupDateTime!).inDays;

      // Lấy giá thuê từ thông tin xe
      var info = widget.motorcycle['informationMoto'] ?? {};
      String priceXe = info['price'].toString();
      // Lấy giá đã áp dụng khuyến mãi từ service
      try {
        double discountedPrice = await promoService
            .applyPromotion(widget.motorcycle['id']); // Lấy id của xe máy
        setState(() {
          // Nếu có khuyến mãi, dùng giá đã giảm, nếu không dùng giá gốc
          priceXe = discountedPrice.toString();
          // Tính tổng tiền sau khuyến mãi
          int numberPirceXe = discountedPrice.toInt();
          totalAmount = (rentalDays * numberPirceXe);
          originalTotalAmount = totalAmount;
        });
      } catch (e) {
        // Nếu không áp dụng khuyến mãi, sử dụng giá gốc
        setState(() {
          int numberPirceXe = int.parse(priceXe);
          totalAmount = (rentalDays * numberPirceXe);
          originalTotalAmount = totalAmount;
        });
      }
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      ErrorNotification(text: message).buildSnackBar(),
    );
  }

  Future<void> _addBooking({
    required String numberPlate,
    required DateTime? pickupDateTime,
    required DateTime? returnDateTime,
  }) async {
    User? user = FirebaseAuth.instance.currentUser;
    String email = widget.motorcycle['email'] ?? 'No email';

    // Ensure the user is logged in and their email is not the same as the motorcycle owner
    if (user != null && user.email != email) {
      if (pickupDateTime != null && returnDateTime != null) {
        // Calculate the number of rental days
        int numberOfRentalDay =
            returnDateTime.difference(pickupDateTime).inDays;

        // Ensure the rental days are positive
        if (numberOfRentalDay > 0) {
          try {
            // Make the request to the backend to add the booking
            Map<String, dynamic> response = await _addBookingService.addBooking(
              email: user.email!, // Use the current user's email
              numberPlate: numberPlate,
              bookingDate: pickupDateTime,
              returnDate: returnDateTime,
              numberOfRentalDay: numberOfRentalDay,
              totalAmount: originalTotalAmount,
            );

            // Debug: Log the response to check if the conflict message is returned properly
            print("Response from backend: $response");

            // Handle the case when the backend detects a booking conflict
            if (response['message'] ==
                'Conflict detected: Vehicle is already booked.') {
              _showErrorMessage(context, 'Xe đang được thuê');

              return; // Exit the function if there's a conflict
            }

            // If no conflict, proceed with the normal booking flow
            String bookingId = response['id'];

            // Send a push notification to the motorcycle owner
            String fcmToken = await fcmService.getFcmTokenForOwner(email);
            String accountOwner = widget.motorcycle['email'] ?? 'No email';

            if (fcmToken.isNotEmpty) {
              // Send push notification
              await fcmService.sendPushNotification(
                fcmToken,
                'Yêu cầu đặt xe',
                'Xe máy của bạn đã được đặt!',
                accountOwner,
                'NotificationListScreen',
              );
            }

            // Add a notification to the database
            await NotificationService().addNotification(
              title: 'Yêu cầu đặt xe',
              body: 'Xe máy của bạn đã được đặt!',
              email: accountOwner,
              bookingId: bookingId,
              bookingDate: pickupDateTime,
              returnDate: returnDateTime,
            );
          } catch (error) {
            // Handle any errors from the backend or API call
            print('Error occurred while adding booking: $error');
          }
        } else {
          print('Return date must be after the pickup date!');
        }
      } else {
        print(
            'Incomplete information: Please check the pickup or return date!');
      }
    } else {
      // If the emails match, do not allow booking
      print('Booking cannot be added, email is not allowed.');
    }
  }

  Future<LatLng> getCoordinates(
      String streetName, String district, String city, String country) async {
    final address = '$streetName,$district, $city, $country';
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final latitude = double.tryParse(data[0]['lat']);
        final longitude = double.tryParse(data[0]['lon']);

        if (latitude != null && longitude != null) {
          print("Vị độ $longitude, Kinh độ $latitude");
          return LatLng(latitude, longitude);
        }
      }
    }
    throw Exception('Không thể tải tọa độ');
  }

  Future<void> _fetchCoordinates() async {
    var address = widget.motorcycle['address'] ?? {};
    String streetName = address['streetName'] ?? '';
    String district = address['district'] ?? '';
    String city = address['city'] ?? '';
    String country = address['country'] ?? '';

    try {
      LatLng coordinates =
          await getCoordinates(streetName, district, city, country);
      setState(() {
        _mapCoordinates = coordinates; // Đảm bảo tọa độ được cập nhật
      });
    } catch (e) {
      print('Lỗi khi lấy tọa độ: $e');
    }
  }

  void getUserData(String email) async {
    UserService userService = UserService();
    Map<String, dynamic>? data = await userService.getUserData(email);

    if (data != null) {
      setState(() {
        userData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var info = widget.motorcycle['informationMoto'] ?? {};
    var address = widget.motorcycle['address'] ?? {};
    String district = address['district'];
    String city = address['city'];
    String email = widget.motorcycle['email'] ?? 'Không có email';

    return Scaffold(
      appBar: DetailMotoAppBar(motorcycle: widget.motorcycle),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Builder(
                        builder: (context) {
                          String imageUrl = (info['images'] != null &&
                                  info['images'].isNotEmpty)
                              ? info['images'][0]
                              : 'assets/images/xe1.jpg';
                          Uri? uri = Uri.tryParse(imageUrl);
                          if (uri != null && uri.isAbsolute) {
                            return Image.network(
                              imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          } else {
                            return Image.asset(
                              imageUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            );
                          }
                        },
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Motorcycle Name (dynamic)
                            Text(
                              info['nameMoto'] ?? 'Motorcycle Name',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                // Kiểm tra nếu giá gốc và giá sau khuyến mãi giống nhau
                                if (info['price'] == priceIsDiscount)
                                  // Hiển thị giá gốc với màu đen
                                  Text(
                                    NumberFormat("#,###", "vi_VN")
                                        .format(info['price']),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Colors.black, // Màu đen cho giá gốc
                                    ),
                                  )
                                else ...[
                                  // Hiển thị giá gốc với dấu gạch ngang
                                  Text(
                                    NumberFormat("#,###", "vi_VN")
                                        .format(info['price']),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .black54, // Màu xám nhạt cho giá gốc
                                      decoration: TextDecoration
                                          .lineThrough, // Dấu gạch ngang
                                    ),
                                  ),
                                  const SizedBox(
                                      width:
                                          10), // Khoảng cách giữa giá gốc và giá giảm

                                  // Hiển thị giá đã áp dụng khuyến mãi
                                  Text(
                                    NumberFormat("#,###", "vi_VN")
                                        .format(priceIsDiscount),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors
                                          .red, // Màu đỏ cho giá sau khuyến mãi
                                    ),
                                  ),
                                ],
                                const Text(
                                  ' đ/day',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.yellow), // Star icon for rating
                          const SizedBox(width: 2),
                          const Text(
                            '5.0', // Rating score
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Image.asset(
                            'assets/images/fast-delivery.png', // Delivery icon
                            width: 24,
                            height: 24,
                          ),
                          const Text(
                            '10 trip', // Number of trips
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Đặc điểm', // Features
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),

                      // Motorcycle Features
                      Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 236, 237, 236)
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Color Feature
                            Row(
                              children: [
                                const Icon(Icons.energy_savings_leaf_outlined,
                                    color: Color.fromARGB(
                                        255, 255, 173, 21)), // Color icon
                                const SizedBox(width: 8),
                                Text(
                                  "Phân khối: ${info['vehicleMass'] ?? "Unknown"} cc",
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const SizedBox(height: 8),
                            // Fuel consumption
                            Row(
                              children: [
                                Icon(Icons.local_gas_station,
                                    color: Color.fromARGB(
                                        255, 255, 173, 21)), // Fuel icon
                                SizedBox(width: 8),
                                Text(
                                  "Nhiên liệu: ${info['energy'] ?? "Unknown"}",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Mô tả',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Description (dynamic)
                      Text(
                        info['description'] ?? 'No description available.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thời gian thuê xe',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingScreen(
                          pickupDate: pickupDate,
                          returnDate: returnDate,
                          pickupTime: pickupTime,
                          returnTime: returnTime,
                          onDateSelected: (DateTime newPickupDate,
                              DateTime newReturnDate,
                              String newPickupTime,
                              String newReturnTime) {
                            setState(() {
                              // Cập nhật giá trị khi chọn ngày mới
                              pickupDate = newPickupDate;
                              returnDate = newReturnDate;
                              pickupTime = newPickupTime;
                              returnTime = newReturnTime;
                              _updateDateTimes(); // Cập nhật lại thời gian sau khi thay đổi
                              _calculateTotalAmount();
                            });
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/calendar.png',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$pickupTime, ${pickupDate.day}/${pickupDate.month}/${pickupDate.year} - $returnTime, ${returnDate.day}/${returnDate.month}/${returnDate.year}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Vị trí xe',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${district}, ${city}',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _mapCoordinates != null
                    ? LocationOfMotoScreen(
                        latitude: _mapCoordinates!.latitude,
                        longitude: _mapCoordinates!.longitude,
                      )
                    : const CircularProgressIndicator()
              ],
            ),
            const SizedBox(height: 16),
            Row(),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: userData?['information']['avatar'] != null &&
                          userData?['information']['avatar'].isNotEmpty
                      ? NetworkImage(userData?['information']
                          ['avatar']) // Nếu có URL hợp lệ
                      : AssetImage('assets/images/xe1.jpg')
                          as ImageProvider, // Nếu không, dùng ảnh mặc định từ assets
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          userData?['information']['name'] ?? 'User Name',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            final currentUser =
                                FirebaseAuth.instance.currentUser;

                            if (currentUser == null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Dashboard(initialIndex: 2),
                                ),
                              );
                              return;
                            }

                            final userAEmail = currentUser.email ?? '';
                            final userBEmail = userData?['email'] ?? 'Email';

                            if (userAEmail == userBEmail) {
                              return;
                            }

                            try {
                              final senderName =
                                  await UserService().getSenderName(userAEmail);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Error fetching user data: $e')),
                              );
                            }
                          },
                          child: const Icon(Icons.message, size: 30),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (totalTrips > 0) ...[
                          const Icon(Icons.star,
                              color: Colors.yellow, size: 16),
                          const SizedBox(width: 4),
                          isLoading
                              ? const Text(
                                  'Đang tải...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  "${averageRating.toStringAsFixed(1)}", // Hiển thị rating trung bình
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                        ],
                        if (totalTrips > 0) const SizedBox(width: 8),
                        const Icon(Icons.directions_car, size: 16),
                        const SizedBox(width: 4),
                        isLoading
                            ? const Text(
                                'Đang tải...',
                                style: TextStyle(fontSize: 14),
                              )
                            : Text(
                                totalTrips > 0
                                    ? '$totalTrips chuyến'
                                    : 'Chưa có chuyến', // Hiển thị kết quả
                                style: const TextStyle(fontSize: 14),
                              ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBookingsWidget(
              numberPlate: widget.motorcycle['numberPlate'],
            ),
            DetailMotoReview(
              numberPlate: widget.motorcycle['numberPlate'],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4.0, left: 16.0, right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Tổng tiền: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        NumberFormat("#,###", "vi_VN").format(totalAmount),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      Text(
                        ' VNĐ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          TextEditingController discountController =
                              TextEditingController();
                          ApplyPromoService promoService = ApplyPromoService();

                          return AlertDialog(
                            title: const Text('Nhập Mã Giảm Giá'),
                            content: TextField(
                              controller: discountController,
                              decoration: const InputDecoration(
                                hintText: 'Nhập mã giảm giá của bạn',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  String promoCode =
                                      discountController.text.trim();

                                  try {
                                    // Kiểm tra xem mã giảm giá đã được áp dụng chưa
                                    if (promoCode == appliedPromoCode) {
                                      promoService.showSnackbar(
                                        context,
                                        'Mã giảm giá này đã được áp dụng!',
                                        isError: true,
                                      );
                                      Navigator.of(context).pop();
                                      return;
                                    }
                                    // Gọi service để xử lý áp dụng mã khuyến mãi
                                    await promoService.applyPromoHandler(
                                      context,
                                      promoCode,
                                      originalTotalAmount,
                                    );

                                    // Lấy lại tổng tiền sau khi áp dụng khuyến mãi
                                    Map<String, dynamic>? promoDetails =
                                        await promoService
                                            .fetchPromoDetails(promoCode);

                                    if (promoDetails != null) {
                                      int newTotal =
                                          await promoService.applyPromo(
                                        promoCode: promoCode,
                                        totalAmount: originalTotalAmount,
                                        promoDetails: promoDetails,
                                      );
                                      setState(() {
                                        totalAmount =
                                            newTotal; // Cập nhật tổng tiền
                                        appliedPromoCode =
                                            promoCode; // Lưu mã đã áp dụng
                                      });
                                    }

                                    Navigator.of(context).pop();
                                  } catch (e) {
                                    promoService.showSnackbar(
                                      context,
                                      e.toString(),
                                      isError: true,
                                    );
                                  }
                                },
                                child: const Text('Áp Dụng'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Hủy'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Mã Giảm Giá',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  _addBooking(
                    numberPlate: widget.motorcycle['numberPlate'],
                    pickupDateTime: pickupDateTime,
                    returnDateTime: returnDateTime,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 173, 21),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Thuê'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
