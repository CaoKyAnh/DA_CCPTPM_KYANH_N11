import 'package:flutter/material.dart';
import 'package:final_project_rent_moto_fe/widgets/modals/form_day_month_year.dart';

class SignupEnterInforDateText extends StatefulWidget {
  final TextEditingController controllerDate;
  const SignupEnterInforDateText({super.key, required this.controllerDate});

  @override
  State<SignupEnterInforDateText> createState() =>
      _SignupEnterInforDateTextState();
}

class _SignupEnterInforDateTextState extends State<SignupEnterInforDateText> {
  String selectedDate = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DateTime now = DateTime.now();
    // Gán giá trị mặc định với định dạng dd-mm-yyyy
    selectedDate =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    widget.controllerDate.text = selectedDate;
  }

  void _showDatePicker() {
    showDialog(
      context: context,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: FormSelectDayMonthYear(
            onDateSelected: (date) {
              setState(() {
                selectedDate = date; // Cập nhật giá trị đã chọn
                widget.controllerDate.text =
                    selectedDate; // Cập nhật giá trị cho TextFormField
              });
              Navigator.pop(context);
            },
            initialDate: selectedDate, // Truyền giá trị đã chọn vào đây
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFA500).withOpacity(0.5),
            offset: const Offset(-2, -2),
            blurRadius: 15,
          ),
          BoxShadow(
            color: const Color(0xFFDA70D6).withOpacity(0.5),
            offset: const Offset(2, 2),
            blurRadius: 15,
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controllerDate,
        decoration: InputDecoration(
          labelText: "Ngày sinh",
          labelStyle: TextStyle(
              color: Colors.black.withOpacity(0.8),
              fontWeight: FontWeight.w500),
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          suffixIcon: IconButton(
            // Thay đổi từ Icon thành IconButton
            icon: const Icon(Icons.calendar_today),
            onPressed: () => {_showDatePicker()}, // Gọi hàm toggle khi nhấn
          ),
        ),
      ),
    );
  }
}
