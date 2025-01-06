import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FormSelectDayMonthYear extends StatefulWidget {
  final Function(String) onDateSelected;
  final String initialDate;

  const FormSelectDayMonthYear({
    super.key,
    required this.onDateSelected,
    required this.initialDate,
  });

  @override
  State<FormSelectDayMonthYear> createState() => _FormSelectDayMonthYearState();
}

class _FormSelectDayMonthYearState extends State<FormSelectDayMonthYear> {
  int selectedDay = 1;
  int selectedMonth = 1;
  int selectedYear = 2024;

  late FixedExtentScrollController dayController;
  late FixedExtentScrollController monthController;
  late FixedExtentScrollController yearController;

  @override
  void initState() {
    super.initState();
    // Tách giá trị ngày từ initialDate
    List<String> dateParts = widget.initialDate.split('-');
    selectedDay = int.parse(dateParts[0]);
    selectedMonth = int.parse(dateParts[1]);
    selectedYear = int.parse(dateParts[2]);

    // Thiết lập controller với giá trị đã chọn ban đầu
    dayController = FixedExtentScrollController(initialItem: selectedDay - 1);
    monthController =
        FixedExtentScrollController(initialItem: selectedMonth - 1);
    yearController =
        FixedExtentScrollController(initialItem: selectedYear - 1900);
  }

  // Hàm kiểm tra năm nhuận
  bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  // Hàm trả về số ngày trong tháng
  int getDaysInMonth(int month, int year) {
    switch (month) {
      case 1: // Tháng 1
      case 3: // Tháng 3
      case 5: // Tháng 5
      case 7: // Tháng 7
      case 8: // Tháng 8
      case 10: // Tháng 10
      case 12: // Tháng 12
        return 31;
      case 4: // Tháng 4
      case 6: // Tháng 6
      case 9: // Tháng 9
      case 11: // Tháng 11
        return 30;
      case 2: // Tháng 2
        return isLeapYear(year)
            ? 29
            : 28; // Tháng 2 có 29 ngày nếu là năm nhuận
      default:
        return 0; // Trả về 0 cho tháng không hợp lệ
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 300,
        width: 250,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "Đặt ngày",
                style: TextStyle(
                  decoration: TextDecoration.none,
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  // Day Picker
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: dayController,
                      itemExtent: 60,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedDay = (index %
                                  getDaysInMonth(selectedMonth, selectedYear)) +
                              1;
                        });
                      },
                      children: List<Widget>.generate(
                          getDaysInMonth(selectedMonth, selectedYear), (index) {
                        return Center(
                          child: Text(
                            (index + 1).toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Month Picker
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: monthController,
                      itemExtent: 60,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedMonth = index + 1;
                          selectedDay = selectedDay >
                                  getDaysInMonth(selectedMonth, selectedYear)
                              ? getDaysInMonth(selectedMonth, selectedYear)
                              : selectedDay;
                          dayController.jumpToItem(selectedDay -
                              1); // Cập nhật ngày khi tháng thay đổi
                        });
                      },
                      children: List<Widget>.generate(12, (index) {
                        return Center(
                          child: Text(
                            "Th${index + 1}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Year Picker
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: yearController,
                      itemExtent: 60,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedYear = 1900 + index;
                          selectedDay = selectedDay >
                                  getDaysInMonth(selectedMonth, selectedYear)
                              ? getDaysInMonth(selectedMonth, selectedYear)
                              : selectedDay;
                          dayController.jumpToItem(selectedDay -
                              1); // Cập nhật ngày khi năm thay đổi
                        });
                      },
                      children: List<Widget>.generate(
                          DateTime.now().year - 1900 + 1, (index) {
                        return Center(
                          child: Text(
                            (1900 + index).toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onDateSelected(
                    '$selectedDay-${selectedMonth.toString().padLeft(2, '0')}-$selectedYear');
              },
              child: const Text('Đặt'),
            ),
          ],
        ),
      ),
    );
  }
}
