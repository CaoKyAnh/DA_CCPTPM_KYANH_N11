// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:final_project_rent_moto_fe/widgets/modals/select_rent_return_day_form.dart';

typedef OnDateSelectedCallback = void Function(DateTime pickupDate,
    DateTime returnDate, String pickupTime, String returnTime);

class BookingScreen extends StatefulWidget {
  final DateTime pickupDate; // Ngày thuê
  final DateTime returnDate; // Ngày trả
  final String pickupTime;
  final String returnTime;
  final OnDateSelectedCallback onDateSelected;
  const BookingScreen({
    super.key,
    required this.pickupDate,
    required this.returnDate,
    required this.pickupTime,
    required this.returnTime,
    required this.onDateSelected,
  });
  @override
  // ignore: library_private_types_in_public_api
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime selectedPickupDate;
  DateTime? selectedReturnDate;
  String selectedPickupTime = '';
  String selectedReturnTime = '';
  late DateTime tempPickupDate;
  DateTime? tempReturnDate;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    // Gán giá trị từ constructor

    selectedPickupDate = widget.pickupDate;
    selectedReturnDate = widget.returnDate;
    tempPickupDate = selectedPickupDate;
    tempReturnDate = selectedReturnDate!;
    selectedPickupTime = widget.pickupTime;
    selectedReturnTime = widget.returnTime;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  int daysInMonth(int month, int year) {
    if (month == 2) {
      return isLeapYear(year) ? 29 : 28;
    }
    if ([4, 6, 9, 11].contains(month)) {
      return 30;
    }
    return 31;
  }

  void _changeMonth(int increment) {
    setState(() {
      int newMonth = selectedPickupDate.month + increment;
      int newYear = selectedPickupDate.year;

      if (newMonth < 1) {
        newMonth = 12;
        newYear -= 1;
      } else if (newMonth > 12) {
        newMonth = 1;
        newYear += 1;
      }

      if (newMonth == DateTime.now().month && newYear == DateTime.now().year) {
        selectedPickupDate = DateTime.now();
      } else {
        selectedPickupDate = DateTime(newYear, newMonth, 1);
      }
      selectedReturnDate = null; // Reset ngày trả khi thay đổi tháng
    });
  }

  List<String> getWeekdays() {
    return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
  }

  void _selectDate(DateTime date) {
    setState(() {
      if (selectedReturnDate == null) {
        if (date.isAfter(selectedPickupDate)) {
          selectedReturnDate = date;
          tempReturnDate = date;
        } else {
          selectedPickupDate = date;
          tempPickupDate = date;
          selectedReturnDate = null;
          tempReturnDate = null;
        }
      } else {
        selectedPickupDate = date;
        tempPickupDate = date;
        selectedReturnDate = null;
        tempReturnDate = null;
      }
    });
  }

  bool isBetweenSelectedDates(DateTime date) {
    if (tempReturnDate == null) return false;
    return date.isAfter(tempPickupDate) && date.isBefore(tempReturnDate!);
  }

  void _showSelectRentReturnDayForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép cuộn nội dung
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height *
              0.35, // Chiều cao 30% màn hình
          child: SelectRentReturnDayForm(
            onSave: (pickupTime, returnTime) {
              // Cập nhật selectedPickupTime và selectedReturnTime
              setState(() {
                selectedPickupTime = pickupTime;
                selectedReturnTime = returnTime;
              });
            },
            initialPickupTime: selectedPickupTime, // Truyền thời gian lấy
            initialReturnTime: selectedReturnTime, // Truyền thời gian trả
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int daysInSelectedMonth =
        daysInMonth(selectedPickupDate.month, selectedPickupDate.year);
    DateTime firstDayOfMonth =
        DateTime(selectedPickupDate.year, selectedPickupDate.month, 1);
    int firstWeekday = firstDayOfMonth.weekday;

    bool isCurrentMonth = selectedPickupDate.year == DateTime.now().year &&
        selectedPickupDate.month == DateTime.now().month;
    int rentalDays = tempReturnDate != null
        ? tempReturnDate!.difference(tempPickupDate).inDays
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thời gian"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Thuê xe theo ngày"),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isCurrentMonth)
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => _changeMonth(-1),
                  ),
                Text(
                  "Tháng ${selectedPickupDate.month}, ${selectedPickupDate.year}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: getWeekdays().map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: daysInSelectedMonth + (firstWeekday - 1),
              itemBuilder: (context, index) {
                if (index < firstWeekday - 1) {
                  return Container();
                }
                final day = index - (firstWeekday - 2);
                DateTime currentDay = DateTime(
                    selectedPickupDate.year, selectedPickupDate.month, day);
                // Các điều kiện để xác định màu sắc ngày

                bool isSelectedPickup = currentDay == tempPickupDate;
                bool isSelectedReturn =
                    tempReturnDate != null && currentDay == tempReturnDate;
                bool isBeforeToday = currentDay
                    .isBefore(DateTime.now().subtract(const Duration(days: 1)));
                bool isBetween = isBetweenSelectedDates(currentDay);

                return GestureDetector(
                  onTap: () {
                    if (!isBeforeToday ||
                        currentDay.day == DateTime.now().day) {
                      _selectDate(currentDay);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelectedPickup
                          ? const Color(
                              0xFFFFAD15) // Màu ưu tiên cao nhất cho ngày pickup
                          // Màu cho ngày return nếu không phải là pickup
                          : isBetween
                              ? const Color.fromARGB(255, 251, 206, 123)
                              : isSelectedReturn
                                  ? const Color(
                                      0xFFFFAD15) // Màu cho ngày giữa pickup và return
                                  : isBeforeToday
                                      ? Colors
                                          .grey // Màu cho ngày trước hôm nay
                                      : Colors.grey[200],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Center(
                      child: Text(
                        "$day",
                        style: TextStyle(
                          color: isSelectedPickup ||
                                  isSelectedReturn ||
                                  isBetween
                              ? Colors.white
                              : (isBeforeToday ? Colors.white : Colors.black),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(width: 0.1),
                  ),
                  child: TextButton(
                    onPressed: () {
                      _showSelectRentReturnDayForm();
                    },
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Rental moto',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              selectedPickupTime,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                        const SizedBox(width: 40),
                        const Icon(Icons.arrow_drop_down, color: Colors.black),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(width: 0.1),
                  ),
                  child: TextButton(
                    onPressed: () {
                      _showSelectRentReturnDayForm();
                    },
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Return moto',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              selectedReturnTime,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black),
                            ),
                          ],
                        ),
                        const SizedBox(width: 40),
                        const Icon(Icons.arrow_drop_down, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(width: 0.2, color: Colors.black87),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: const BoxDecoration(),
                      child: Text(
                        "$selectedPickupTime, ${tempPickupDate.day}/${tempPickupDate.month}/${tempPickupDate.year} - $selectedReturnTime, ${tempReturnDate?.day ?? ''}/${tempReturnDate?.month ?? ''}/${tempReturnDate?.year ?? ''}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                    Row(
                      children: [
                        const Text(
                          'Numbers of rental days: ',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                              color: Colors.black),
                        ),
                        Text(
                          '$rentalDays day ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                            color: Color(0xFFFFAD15),
                          ),
                        ),
                        const Icon(
                          Icons.question_mark_outlined,
                          size: 10,
                        )
                      ],
                    )
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFAD15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton(
                    onPressed: () {
                      widget.onDateSelected(
                        tempPickupDate,
                        tempReturnDate ?? tempPickupDate,
                        selectedPickupTime,
                        selectedReturnTime,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Continue",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
