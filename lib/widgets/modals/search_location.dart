// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class SearchLocation extends StatefulWidget {
  const SearchLocation({super.key});

  @override
  State<SearchLocation> createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> locations = [];

  // Hàm tìm kiếm địa điểm từ API OpenStreetMap (Nominatim)
  void searchLocation(String query) async {
    final url =
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&accept-language=vi&countrycodes=VN';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (mounted) {
        setState(() {
          locations = data;
        });
      }
    }
  }

  // Hàm lấy vị trí GPS hiện tại và chuyển đổi thành địa chỉ
  Future<String> getLocationFromGPS() async {
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.best, // Độ chính xác cao nhất
    );
    Position position =
        await Geolocator.getCurrentPosition(locationSettings: locationSettings);
    final lat = position.latitude;
    final lon = position.longitude;

    final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&addressdetails=1&accept-language=vi';
    final geoResponse = await http.get(Uri.parse(url));

    if (geoResponse.statusCode == 200) {
      final geoData = jsonDecode(geoResponse.body);
      final address = geoData['address'] ?? {};
      final road = address['road'] ?? '';
      final suburb = address['suburb'] ?? '';
      final city = address['city'] ?? '';
      final county = address['county'] ?? '';
      final state = address['state'] ?? '';
      final country = address['country'] ?? 'N/A';

      List<String> addressParts = [];
      if (road.isNotEmpty) addressParts.add(road);
      if (suburb.isNotEmpty) addressParts.add(suburb);
      if (city.isNotEmpty) addressParts.add(city);
      if (county.isNotEmpty) addressParts.add(county);
      if (state.isNotEmpty) addressParts.add(state);
      if (country.isNotEmpty && country != 'N/A') addressParts.add(country);

      return addressParts.isNotEmpty ? addressParts.join(', ') : 'N/A';
    } else {
      throw Exception('Không thể lấy dữ liệu vị trí');
    }
  }

  Future<void> _getLocation() async {
    // Kiểm tra và yêu cầu quyền vị trí
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("GPS chưa được bật");
    } else {
      var status = await Permission.location.request();
      if (status.isDenied) {
        status = await Permission.location.request();
      }

      if (status.isGranted) {
        final subtitle = await getLocationFromGPS();
        Navigator.pop(context, subtitle);
      } else if (status.isPermanentlyDenied) {
        // Gợi ý người dùng bật quyền trong cài đặt
        openAppSettings();
      } else {
        print('Quyền vị trí bị từ chối');
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Địa điểm"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  width: 0.6,
                  color: Colors.green,
                ),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Nhập địa chỉ",
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    color: Colors.orangeAccent,
                  ),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              locations = [];
                            });
                          },
                        )
                      : IconButton(
                          icon: Icon(
                              Icons.my_location), // Hiển thị biểu tượng vị trí
                          onPressed: () async {
                            await _getLocation(); // Gọi hàm lấy vị trí
                          },
                        ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    searchLocation(value); // Tìm kiếm khi giá trị thay đổi
                  } else {
                    setState(() {
                      locations =
                          []; // Xóa kết quả nếu không có giá trị tìm kiếm
                    });
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final location = locations[index];
                final address =
                    location['display_name'] ?? 'N/A'; // Địa chỉ đầy đủ

                // Trích xuất các phần của địa chỉ
                final road = location['address']?['road'] ?? '';
                final suburb = location['address']?['suburb'] ?? '';
                final city = location['address']?['city'] ?? '';
                final county = location['address']?['county'] ?? '';
                final state = location['address']?['state'] ?? '';
                final country = location['address']?['country'] ?? 'N/A';

                // Tạo subtitle chỉ hiển thị các giá trị có thực
                List<String> addressParts = [];

                if (road.isNotEmpty) addressParts.add(road);
                if (suburb.isNotEmpty) addressParts.add(suburb);
                if (city.isNotEmpty) addressParts.add(city);
                if (county.isNotEmpty) addressParts.add(county);
                if (state.isNotEmpty) addressParts.add(state);
                if (country.isNotEmpty && country != 'N/A')
                  addressParts.add(country);

                // Tạo chuỗi subtitle
                final subtitle =
                    addressParts.isNotEmpty ? addressParts.join(', ') : 'N/A';

                // Logic để quyết định "address" sẽ hiển thị gì
                String displayAddress = '';
                if (road.isNotEmpty && suburb.isNotEmpty) {
                  // Nếu cả đường và phường đều có, hiển thị phần nhỏ hơn
                  displayAddress = road.length <= suburb.length ? road : suburb;
                } else if (road.isNotEmpty) {
                  // Nếu chỉ có đường, hiển thị tên đường
                  displayAddress = road;
                } else if (suburb.isNotEmpty) {
                  // Nếu chỉ có phường, hiển thị phường
                  displayAddress = suburb;
                } else {
                  displayAddress =
                      address; // Nếu không có đường/phường, hiển thị địa chỉ đầy đủ
                }

                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(width: 0.8, color: Colors.black))),
                  child: ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: Colors.greenAccent,
                    ),
                    title: Text(
                      displayAddress,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ), // Hiển thị đường/phường theo yêu cầu
                    subtitle: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ), // Hiển thị tên đường, phường, thành phố, tỉnh
                    onTap: () {
                      Navigator.pop(context,
                          subtitle); // Trả lại subtitle thay vì địa chỉ đầy đủ
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
