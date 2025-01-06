// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateIsHideBookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cập nhật thuộc tính isHide của booking
  Future<void> hideBooking(String bookingId) async {
    try {
      // Kiểm tra nếu booking tồn tại
      DocumentSnapshot bookingSnapshot =
          await _firestore.collection('bookings').doc(bookingId).get();

      // Nếu tài liệu không tồn tại, in ra thông báo lỗi
      if (!bookingSnapshot.exists) {
        print('Booking with ID $bookingId does not exist.');
        return;
      }

      // Nếu tài liệu tồn tại, cập nhật isHide
      await _firestore.collection('bookings').doc(bookingId).update({
        'isHide': true,
        'isAccept': false,
      });
      print('Booking $bookingId has been successfully hidden.');
    } catch (e) {
      print('Error updating booking: $e');
    }
  }

  // Cập nhật thuộc tính isHide của booking
  Future<void> updateBooking(String bookingId) async {
    try {
      // Kiểm tra nếu booking tồn tại
      DocumentSnapshot bookingSnapshot =
          await _firestore.collection('bookings').doc(bookingId).get();

      // Nếu tài liệu không tồn tại, in ra thông báo lỗi
      if (!bookingSnapshot.exists) {
        print('Booking with ID $bookingId does not exist.');
        return;
      }

      // Nếu tài liệu tồn tại, cập nhật isHide
      await _firestore.collection('bookings').doc(bookingId).update({
        'isHide': true,
      });
      print('Booking $bookingId has been successfully hidden.');
    } catch (e) {
      print('Error updating booking: $e');
    }
  }
}
