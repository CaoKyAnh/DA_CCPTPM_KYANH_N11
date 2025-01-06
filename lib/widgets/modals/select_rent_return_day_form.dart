import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelectRentReturnDayForm extends StatefulWidget {
  final Function(String, String) onSave; // Callback for save action
  final String initialPickupTime; // Tham số mới cho thời gian lấy xe
  final String initialReturnTime; // Tham số mới cho thời gian trả xe

  const SelectRentReturnDayForm({
    super.key,
    required this.onSave,
    required this.initialPickupTime,
    required this.initialReturnTime,
  });

  @override
  State<SelectRentReturnDayForm> createState() =>
      _SelectRentReturnDayFormState();
}

class _SelectRentReturnDayFormState extends State<SelectRentReturnDayForm> {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController returnController = TextEditingController();

  final List<String> times = List.generate(
    48,
    (index) => '${index ~/ 2}:${index % 2 == 0 ? '00' : '30'}',
  );

  int selectedPickupIndex = 0;
  int selectedReturnIndex = 0;

  @override
  void initState() {
    super.initState();

    // Tìm chỉ số của thời gian lấy và trả xe
    selectedPickupIndex = times.indexOf(widget.initialPickupTime);
    selectedReturnIndex = times.indexOf(widget.initialReturnTime);

    // Gán giá trị cho các TextEditingController
    pickupController.text = widget.initialPickupTime;
    returnController.text = widget.initialReturnTime;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            height: 40,
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.cancel_outlined,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Rental moto',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 100,
                      child: CupertinoPicker(
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(
                            initialItem: selectedPickupIndex),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedPickupIndex = index;
                            pickupController.text = times[index];
                          });
                        },
                        children: times
                            .map((time) => Center(child: Text(time)))
                            .toList(),
                      ),
                    ),
                    Visibility(
                      visible: false,
                      child: TextField(
                        controller: pickupController,
                        readOnly: true,
                        textAlign: TextAlign.center,
                        decoration:
                            const InputDecoration(border: InputBorder.none),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'Return moto',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 100,
                      child: CupertinoPicker(
                        itemExtent: 32,
                        scrollController: FixedExtentScrollController(
                            initialItem: selectedReturnIndex),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedReturnIndex = index;
                            returnController.text = times[index];
                          });
                        },
                        children: times
                            .map((time) => Center(child: Text(time)))
                            .toList(),
                      ),
                    ),
                    Visibility(
                      visible: false,
                      child: TextField(
                        controller: returnController,
                        readOnly: true,
                        textAlign: TextAlign.center,
                        decoration:
                            const InputDecoration(border: InputBorder.none),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 40,
            width: 450,
            decoration: const BoxDecoration(
              color: Color(0xFFFFAD15),
            ),
            child: TextButton(
              onPressed: () {
                String pickupTime = pickupController.text;
                String returnTime = returnController.text;

                widget.onSave(pickupTime, returnTime);
                Navigator.pop(context);
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
