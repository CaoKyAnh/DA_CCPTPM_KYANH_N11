// ignore_for_file: avoid_print, unused_element

import 'package:final_project_rent_moto_fe/screens/dashboard.dart';
import 'package:final_project_rent_moto_fe/screens/detail/detail_moto_screen.dart';
import 'package:final_project_rent_moto_fe/services/promoByCompany/applyPromoByCompany.dart';
import 'package:final_project_rent_moto_fe/widgets/notification/error_notification.dart';
import 'package:final_project_rent_moto_fe/widgets/notification/success_notification.dart';
import 'package:flutter/material.dart';
import 'package:final_project_rent_moto_fe/services/MotorCycle/fetch_motorcycle_isaccept_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:final_project_rent_moto_fe/services/favorite_list/get_favoritelist_service.dart';
import 'package:final_project_rent_moto_fe/services/favorite_list/add_favoritelist_service.dart';
import 'package:final_project_rent_moto_fe/services/favorite_list/delete_favoritelist_service.dart';
import 'package:intl/intl.dart';

class RentHomeInforMotos extends StatefulWidget {
  const RentHomeInforMotos({super.key});

  @override
  State<RentHomeInforMotos> createState() => _RentHomeInforMotosState();
}

class _RentHomeInforMotosState extends State<RentHomeInforMotos> {
  late Future<List<dynamic>> motorcycles;
  final FetchMotorcycleIsacceptService motorcycleService =
      FetchMotorcycleIsacceptService();
  late String userEmail; // Store the user's email
  Map<String, bool> motorcycleFavoriteState = {};
  final ApplyPromoByCompanyService promoService =
      ApplyPromoByCompanyService(); // Khởi tạo service áp dụng khuyến mãi
  Map<String, double> discountedPrices =
      {}; // Lưu giá tiền sau khi áp dụng khuyến mãi
  Map<String, double> discountValues = {}; // Lưu giá trị khuyến mãi
  Map<String, double> discountPercentages = {}; // Lưu phần trăm khuyến mãi
  @override
  void initState() {
    super.initState();
    motorcycles = motorcycleService.fetchMotorcycle();
    _loadUserFavoriteState();
    _applyPromotions(); // Gọi hàm áp dụng khuyến mãi
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      ErrorNotification(text: message).buildSnackBar(),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SuccessNotification(text: message).buildSnackBar(),
    );
  }

  // Áp dụng khuyến mãi
  Future<void> _applyPromotions() async {
    try {
      List<dynamic> motorcycleList = await motorcycles;
      for (var motorcycle in motorcycleList) {
        String motorcycleId = motorcycle['id'] ?? '';
        double originalPrice =
            (motorcycle['informationMoto']?['price'] ?? 0.0).toDouble();

        try {
          // Áp dụng khuyến mãi
          double discountedPrice =
              await promoService.applyPromotion(motorcycleId);

          setState(() {
            discountedPrices[motorcycleId] = discountedPrice;
            discountValues[motorcycleId] = originalPrice - discountedPrice;
            discountPercentages[motorcycleId] =
                ((originalPrice - discountedPrice) / originalPrice) * 100;
          });
        } catch (e) {
          // Nếu không có khuyến mãi, giữ nguyên giá gốc
          setState(() {
            discountedPrices[motorcycleId] = originalPrice;
            discountPercentages[motorcycleId] = 0.0;
          });
        }
      }
    } catch (e) {
      print("Lỗi khi áp dụng khuyến mãi: $e");
    }
  }

  Future<void> _loadUserFavoriteState() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      userEmail = currentUser.email ?? 'No email available';

      try {
        List<String> favoriteMotorcycles = await getFavoriteList(userEmail);

        setState(() {
          // Mark each motorcycle as favorite if it's in the favorite list
          motorcycles.then((motorcycleList) {
            for (var motorcycle in motorcycleList) {
              String motorcycleId = motorcycle['id'] ?? '';
              motorcycleFavoriteState[motorcycleId] =
                  favoriteMotorcycles.contains(motorcycleId);
            }
          });
        });
      } catch (e) {
        print("Failed to load favorite state: $e");
      }
    }
  }

  Future<void> toggleFavorite(String motorcycleId) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const Dashboard(initialIndex: 2), // Chỉ số UserInforScreen
          ),
        );
      }
      return;
    }
    final String email = currentUser?.email ?? 'No email available';

    try {
      setState(() {
        motorcycleFavoriteState[motorcycleId] =
            !motorcycleFavoriteState[motorcycleId]!;
      });

      if (motorcycleFavoriteState[motorcycleId]!) {
        // Add motorcycle to favorite list
        await addFavoriteList(email, [motorcycleId]);
        _showSuccessMessage('Đã thêm xe vào danh sách yêu thích!');
      } else {
        // Remove motorcycle from favorite list
        await deleteFavoriteListService(email, motorcycleId);
        _showErrorMessage('Đã xóa xe khỏi danh sách yêu thích!');
      }
    } catch (error) {
      setState(() {
        motorcycleFavoriteState[motorcycleId] =
            !motorcycleFavoriteState[motorcycleId]!;
      });
      _showErrorMessage('Không thể cập nhật danh sách yêu thích');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Xe máy dành cho bạn",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          FutureBuilder<List<dynamic>>(
            future: motorcycles,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                var data = snapshot.data!;
                if (data.isEmpty) {
                  return const Center(child: Text('No motorcycles found'));
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: data.map((motorcycle) {
                      var info = motorcycle['informationMoto'] ?? {};
                      var address = motorcycle['address'] ?? {};
                      String motorcycleId = motorcycle['id'] ?? '';
                      bool isFavorite =
                          motorcycleFavoriteState[motorcycleId] ?? false;

                      // Lấy giá sau khuyến mãi và giá trị khuyến mãi
                      double originalPrice = (info['price'] ?? 0.0).toDouble();
                      double discountedPrice =
                          discountedPrices[motorcycleId] ?? originalPrice;
                      double discountPercentage =
                          discountPercentages[motorcycleId] ?? 0.0;

                      return InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailMotoScreen(
                                motorcycle: motorcycle,
                              ),
                            ),
                          );
                          if (result != null &&
                              result['motorcycleId'] == motorcycleId) {
                            setState(() {
                              motorcycleFavoriteState[motorcycleId] =
                                  result['isFavorite'];
                            });
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          margin: const EdgeInsets.only(right: 8),
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
                                Stack(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
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
                                                "assets/images/xe1.jpg",
                                                fit: BoxFit.contain,
                                              ),
                                      ),
                                    ),
                                    if (discountPercentage > 0)
                                      Positioned(
                                        bottom: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            "Giảm: ${discountPercentage.toStringAsFixed(0)}%",
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 5),
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: const Color.fromARGB(
                                            129, 255, 173, 21),
                                      ),
                                      child: Text(
                                        "${motorcycle['category']?['name'] ?? 'Unknown'}",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFavorite
                                            ? Colors.red
                                            : Colors.black,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        toggleFavorite(motorcycleId);
                                      },
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
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
                                        "${address['district']}, ${address['city']}")
                                  ],
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      top: BorderSide(width: 1),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Hiển thị đánh giá bằng ngôi sao

                                            const SizedBox(
                                                height:
                                                    5), // Khoảng cách giữa đánh giá và giá
                                            // Giá gốc (gạch chân)
                                            Row(
                                              children: [
                                                // Giá gốc
                                                if (discountPercentage > 0)
                                                  Text(
                                                    NumberFormat(
                                                            "#,###", "vi_VN")
                                                        .format(originalPrice),
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 18,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                    ),
                                                  ),
                                                // Giá khuyến mãi
                                                Text(
                                                  NumberFormat("#,###", "vi_VN")
                                                      .format(discountedPrice),
                                                  style: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 253, 101, 20),
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
                                                  padding:
                                                      EdgeInsets.only(top: 10),
                                                  child: Text(
                                                    "/ngày",
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 83, 83, 83),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
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
                    }).toList(),
                  ),
                );
              } else {
                return const Center(
                  child: Text('Không có dữ liệu'),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
