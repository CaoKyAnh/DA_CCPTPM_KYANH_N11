import 'package:final_project_rent_moto_fe/widgets/rent_home/rent_home_search_by_location.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firebase data

class RentHomeFeaturedLocation extends StatelessWidget {
  RentHomeFeaturedLocation({super.key});

  final List<String> images = [
    'assets/images/quan1.png',
    'assets/images/q2.png',
    'assets/images/q3.png',
    'assets/images/q4.png',
    'assets/images/quan5.png',
    'assets/images/q6.png',
    'assets/images/q7.png',
    'assets/images/q8.png',
    'assets/images/q10.png',
    'assets/images/q11.png',
    'assets/images/q12.png',
    'assets/images/qgv.png',
    'assets/images/qtb.png',
    'assets/images/qbt.png',
    'assets/images/qbinhthanh.png',
    'assets/images/qtp.png',
    'assets/images/qpn.png',
  ];

  final List<String> locations = [
    'Quận 1',
    'Thành phố Thủ Đức',
    'Quận 3',
    'Quận 4',
    'Quận 5',
    'Quận 6',
    'Quận 7',
    'Quận 8',
    'Quận 10',
    'Quận 11',
    'Quận 12',
    'Quận Gò Vấp',
    'Quận Tân Bình',
    'Quận Bình Tân',
    'Quận Bình Thạnh',
    'Quận Tân Phú',
    'Quận Phú Nhuận',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20), // Cách đáy 20px
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Căn trái các phần tử
        children: [
          const Text(
            "Địa điểm nổi bật",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5), // Khoảng cách giữa tiêu đề và ảnh
          // SingleChildScrollView cho phép lướt qua các khung ảnh theo chiều ngang
          SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Lướt ngang
            child: Row(
              children: List.generate(images.length, (index) {
                return GestureDetector(
                  onTap: () {
                    // Chuyển hướng đến màn hình chi tiết quận
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RentHomeSearchByLocation(
                            location: locations[index]),
                      ),
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.45,
                    margin: const EdgeInsets.only(
                        right: 10), // Khoảng cách giữa các ảnh
                    height: 230, // Chiều cao của ảnh
                    child: ClipPath(
                      clipper:
                          DiagonalClipper(), // Dùng custom clipper để cắt ảnh chéo
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(13), // Bo tròn góc ảnh
                        child: Stack(
                          fit: StackFit
                              .expand, // Đảm bảo Stack chiếm toàn bộ không gian
                          children: [
                            Image.asset(
                              images[
                                  index], // Đọc đường dẫn ảnh từ danh sách images
                              fit: BoxFit.cover, // Đảm bảo ảnh phủ đầy khung
                            ),
                            Positioned(
                              bottom: 10, // Cách đáy 10px
                              left: 10, // Cách trái 10px
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                color: Colors.grey
                                    .withOpacity(0.6), // Nền mờ cho text
                                child: Text(
                                  locations[
                                      index], // Đọc tên địa điểm từ danh sách locations
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Fetch data from Firebase and display vehicles based on isHide
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('vehicles').get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              var vehicleData = snapshot.data!.docs;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: vehicleData.map((doc) {
                    var isHide =
                        doc['isHide']; // Assuming the field name is isHide
                    if (isHide) {
                      return Container(); // Skip rendering if isHide is true
                    }

                    // Render vehicle item
                    String image = doc['image'] ??
                        'assets/images/default.png'; // Example image path
                    String location = doc['location'] ??
                        'Unknown Location'; // Example location
                    return GestureDetector(
                      onTap: () {
                        // Handle vehicle detail navigation
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        margin: const EdgeInsets.only(right: 10),
                        height: 230,
                        child: ClipPath(
                          clipper: DiagonalClipper(),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  image,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  bottom: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    color: Colors.grey.withOpacity(0.6),
                                    child: Text(
                                      location,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DiagonalClipper extends CustomClipper<Path> {
  final double cutPercentageX;
  final double cutPercentageY;

  DiagonalClipper({
    this.cutPercentageX = 1 / 3,
    this.cutPercentageY = 1 / 3,
  });

  @override
  Path getClip(Size size) {
    Path path = Path();
    double cutPointX = size.width * cutPercentageX;
    double cutPointY = size.height * cutPercentageY;

    path.moveTo(0, 0);
    path.lineTo(size.width - cutPointX, 0);
    path.lineTo(size.width, cutPointY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
