import 'package:final_project_rent_moto_fe/services/promoByCompany/applyPromoByCompany.dart'; // Import service applyPromoByCompanyService
import 'package:final_project_rent_moto_fe/screens/detail/detail_moto_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RentHomeSearchByLocation extends StatefulWidget {
  final String location;

  const RentHomeSearchByLocation({super.key, required this.location});

  @override
  State<RentHomeSearchByLocation> createState() =>
      _RentHomeSearchByLocationState();
}

class _RentHomeSearchByLocationState extends State<RentHomeSearchByLocation> {
  late Future<List<dynamic>> motorcyclesByLocation;
  final ApplyPromoByCompanyService _applyPromoService =
      ApplyPromoByCompanyService(); // Tạo đối tượng dịch vụ

  @override
  void initState() {
    super.initState();
    motorcyclesByLocation = fetchMotorcyclesByLocation(widget.location);
  }

  Future<List<dynamic>> fetchMotorcyclesByLocation(String district) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> motorcycles = [];

    try {
      // Tìm kiếm xe máy theo quận
      final districtSnapshot = await firestore
          .collection('motorcycles')
          .where('address.district', isEqualTo: district)
          .where('isHide', isEqualTo: false)
          .get();

      motorcycles = districtSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();

      // Nếu không có xe trong quận, tìm kiếm theo thành phố
      if (motorcycles.isEmpty) {
        final citySnapshot = await firestore
            .collection('motorcycles')
            .where('address.city', isEqualTo: district)
            .where('isHide', isEqualTo: false)
            .get();

        motorcycles = citySnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList();
      }

      // Tính toán giá sau khuyến mãi cho từng xe
      for (var motorcycle in motorcycles) {
        var info = motorcycle['informationMoto'] ?? {};
        double originalPrice = (info['price'] ?? 0.0).toDouble();
        double discountedPrice = originalPrice;

        // Gọi dịch vụ áp dụng khuyến mãi
        try {
          discountedPrice =
              await _applyPromoService.applyPromotion(motorcycle['id']);
        } catch (e) {
          print("Lỗi khi áp dụng khuyến mãi cho xe ${motorcycle['id']}: $e");
        }

        // Cập nhật giá đã tính vào dữ liệu
        motorcycle['discountedPrice'] = discountedPrice;
      }

      return motorcycles;
    } catch (e) {
      throw Exception("Error fetching motorcycles by location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Xe tại ${widget.location}"),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: motorcyclesByLocation,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var data = snapshot.data!;
            if (data.isEmpty) {
              return const Center(
                  child: Text('Không có xe nào tại địa điểm này.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: data.length,
              itemBuilder: (context, index) {
                var motorcycle = data[index];
                var info = motorcycle['informationMoto'] ?? {};
                var address = motorcycle['address'] ?? {};
                double originalPrice = (info['price'] ?? 0.0).toDouble();
                double discountedPrice =
                    motorcycle['discountedPrice'] ?? originalPrice;

                return InkWell(
                  onTap: () async {
                    // Điều hướng đến DetailMotoScreen và chờ kết quả trả về
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailMotoScreen(
                          motorcycle: motorcycle, // Truyền motorcycle vào
                        ),
                      ),
                    );

                    if (result != null &&
                        result['motorcycleId'] == motorcycle['id']) {
                      setState(() {
                        // Cập nhật trạng thái yêu thích dựa trên kết quả từ DetailMotoScreen
                        motorcycle['isFavorite'] = result['isFavorite'];
                      });
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        width: 0.2,
                        color: Colors.black,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sử dụng Stack để chồng phần trăm giảm giá lên hình ảnh
                          Stack(
                            children: [
                              // Hiển thị hình ảnh xe
                              Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    width: 0.2,
                                    color: Colors.black,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: (info['images'] != null &&
                                          info['images'].isNotEmpty)
                                      ? Image.network(
                                          info['images'][0],
                                          fit: BoxFit.contain,
                                        )
                                      : Image.asset(
                                          "assets/images/logo.png",
                                          fit: BoxFit.contain,
                                        ),
                                ),
                              ),

                              // Hiển thị nhãn khuyến mãi
                              if (motorcycle['discountedPrice'] !=
                                  originalPrice)
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Giảm ${(originalPrice - discountedPrice) / originalPrice * 100}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          // Hiển thị thông tin loại xe, tên xe, địa chỉ, và giá
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              info['nameMoto'] ?? "Automatic moto",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on),
                              const SizedBox(width: 5),
                              Text(
                                  "${address['district']}, ${address['city']}"),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(width: 1),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: const [
                                    // Đánh giá sao
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow,
                                          size: 30,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          "5.0",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 100),
                                    Row(
                                      children: [
                                        Icon(Icons.motorcycle),
                                        SizedBox(width: 5),
                                        Text(
                                          "10 chuyến",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Row(
                                    children: [
                                      if (motorcycle['discountedPrice'] !=
                                          originalPrice)
                                        Text(
                                          NumberFormat("#,###", "vi_VN")
                                              .format(originalPrice),
                                          style: const TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontSize: 20,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      Text(
                                        NumberFormat("#,###", "vi_VN")
                                            .format(discountedPrice),
                                        style: const TextStyle(
                                          color:
                                              Color.fromARGB(255, 253, 101, 20),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 25,
                                        ),
                                      ),
                                      const Text(
                                        "đ",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(top: 10),
                                        child: Text(
                                          "/ngày",
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 83, 83, 83),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Không có dữ liệu'));
          }
        },
      ),
    );
  }
}
