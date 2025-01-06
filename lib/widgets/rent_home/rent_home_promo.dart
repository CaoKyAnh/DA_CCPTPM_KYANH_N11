import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RentHomePromo extends StatefulWidget {
  const RentHomePromo({super.key});

  @override
  State<RentHomePromo> createState() => _RentHomePromoState();
}

class _RentHomePromoState extends State<RentHomePromo> {
  void _showPromotionDetails(Map<String, dynamic> promoData) {
    // Hàm định dạng ngày tháng
    String formatDate(String? date) {
      if (date == null || date.isEmpty) return 'Không có';
      try {
        final parsedDate = DateTime.parse(date);
        return DateFormat('dd/MM/yyyy').format(parsedDate);
      } catch (e) {
        return 'Không hợp lệ';
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hình ảnh khuyến mãi
                  if (promoData['imageUrl'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        promoData['imageUrl'],
                        fit: BoxFit
                            .contain, // Hiển thị toàn bộ hình ảnh mà không bị cắt
                        width: double.infinity, // Đặt chiều rộng đầy đủ
                        height:
                            200, // Chiều cao cố định (hoặc để trống nếu cần tự động)
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Text(
                                'Không có hình ảnh',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Tên khuyến mãi
                  Text(
                    promoData['name'] ?? 'Tên khuyến mãi',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Thông tin khác (mã, giảm giá, ngày bắt đầu/kết thúc)
                  Row(
                    children: [
                      const Icon(Icons.code, size: 20, color: Colors.black54),
                      const SizedBox(width: 8),
                      Text(
                        "Mã: ${promoData['code'] ?? 'Không có mã'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.discount,
                          size: 20, color: Colors.black54),
                      const SizedBox(width: 8),
                      Text(
                        "Giảm giá: ${promoData['discount']}%",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 20, color: Colors.black54),
                      const SizedBox(width: 8),
                      Text(
                        "Ngày bắt đầu: ${formatDate(promoData['startDate'])}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 20, color: Colors.black54),
                      const SizedBox(width: 8),
                      Text(
                        "Ngày kết thúc: ${formatDate(promoData['endDate'])}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Nút đóng
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Đóng',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Đảm bảo căn lề trái
      children: [
        const Padding(
          padding: EdgeInsets.zero, // Không có khoảng cách bên ngoài
          child: Text(
            "Chương trình khuyến mãi",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 5),
        StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('promotions').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final promotions = snapshot.data!.docs;
            final now = DateTime.now();

            // Lọc các khuyến mãi có ngày hợp lệ và không bị ẩn
            final validPromotions = promotions.where((promo) {
              final data = promo.data() as Map<String, dynamic>;

              // Kiểm tra ishide
              if (data['isHide'] == true) return false;

              final startDate = data['startDate'] != null
                  ? DateTime.tryParse(data['startDate'])
                  : null;
              final endDate = data['endDate'] != null
                  ? DateTime.tryParse(data['endDate'])
                  : null;

              // Chỉ hiển thị các khuyến mãi trong khoảng thời gian hợp lệ
              if (startDate == null || endDate == null) return false;
              return now.isAfter(startDate) && now.isBefore(endDate);
            }).toList();

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: validPromotions.isEmpty
                  ? Center(
                      child: Text(
                        "Hiện tại chưa có khuyến mãi",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Row(
                      children: validPromotions.map((promo) {
                        final data = promo.data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () => _showPromotionDetails(data),
                          child: Container(
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.transparent,
                            ),
                            width: 270,
                            height: 150,
                            child: Stack(
                              children: [
                                // Hình ảnh toàn khung
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    data['imageUrl'] ?? '',
                                    fit: BoxFit
                                        .contain, // Sử dụng BoxFit.contain
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey,
                                        child: const Center(
                                          child: Text(
                                            'Không có hình ảnh',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Mã khuyến mãi ở góc phải dưới
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      data['code'] ?? 'Không có mã',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            );
          },
        ),
      ],
    );
  }
}
