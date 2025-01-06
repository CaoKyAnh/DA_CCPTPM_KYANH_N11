import 'package:final_project_rent_moto_fe/screens/dashboard.dart';
import 'package:final_project_rent_moto_fe/services/motorCycle/motorcycle_service.dart';
import 'package:final_project_rent_moto_fe/services/review/add_review_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {
  final String numberPlate;
  const ReviewScreen({super.key, required this.numberPlate});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int rating = 0;
  final _controllerComment = TextEditingController();
  final _addReviewService = AddReviewService();
  // Thông tin xe máy
  final MotorcycleService _motorcycleService = MotorcycleService();
  Map<String, dynamic>? motorcycleData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadMotorcycleData();
  }

  void updateRating(int newRating) {
    setState(() {
      rating = newRating;
    });
  }

  Future<void> _loadMotorcycleData() async {
    Map<String, dynamic>? data =
        await _motorcycleService.getMotorcycleByNumberPlate(widget.numberPlate);
    setState(() {
      motorcycleData = data;
    });
  }

  void _addReview() {
    try {
      String? email = FirebaseAuth.instance.currentUser?.email;
      if (email != null) {
        _addReviewService.addReview(
          email,
          widget.numberPlate,
          rating,
          _controllerComment.text.trim(),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const Dashboard(initialIndex: 1), // Chỉ số UserInforScreen
          ),
        );
        print("Đánh giá thành công");
      } else {
        print("Đánh giá không thành công");
      }
    } catch (e) {
      print("Không đánh giá được lỗi :$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Đánh giá",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFFFAD15),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        // Sử dụng SingleChildScrollView để cuộn màn hình khi mở bàn phím
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phần hiển thị thông tin xe máy
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hình ảnh xe
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: motorcycleData?['informationMoto']['images'] !=
                                    null &&
                                motorcycleData?['informationMoto']['images']
                                        [0] !=
                                    null &&
                                motorcycleData?['informationMoto']['images'][0]
                                    .isNotEmpty
                            ? Image.network(
                                motorcycleData?['informationMoto']['images'][0],
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child; // Hình ảnh đã tải xong
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null, // Hiển thị tiến trình tải
                                    ),
                                  );
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  return Center(
                                    child: Text(
                                      'Không thể tải ảnh',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ); // Xử lý khi URL không hợp lệ
                                },
                              )
                            : Center(
                                child:
                                    CircularProgressIndicator(), // Hiển thị loading nếu `images` là null
                              ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Thông tin xe máy",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                          "Mẫu xe: ${motorcycleData?['informationMoto']['nameMoto'] ?? 'Không có'}"),
                      Text(
                          "Biển số: ${motorcycleData?['numberPlate'] ?? 'Không có'}"),
                      Text(
                          "Loại xe: ${motorcycleData?['category']['name'] ?? 'Không có'}"),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Phần đánh giá sao
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      Icons.star,
                      color: index < rating ? Colors.yellow : Colors.grey,
                      size: 40,
                    ),
                    onPressed: () => updateRating(index + 1),
                  );
                }),
              ),
              SizedBox(height: 20),

              // Phần nhập bình luận
              TextFormField(
                controller: _controllerComment,
                decoration: InputDecoration(
                  labelText: 'Viết đánh giá của bạn...',
                  border: OutlineInputBorder(),
                  hintText: 'Nhập ý kiến của bạn tại đây',
                ),
                maxLines: 4,
              ),
              SizedBox(height: 20),

              // Nút gửi đánh giá
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () {
                    // Xử lý khi người dùng gửi đánh giá
                    _addReview();
                  },
                  child: Text('Gửi Đánh Giá'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFAD15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
