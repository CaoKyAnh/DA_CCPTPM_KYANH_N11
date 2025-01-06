// ignore_for_file: library_private_types_in_public_api

import 'package:final_project_rent_moto_fe/services/categoryMoto/update_category_service.dart';
import 'package:flutter/material.dart';

class UpdateCategoryScreen extends StatefulWidget {
  final String id;
  final String currentName;
  final bool currentIsHide;
  final Function(String, String, bool) onUpdate;

  const UpdateCategoryScreen({
    super.key,
    required this.id,
    required this.currentName,
    required this.currentIsHide,
    required this.onUpdate,
  });

  @override
  _UpdateCategoryScreenState createState() => _UpdateCategoryScreenState();
}

class _UpdateCategoryScreenState extends State<UpdateCategoryScreen> {
  late TextEditingController nameController;
  late bool isHide;
  bool isLoading = false; // Thêm biến trạng thái để theo dõi quá trình tải

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    isHide = widget.currentIsHide; // Khởi tạo trạng thái ban đầu
  }

  @override
  void dispose() {
    nameController.dispose(); // Giải phóng bộ điều khiển khi widget bị loại bỏ
    super.dispose();
  }

  // Hàm cập nhật danh mục
  Future<void> updateCategory() async {
    setState(() {
      isLoading =
          true; // Đặt isLoading thành true khi bắt đầu quá trình cập nhật
    });

    try {
      // Gọi dịch vụ để cập nhật
      final updateService = UpdateCategoryService();
      await updateService.updateCategoryMoto(
          widget.id, nameController.text, isHide);

      // Sau khi cập nhật thành công, gọi hàm onUpdate và đóng dialog
      widget.onUpdate(widget.id, nameController.text, isHide);
      Navigator.of(context).pop();

      // Hiển thị thông báo thành công
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Category updated successfully!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng thông báo thành công
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Nếu có lỗi, hiển thị thông báo lỗi
      setState(() {
        isLoading = false; // Đặt isLoading về false nếu có lỗi
      });

      // Hiển thị thông báo lỗi
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to update category: $e'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng thông báo lỗi
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Update Category Motto',
        style: TextStyle(color: Colors.blue), // Màu tiêu đề
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Category Name'),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text(
              'Hidden',
              style: TextStyle(color: Colors.blue),
            ),
            value: isHide,
            onChanged: (value) {
              setState(() {
                isHide =
                    value; // Cập nhật trạng thái isHide khi người dùng thay đổi
              });
            },
            activeColor: Colors.blue, // Tùy chỉnh màu sắc khi bật
            inactiveThumbColor: Colors.grey, // Tùy chỉnh màu sắc khi tắt
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Đóng dialog khi hủy
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            backgroundColor: Colors.grey[300], // Màu nền cho nút hủy
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.blue), // Màu chữ cho nút hủy
          ),
        ),
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  // Khi đang tải, nút Update sẽ bị vô hiệu hóa
                  updateCategory();
                },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            backgroundColor: Colors.blue, // Màu nền cho nút cập nhật
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white, // Vòng tròn tải với màu trắng
                )
              : const Text(
                  'Update',
                  style:
                      TextStyle(color: Colors.white), // Màu chữ cho nút Update
                ),
        ),
      ],
    );
  }
}
