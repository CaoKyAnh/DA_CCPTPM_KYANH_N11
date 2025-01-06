import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_rent_moto_fe/services/promoByCompany/edit_promoByCompany_service.dart';

class PromobycompanyEditScreen extends StatefulWidget {
  final String promoId; // ID của khuyến mãi để chỉnh sửa
  final Map<String, dynamic> promoData; // Dữ liệu khuyến mãi

  const PromobycompanyEditScreen({
    Key? key,
    required this.promoId,
    required this.promoData,
  }) : super(key: key);

  @override
  State<PromobycompanyEditScreen> createState() =>
      _PromobycompanyEditScreenState();
}

class _PromobycompanyEditScreenState extends State<PromobycompanyEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _promoNameController;
  late TextEditingController _percentageController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late bool _isHide;

  List<String> companyMotos = [];
  String? selectedCompanyMoto;

  @override
  void initState() {
    super.initState();
    _fetchCompanyMotos();

    // Định dạng ngày từ Firestore
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final startDate = DateTime.parse(widget.promoData['startDate']);
    final endDate = DateTime.parse(widget.promoData['endDate']);

    _promoNameController =
        TextEditingController(text: widget.promoData['promoName']);
    _percentageController =
        TextEditingController(text: widget.promoData['percentage'].toString());
    _startDateController =
        TextEditingController(text: formatter.format(startDate));
    _endDateController = TextEditingController(text: formatter.format(endDate));
    _isHide = widget.promoData['isHide'];

    // Gán tên loại xe đã chọn từ dữ liệu khuyến mãi
    selectedCompanyMoto = widget.promoData['companyMoto']['name'];
  }

  @override
  void dispose() {
    _promoNameController.dispose();
    _percentageController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _fetchCompanyMotos() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('companyMotos').get();
      setState(() {
        companyMotos =
            snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải dữ liệu loại xe: $e')));
    }
  }

  Future<DateTime?> _pickDate(TextEditingController controller) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Ngày nhỏ nhất là hôm nay
      lastDate: DateTime(2100), // Ngày lớn nhất
    );

    if (selectedDate != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      return selectedDate;
    }
    return null;
  }

  Future<void> _editPromotion() async {
    if (_formKey.currentState!.validate()) {
      final isSuccess = await editPromoByCompany(
        promoId: widget.promoId,
        companyMoto: selectedCompanyMoto!,
        promoName: _promoNameController.text,
        percentage: double.parse(_percentageController.text),
        startDate: _startDateController.text,
        endDate: _endDateController.text,
        isHide: _isHide,
      );

      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật khuyến mãi thành công!')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật khuyến mãi thất bại.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa khuyến mãi')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: selectedCompanyMoto, // Hiển thị tên loại xe đã chọn
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCompanyMoto = newValue;
                  });
                },
                decoration: const InputDecoration(labelText: 'Tên Loại Xe'),
                items: companyMotos.map((String companyMoto) {
                  return DropdownMenuItem<String>(
                    value: companyMoto,
                    child: Text(companyMoto),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn loại xe';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _promoNameController,
                decoration: const InputDecoration(labelText: 'Tên Khuyến mãi'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Vui lòng nhập tên khuyến mãi'
                    : null,
              ),
              TextFormField(
                controller: _percentageController,
                decoration:
                    const InputDecoration(labelText: 'Phần trăm khuyến mãi'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập phần trăm khuyến mãi';
                  }
                  final percentage = double.tryParse(value);
                  if (percentage == null ||
                      percentage < 0 ||
                      percentage > 100) {
                    return 'Phần trăm khuyến mãi phải từ 0 đến 100';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _startDateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Ngày Bắt Đầu'),
                onTap: () async {
                  final selectedDate = await _pickDate(_startDateController);
                  if (selectedDate != null) {
                    final endDate = _endDateController.text.isNotEmpty
                        ? DateTime.parse(_endDateController.text)
                        : null;

                    if (endDate != null && selectedDate.isAfter(endDate)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Ngày bắt đầu phải trước ngày kết thúc.'),
                        ),
                      );
                      _startDateController.clear();
                    }
                  }
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Vui lòng nhập ngày bắt đầu'
                    : null,
              ),
              TextFormField(
                controller: _endDateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Ngày Kết Thúc'),
                onTap: () async {
                  final selectedDate = await _pickDate(_endDateController);
                  if (selectedDate != null) {
                    final startDate = _startDateController.text.isNotEmpty
                        ? DateTime.parse(_startDateController.text)
                        : null;

                    if (startDate != null && selectedDate.isBefore(startDate)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ngày kết thúc phải sau ngày bắt đầu.'),
                        ),
                      );
                      _endDateController.clear();
                    }
                  }
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Vui lòng nhập ngày kết thúc'
                    : null,
              ),
              SwitchListTile(
                title: const Text('Ẩn khuyến mãi'),
                value: _isHide,
                onChanged: (value) => setState(() => _isHide = value),
              ),
              ElevatedButton(
                onPressed: _editPromotion,
                child: const Text('Lưu Thay Đổi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
