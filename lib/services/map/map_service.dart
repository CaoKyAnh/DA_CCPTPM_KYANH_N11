import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapService {
  Future<LatLng> getCoordinates(String address) async {
    final response = await http.get(Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final latitude = double.tryParse(data[0]['lat']);
        final longitude = double.tryParse(data[0]['lon']);

        if (latitude != null && longitude != null) {
          print("Vị độ $longitude, Kinh độ $latitude");
          return LatLng(latitude, longitude);
        }
      }
    }
    throw Exception('Không thể tải tọa độ');
  }
}
