import 'package:final_project_rent_moto_fe/services/auth/sendmail_service.dart';
import 'package:flutter/material.dart';

class DenyMotorRentalPostScreen extends StatefulWidget {
  final String email;
  const DenyMotorRentalPostScreen({super.key, required this.email});

  @override
  State<DenyMotorRentalPostScreen> createState() =>
      _DenyMotorRentalPostScreenState();
}

class _DenyMotorRentalPostScreenState extends State<DenyMotorRentalPostScreen> {
  final TextEditingController reasonController = TextEditingController();
  final SendMailService sendMailService = SendMailService();

  void _confirmDeny() async {
    String reason = reasonController.text.trim();

    if (reason.isEmpty) {
      // Hiển thị thông báo nếu lý do chưa được nhập
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập lý do từ chối!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Gọi hàm gửi lý do qua email
    await sendMailService.sendReasonByMail(context, widget.email, reason);

    // Xóa dữ liệu và quay lại màn hình trước
    reasonController.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text("Lý do từ chối duyệt xe"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 5,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
                child: TextFormField(
                  controller: reasonController,
                  maxLines: 5, // Cho phép nhập nhiều dòng
                  decoration: InputDecoration(
                    labelText: 'Lý do từ chối',
                    hintText: 'Nhập lý do từ chối',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _confirmDeny,
                child: const Text(
                  "XÁC NHẬN",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
