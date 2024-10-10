import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class ApiService {
  final String baseUrl = "http://172.30.1.86:3000"; // API 서버 URL

  // GET 요청: 모든 도시의 좌표 목록을 가져옴
  Future<List<dynamic>?> fetchCities() async {
    final response = await http.get(Uri.parse('$baseUrl/cities'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>; // 데이터를 리스트로 반환
    } else {
      print('Failed to load cities');
      return null;
    }
  }

// POST 요청: 현재 위치 정보와 QR 코드 URL 전송 후 count 값을 반환
  Future<int?> sendUserLocationWithUrl(
      double latitude, double longitude, String url) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cities'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'url': url,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // 응답 데이터 파싱
      final responseData = jsonDecode(response.body);
      final int count = responseData['location']['count']; // count 값 추출

      print('Location and URL sent successfully, count: $count'); // count 출력
      return count; // count 값 반환
    } else {
      print('Failed to send location and URL: ${response.statusCode}');
      return null;
    }
  }

  // 현재 위치 정보 가져오기
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}
