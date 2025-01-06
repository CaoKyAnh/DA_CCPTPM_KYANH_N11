import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input validation
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_rent_moto_fe/services/promoByCompany/add_promoByCompany_service.dart';

class PromobycompayAddScreen extends StatefulWidget {
  const PromobycompayAddScreen({super.key});

  @override
  State<PromobycompayAddScreen> createState() => _PromobycompayAddScreenState();
}

class _PromobycompayAddScreenState extends State<PromobycompayAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _promoNameController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  bool _isHide = false;
  List<String> companyMotos = [];
  String? selectedCompanyMoto;

  DateTime? selectedStartDate; // Chỉ định null ban đầu
  DateTime? selectedEndDate; // Chỉ định null ban đầu

  @override
  void initState() {
    super.initState();
    _fetchCompanyMotos();
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
        SnackBar(content: Text('Lỗi khi tải dữ liệu loại xe: $e')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = isStartDate
        ? (selectedStartDate ?? now)
        : (selectedEndDate ?? (selectedStartDate ?? now));
    final DateTime firstDate = isStartDate ? now : (selectedStartDate ?? now);
    final DateTime lastDate = isStartDate
        ? DateTime(2100)
        : (selectedStartDate?.add(const Duration(days: 365)) ?? DateTime(2100));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          selectedStartDate = picked;
          _startDateController.text =
              "${picked.day}/${picked.month}/${picked.year}";
          // Reset end date if it's before the new start date
          if (selectedEndDate != null && selectedEndDate!.isBefore(picked)) {
            selectedEndDate = picked.add(const Duration(days: 1));
            _endDateController.text =
                "${selectedEndDate!.day}/${selectedEndDate!.month}/${selectedEndDate!.year}";
          }
        } else {
          selectedEndDate = picked;
          _endDateController.text =
              "${picked.day}/${picked.month}/${picked.year}";
        }
      });
    }
  }

  Future<void> _addPromotion() async {
    if (_formKey.currentState?.validate() ?? false) {
      final companyMoto = selectedCompanyMoto;
      final promoName = _promoNameController.text.trim();
      final percentage = double.tryParse(_percentageController.text) ?? 0;

      if (companyMoto == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn loại xe')),
        );
        return;
      }

      if (selectedStartDate == null || selectedEndDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Vui lòng chọn ngày bắt đầu và kết thúc')),
        );
        return;
      }

      if (selectedEndDate!.isBefore(selectedStartDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ngày kết thúc phải sau ngày bắt đầu')),
        );
        return;
      }

      final result = await addPromoByCompany(
        companyMoto: companyMoto,
        promoName: promoName,
        percentage: percentage,
        startDate: selectedStartDate!.toIso8601String(),
        endDate: selectedEndDate!.toIso8601String(),
        isHide: _isHide,
      );

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm khuyến mãi thành công!')),
        );
        Navigator.pop(context); // Quay lại sau khi thêm thành công
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể thêm khuyến mãi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm Khuyến Mãi Theo Loại Xe"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: selectedCompanyMoto,
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
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên khuyến mãi';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _percentageController,
                decoration:
                    const InputDecoration(labelText: 'Phần trăm khuyến mãi'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập phần trăm khuyến mãi';
                  }
                  final percentage = double.tryParse(value);
                  if (percentage == null ||
                      percentage < 0 ||
                      percentage > 100) {
                    return 'Vui lòng nhập phần trăm khuyến mãi từ 0 đến 100';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _startDateController,
                decoration: const InputDecoration(labelText: 'Ngày Bắt Đầu'),
                readOnly: true,
                onTap: () => _selectDate(context, true),
              ),
              TextFormField(
                controller: _endDateController,
                decoration: const InputDecoration(labelText: 'Ngày Kết Thúc'),
                readOnly: true,
                onTap: () => _selectDate(context, false),
              ),
              SwitchListTile(
                title: const Text('Ẩn khuyến mãi'),
                value: _isHide,
                onChanged: (bool value) {
                  setState(() {
                    _isHide = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addPromotion,
                child: const Text('Thêm Khuyến Mãi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
