// ignore_for_file: avoid_print

import 'package:final_project_rent_moto_fe/services/MotorCycle/get_motorcycle_by_user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MotorcycleListByUser extends StatefulWidget {
  const MotorcycleListByUser({super.key});

  @override
  State<MotorcycleListByUser> createState() => _MotorcycleListByUserState();
}

class _MotorcycleListByUserState extends State<MotorcycleListByUser> {
  Future<List<Map<String, dynamic>>>?
      motorcycleList; // This will hold the list of motorcycles.

  @override
  void initState() {
    super.initState();
    fetchMotorcycleList(); // Fetch the motorcycle list when the widget initializes.
  }

  // Fetch the list of motorcycles associated with the logged-in user.
  Future<void> fetchMotorcycleList() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      final String email = currentUser?.email ?? '';

      if (email.isNotEmpty) {
        // Query Firestore to get the user's document by email
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          String firestoreUserId = userDoc.id;

          // Fetch the motorcycle list associated with the Firestore userId
          List<Map<String, dynamic>> data =
              await getMotorcycleListByUser(firestoreUserId);

          setState(() {
            // Store the fetched motorcycle list in your local variable (e.g., motorcycleList)
            motorcycleList = Future.value(data);
          });
        } else {
          throw Exception("User document not found in Firestore.");
        }
      } else {
        throw Exception("User email not available.");
      }
    } catch (error) {
      print("Error fetching Firestore user ID or motorcycle list: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Danh sách xe của tôi',
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
                  future: motorcycleList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      var data = snapshot.data!;
                      if (data.isEmpty) {
                        return const Center(
                            child: Text('Chưa có xe được đăng lên'));
                      }

                      return Column(
                        children: data.map((motorcycle) {
                          var info = motorcycle['informationMoto'] ?? {};

                          return InkWell(
                            child: Container(
                              width: 350,
                              margin: const EdgeInsets.only(bottom: 20),
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
                                    // Motorcycle Image
                                    Container(
                                      width: 350,
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
                                            ? Image.network(info['images'][0],
                                                fit: BoxFit.contain)
                                            : Image.asset(
                                                "assets/images/xe1.jpg",
                                                fit: BoxFit.contain),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 5),
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color: const Color.fromARGB(
                                                129, 255, 173, 21),
                                          ),
                                          child: Text(
                                            "Category: ${motorcycle['category']?['name'] ?? 'Unknown'}",
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
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
                                        Expanded(
                                          child: Text(
                                            "${motorcycle['address']?['streetName'] ?? 'Unknown'}, "
                                            "${motorcycle['address']?['district'] ?? 'Unknown'}, "
                                            "${motorcycle['address']?['city'] ?? 'Unknown'}, "
                                            "${motorcycle['address']?['country'] ?? 'Unknown'}",
                                            style:
                                                const TextStyle(fontSize: 16),
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          top: BorderSide(width: 1),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: const [
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
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 18),
                                                  )
                                                ],
                                              ),
                                              SizedBox(width: 100),
                                              Row(
                                                children: [
                                                  Icon(Icons.business_center),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    "10 trips",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 18),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "${info['price'] ?? "111.000"}",
                                                  style: const TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 253, 101, 20),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 25,
                                                  ),
                                                ),
                                                const Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 5),
                                                  child: Text(
                                                    "VND/day",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 18,
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
                        }).toList(),
                      );
                    } else {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Căn giữa theo chiều dọc
                          children: [
                            // Biểu tượng tải hình tròn chuyển động
                            SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(
                                strokeWidth: 4, // Độ dày của vòng tải
                                color: Colors.blueAccent, // Màu của biểu tượng
                              ),
                            ),
                            SizedBox(
                                height:
                                    10), // Khoảng cách giữa biểu tượng và văn bản
                            // Văn bản hiển thị
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
}
