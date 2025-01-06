import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailMotoReview extends StatefulWidget {
  final String numberPlate;
  const DetailMotoReview({super.key, required this.numberPlate});

  @override
  State<DetailMotoReview> createState() => _DetailMotoReviewState();
}

class _DetailMotoReviewState extends State<DetailMotoReview> {
  List<Map<String, dynamic>> reviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  Future<void> fetchReviews() async {
    try {
      final motorcycleSnapshot = await FirebaseFirestore.instance
          .collection('motorcycles')
          .where('numberPlate', isEqualTo: widget.numberPlate)
          .get();

      if (motorcycleSnapshot.docs.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Lấy reviewList từ document đầu tiên
      final reviewList =
          motorcycleSnapshot.docs.first.data()['reviewList'] ?? [];

      // Nếu reviewList rỗng
      if (reviewList.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Lấy dữ liệu từ collection reviews
      final reviewDocs = await FirebaseFirestore.instance
          .collection('reviews')
          .where(FieldPath.documentId, whereIn: reviewList)
          .get();

      // Chuyển dữ liệu thành danh sách Map
      final fetchedReviews = reviewDocs.docs.map((doc) => doc.data()).toList();

      setState(() {
        reviews = fetchedReviews;
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching reviews: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (reviews.isEmpty) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(width: 1, color: Colors.black54),
        ),
        child: const Center(
          child: Text(
            'Chưa có đánh giá nào',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đánh giá',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...reviews.map((review) => Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/images/sh.png'),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(
                          review['numberStars'],
                          (index) => const Icon(Icons.star,
                              color: Colors.yellow, size: 20),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(review['email'] ?? 'Người dùng ẩn'),
                    ],
                  ),
                  subtitle: Text(review['comment'] ?? ''),
                ),
                const Divider(),
              ],
            )),
      ],
    );
  }
}
