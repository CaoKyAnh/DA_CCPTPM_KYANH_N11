// ignore_for_file: avoid_print, unused_element
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_rent_moto_fe/screens/dashboard.dart';
import 'package:final_project_rent_moto_fe/screens/detail/detail_moto_screen.dart';
import 'package:final_project_rent_moto_fe/services/favorite_list/add_favoritelist_service.dart';
import 'package:final_project_rent_moto_fe/services/favorite_list/delete_favoritelist_service.dart';
import 'package:final_project_rent_moto_fe/services/promoByCompany/applyPromoByCompany.dart';
import 'package:final_project_rent_moto_fe/widgets/notification/error_notification.dart';
import 'package:final_project_rent_moto_fe/widgets/notification/success_notification.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:final_project_rent_moto_fe/services/favorite_list/get_favorite_list_by_user.dart';
import 'package:intl/intl.dart';

class ListFavoriteByUser extends StatefulWidget {
  const ListFavoriteByUser({super.key});

  @override
  State<ListFavoriteByUser> createState() => _ListFavoriteByUserState();
}

class _ListFavoriteByUserState extends State<ListFavoriteByUser> {
  Future<List<Map<String, dynamic>>>? favoriteList;
  final ApplyPromoByCompanyService _applyPromoService =
      ApplyPromoByCompanyService();
  Map<String, bool> motorcycleFavoriteState =
      {}; // To track favorite state for each motorcycle

  @override
  void initState() {
    super.initState();
    fetchFavoriteList();
  }

  Future<void> fetchFavoriteList() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      final String email = currentUser?.email ?? '';

      if (email.isNotEmpty) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          String firestoreUserId = userDoc.id;

          List<Map<String, dynamic>> data =
              await getFavoriteListByUserService(firestoreUserId);
          setState(() {
            favoriteList = Future.value(data);

            motorcycleFavoriteState = {
              for (var motorcycle in data) motorcycle['id']: true
            };
          });
        } else {
          throw Exception("User document not found in Firestore.");
        }
      } else {
        throw Exception("User email not available.");
      }
    } catch (error) {
      print("Error fetching Firestore user ID: $error");
    }
  }

  Future<void> toggleFavorite(String motorcycleId) async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String email = currentUser?.email ?? 'No email available';

    try {
      setState(() {
        motorcycleFavoriteState[motorcycleId] =
            !(motorcycleFavoriteState[motorcycleId] ?? false);
      });

      if (motorcycleFavoriteState[motorcycleId]!) {
        await addFavoriteList(email, [motorcycleId]);
        if (mounted) {
          _showSuccessMessage(context, 'Đã thêm xe vào danh sách yêu thích!');
        }
      } else {
        await deleteFavoriteListService(email, motorcycleId);
        if (mounted) {
          _showErrorMessage(context, 'Đã xóa xe khỏi danh sách yêu thích!');
        }

        setState(() {
          favoriteList = favoriteList == null
              ? Future.value(
                  []) // Nếu favoriteList là null, trả về danh sách trống
              : favoriteList!.then((list) {
                  return list
                      .where((motorcycle) => motorcycle['id'] != motorcycleId)
                      .toList();
                });
        });
      }
    } catch (error) {
      // Nếu có lỗi, khôi phục lại trạng thái trước đó
      setState(() {
        motorcycleFavoriteState[motorcycleId] =
            !(motorcycleFavoriteState[motorcycleId] ?? false);
      });
      if (mounted) {
        _showErrorMessage(context, 'Không thể cập nhật danh sách yêu thích');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Dashboard(),
              ),
            );
          },
        ),
        title: const Text(
          'Danh sách xe yêu thích',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFF49C21),
        elevation: 5,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: favoriteList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: SizedBox
                              .shrink()); // Không hiển thị vòng tròn chờ
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      var data = snapshot.data!;
                      if (data.isEmpty) {
                        return const Center(
                          child: Text('Danh sách xe yêu thích trống'),
                        );
                      }

                      return Column(
                        children: data.map((motorcycle) {
                          var info = motorcycle['informationMoto'] ?? {};
                          String motorcycleId = motorcycle['id'] ?? '';

                          return FutureBuilder<double>(
                            future:
                                _applyPromoService.applyPromotion(motorcycleId),
                            builder: (context, promoSnapshot) {
                              // Nếu không có dữ liệu khuyến mãi, không cần hiển thị vòng tròn chờ
                              if (promoSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox
                                    .shrink(); // Không hiển thị vòng tròn chờ
                              } else if (promoSnapshot.hasError) {
                                // Nếu có lỗi, hiển thị thông báo lỗi
                                if (promoSnapshot.error.toString() ==
                                    "Khuyến mãi không hợp lệ cho hôm nay") {
                                  return const SizedBox
                                      .shrink(); // Không hiển thị gì khi không có khuyến mãi
                                }
                                return Center(
                                    child:
                                        Text('Error: ${promoSnapshot.error}'));
                              } else if (promoSnapshot.hasData) {
                                double discountedPrice = promoSnapshot.data!;
                                bool hasDiscount =
                                    discountedPrice != info['price'];

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
                                        result['motorcycleId'] ==
                                            motorcycleId) {
                                      setState(() {
                                        motorcycleFavoriteState[motorcycleId] =
                                            result['isFavorite'];
                                        if (!result['isFavorite']) {
                                          favoriteList =
                                              favoriteList!.then((list) {
                                            return list
                                                .where((motorcycle) =>
                                                    motorcycle['id'] !=
                                                    motorcycleId)
                                                .toList();
                                          });
                                        }
                                      });
                                    }
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    margin: const EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          width: 0.2, color: Colors.black),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                      width: 0.2,
                                                      color: Colors.black),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: (info['images'] !=
                                                              null &&
                                                          info['images']
                                                              .isNotEmpty)
                                                      ? Image.network(
                                                          info['images'][0],
                                                          fit: BoxFit.contain)
                                                      : Image.asset(
                                                          "assets/images/xe1.jpg",
                                                          fit: BoxFit.contain),
                                                ),
                                              ),
                                              if (hasDiscount)
                                                Positioned(
                                                  bottom: 10,
                                                  right: 10,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Text(
                                                      'Giảm: ${((info['price'] - discountedPrice) / info['price']) * 100}% ',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                margin: const EdgeInsets.only(
                                                    top: 5),
                                                padding:
                                                    const EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: const Color.fromARGB(
                                                      129, 255, 173, 21),
                                                ),
                                                child: Text(
                                                  "Category: ${motorcycle['category']?['name'] ?? 'Unknown'}",
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  motorcycleFavoriteState[
                                                              motorcycleId] ??
                                                          false
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: motorcycleFavoriteState[
                                                              motorcycleId] ??
                                                          false
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
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Text(
                                              info['nameMoto'] ??
                                                  "Automatic moto",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.location_on),
                                              SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  "${motorcycle['address']?['district'] ?? 'Unknown'}, ${motorcycle['address']?['city'] ?? 'Unknown'}, ",
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: true,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(
                                              color: Colors.black,
                                              thickness: 1.5),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.yellow,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                "${info['rating'] ?? '5.0'}",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  if (hasDiscount)
                                                    Text(
                                                      NumberFormat(
                                                              "#,###", "vi_VN")
                                                          .format(
                                                              info['price']),
                                                      style: const TextStyle(
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        fontSize: 20,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  Text(
                                                    NumberFormat(
                                                            "#,###", "vi_VN")
                                                        .format(
                                                            discountedPrice),
                                                    style: const TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 253, 101, 20),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 25,
                                                    ),
                                                  ),
                                                  const Text(
                                                    "VND/day",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 18),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return const SizedBox
                                    .shrink(); // Không hiển thị gì nếu không có khuyến mãi
                              }
                            },
                          );
                        }).toList(),
                      );
                    } else {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                color: Colors.blueAccent,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Đang tải...",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      ErrorNotification(text: message).buildSnackBar(),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SuccessNotification(text: message).buildSnackBar(),
    );
  }
}
