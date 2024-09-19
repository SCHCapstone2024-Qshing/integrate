import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  GoogleMapController? mapController;
  final LatLng _center = const LatLng(37.5665, 126.9780); // 기본 중심 좌표 (서울 시청)
  Set<Circle> _circles = {}; // 원을 저장할 Set 초기화

  @override
  void initState() {
    super.initState();
    _loadCirclesFromApi(); // 화면 로딩 시 API에서 원 데이터 불러오기
  }

  Future<void> _loadCirclesFromApi() async {
    try {
      final response = await http.get(Uri.parse(
          'http://172.30.1.86:3000/cities')); //API Server로 요청 꼭 주소형태로 요청해야 함 localhost 안 됨

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        Set<Circle> loadedCircles = {};

        data.forEach((city, value) {
          double lat = value['latitude'];
          double lng = value['longitude'];
          double radius = 1000.0; // 기본 반경 값 설정

          loadedCircles.add(Circle(
            circleId: CircleId(city),
            center: LatLng(lat, lng),
            radius: radius,
            fillColor: Colors.red.withOpacity(0.5),
            strokeColor: Colors.red,
            strokeWidth: 2,
          ));
        });

        // State 업데이트
        setState(() {
          _circles = loadedCircles;
        });
      } else {
        throw Exception('Failed to load data from API');
      }
    } catch (e) {
      print('Error loading circles from API: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
        circles: _circles,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
}
