import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PromoUpdateScreen extends StatefulWidget {
  final String documentId;

  PromoUpdateScreen({super.key, required this.documentId});

  @override
  _PromoUpdateScreenState createState() => _PromoUpdateScreenState();
}

class _PromoUpdateScreenState extends State<PromoUpdateScreen> {
  late Map<String, dynamic> promoData;
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _imageUrl;
  bool _isHide = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getPromoData();
  }

  Future<void> _getPromoData() async {
    try {
      DocumentSnapshot promoSnapshot = await FirebaseFirestore.instance
          .collection('promotions')
          .doc(widget.documentId)
          .get();

      if (promoSnapshot.exists) {
        promoData = promoSnapshot.data() as Map<String, dynamic>;
        DateTime currentDate = DateTime.now();

        setState(() {
          _startDate = DateTime.parse(promoData['startDate']);
          _endDate = DateTime.parse(promoData['endDate']);
          _imageUrl = promoData['imageUrl'];
          _isHide = promoData['isHide'] ?? false;

          // Nếu khuyến mãi đã hết hạn, chỉ cập nhật trạng thái `isHide`
          if (_endDate!.isBefore(currentDate) && !_isHide) {
            _isHide = true;
            promoData['isHide'] = true;

            // Lưu trạng thái mới vào Firestore
            _updatePromo({'isHide': true});
          }

          isLoading = false;
        });
      } else {
        _showSnackbar("Khuyến mãi không tồn tại!");
      }
    } catch (e) {
      _showSnackbar("Lỗi khi tải dữ liệu: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String fileName = pickedFile.name;
      try {
        Reference storageReference =
            FirebaseStorage.instance.ref().child('promo_images/$fileName');
        await storageReference.putFile(File(pickedFile.path));

        String imageUrl = await storageReference.getDownloadURL();

        setState(() {
          _imageUrl = imageUrl;
          promoData['imageUrl'] = imageUrl;
        });
      } catch (e) {
        _showSnackbar("Lỗi khi tải lên hình ảnh: $e");
      }
    }
  }

  void _updatePromo(Map<String, dynamic> updatedData) async {
    try {
      // Kiểm tra ngày kết thúc
      if (_endDate != null && _endDate!.isBefore(DateTime.now())) {
        updatedData['isHide'] = true;
      }

      await FirebaseFirestore.instance
          .collection('promotions')
          .doc(widget.documentId)
          .update(updatedData);

      _showSnackbar("Cập nhật khuyến mãi thành công!");
      Navigator.pop(context);
    } catch (e) {
      _showSnackbar("Lỗi khi cập nhật: $e");
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? currentDate,
      firstDate: currentDate,
      lastDate: DateTime(currentDate.year + 5),
    );
    if (selectedDate != null) {
      setState(() {
        _startDate = selectedDate;
        promoData['startDate'] = DateFormat('yyyy-MM-dd').format(_startDate!);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Vui lòng chọn ngày bắt đầu trước"),
      ));
      return;
    }

    DateTime currentDate = DateTime.now(); // Ngày hiện tại
    DateTime firstValidDate =
        _startDate!.isAfter(currentDate) ? _startDate! : currentDate;

    DateTime? selectedEndDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? firstValidDate,
      firstDate:
          firstValidDate, // Ngày kết thúc không được trước ngày bắt đầu và ngày hiện tại
      lastDate: DateTime(currentDate.year + 5),
    );

    if (selectedEndDate != null && selectedEndDate != _endDate) {
      setState(() {
        _endDate = selectedEndDate;
        promoData['endDate'] = DateFormat('yyyy-MM-dd').format(_endDate!);
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cập nhật khuyến mãi")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: promoData['name'],
                        decoration:
                            InputDecoration(labelText: 'Tên khuyến mãi'),
                        onChanged: (value) => promoData['name'] = value,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Vui lòng nhập tên khuyến mãi'
                            : null,
                      ),
                      TextFormField(
                        initialValue: promoData['code'],
                        decoration: InputDecoration(labelText: 'Mã khuyến mãi'),
                        onChanged: (value) => promoData['code'] = value,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Vui lòng nhập mã khuyến mãi'
                            : null,
                      ),
                      TextFormField(
                        initialValue: promoData['discount'].toString(),
                        decoration: InputDecoration(labelText: 'Giảm giá (%)'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) =>
                            promoData['discount'] = int.tryParse(value) ?? 0,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Vui lòng nhập tỷ lệ giảm giá'
                            : null,
                      ),
                      GestureDetector(
                        onTap: () => _selectStartDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: TextEditingController(
                              text: _startDate == null
                                  ? 'Chọn ngày bắt đầu'
                                  : DateFormat('yyyy-MM-dd')
                                      .format(_startDate!),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Ngày bắt đầu',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _selectEndDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: TextEditingController(
                              text: _endDate == null
                                  ? 'Chọn ngày kết thúc'
                                  : DateFormat('yyyy-MM-dd').format(_endDate!),
                            ),
                            decoration: InputDecoration(
                              labelText: 'Ngày kết thúc',
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      _imageUrl == null
                          ? Text("Chưa có hình ảnh")
                          : Image.network(_imageUrl!),
                      ElevatedButton(
                        onPressed: _pickImage,
                        child: Text("Chọn hình ảnh mới"),
                      ),
                      SizedBox(height: 20),
                      SwitchListTile(
                        title: Text("Ẩn khuyến mãi"),
                        value: _isHide,
                        onChanged: (value) {
                          setState(() {
                            _isHide = value;
                            promoData['isHide'] = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _updatePromo(promoData);
                          }
                        },
                        child: Text("Cập nhật"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
