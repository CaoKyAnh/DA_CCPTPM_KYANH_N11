// ignore_for_file: avoid_print, sort_child_properties_last, unused_element

import 'package:final_project_rent_moto_fe/screens/notification/notification_list_screen.dart';
import 'package:final_project_rent_moto_fe/services/bookingMoto/accept_booking_service.dart';
import 'package:final_project_rent_moto_fe/services/bookingMoto/get_booking_service.dart';
import 'package:final_project_rent_moto_fe/services/notification/update_is_hide_service.dart';
import 'package:final_project_rent_moto_fe/widgets/notification/error_notification.dart';
import 'package:final_project_rent_moto_fe/widgets/notification/success_notification.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  final String notificationId;

  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
    required this.notificationId,
  });

  @override
  _BookingDetailsScreenState createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  Map<String, dynamic>? bookingData;
  bool isLoading = true;

  bool isAccepting = false;

  String? acceptTime;

  final AcceptBookingService acceptBookingService = AcceptBookingService();

  final GetBookingService service = GetBookingService();

  final UpdateIsHideService updateIsHideService = UpdateIsHideService();
  late String notificationId;

  @override
  void initState() {
    super.initState();
    notificationId = widget.notificationId;
    fetchData();
  }

  Future<void> fetchData() async {
    print('Notification ID: $notificationId');
    try {
      final response = await service.fetchBookingById(widget.bookingId);
      if (response != null && response['success'] == true) {
        final booking = response['data'];

        // Xử lý ngày thành DateTime hoặc chuỗi hiển thị
        final String bookingDate = booking['bookingDate'] != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss')
                .format(DateTime.parse(booking['bookingDate']).toLocal())
            : 'N/A';

        final String returnDate = booking['returnDate'] != null
            ? DateFormat('yyyy-MM-dd HH:mm:ss')
                .format(DateTime.parse(booking['returnDate']).toLocal())
            : 'N/A';

        setState(() {
          bookingData = {
            ...booking,
            'bookingDate': bookingDate,
            'returnDate': returnDate,
          };
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load booking data');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching booking data: $error');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      ErrorNotification(text: message).buildSnackBar(),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SuccessNotification(text: message).buildSnackBar(),
    );
  }

  Future<Map<String, dynamic>> _acceptBooking() async {
    setState(() {
      isAccepting = true;
    });

    final result = await acceptBookingService.acceptBooking(widget.bookingId);

    setState(() {
      isAccepting = false;
    });

    return result; // Return the result so it can be used later
  }

  Future<void> _updateIsHide(String notificationId, bool isHide) async {
    try {
      final result =
          await updateIsHideService.updateIsHide(notificationId, isHide);

      if (result.containsKey('error')) {
        _showErrorMessage(result['error']);
      } else {
        print('Notification updated successfully!');
      }
    } catch (error) {
      print('Error updating notification!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chi Tiết Đặt Xe',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true, // Đặt tiêu đề nằm giữa
        backgroundColor: const Color(0xFFF49C21),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                // builder: (context) => NotificationListByUser(
                //     email: FirebaseAuth.instance.currentUser?.email ?? ''),
                builder: (context) => NotificationListScreen(),
              ),
            );
          },
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : bookingData == null
              ? const Center(
                  child: Text(
                    'Loading',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20.0,
                              horizontal: 16.0), // Tăng padding theo chiều dọc
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                label: 'Email:',
                                value: bookingData!['email'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                label: 'Biển số xe:',
                                value: bookingData!['numberPlate'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                label: 'Ngày đặt:',
                                value: bookingData!['bookingDate'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                label: 'Ngày trả:',
                                value: bookingData!['returnDate'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                label: 'Số ngày thuê:',
                                value: bookingData!['numberOfRentalDay']
                                        ?.toString() ??
                                    'N/A',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 45),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: isAccepting
                                ? null
                                : () async {
                                    // Attempt to accept the booking first
                                    final result = await _acceptBooking();

                                    // If the booking was accepted successfully (check if there is an acceptTime in result)
                                    if (result['error'] == null) {
                                      _showSuccessMessage(
                                          'Bạn đã chập nhận yêu cầu thuê xe');
                                      await _updateIsHide(notificationId, true);
                                    } else {
                                      _showErrorMessage(
                                          'Xe đang được cho thuê');
                                    }
                                  },
                            icon: isAccepting
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Icon(Icons.check),
                            label: const Text('Chấp nhận'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF49C21),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 18, color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
