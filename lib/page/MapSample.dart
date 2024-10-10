import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../API/api.dart'; // API 파일 임포트

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  GoogleMapController? mapController;
  final LatLng _center = const LatLng(37.5665, 126.9780); // 기본 중심 좌표 (서울 시청)
  Set<Circle> _circles = {}; // 원을 저장할 Set 초기화
  final ApiService apiService = ApiService(); // API 서비스 인스턴스 생성

  @override
  void initState() {
    super.initState();
    _loadCirclesFromApi(); // 화면 로딩 시 API에서 원 데이터 불러오기
  }

  // API에서 원 데이터 불러오는 함수
  Future<void> _loadCirclesFromApi() async {
    try {
      final data = await apiService.fetchCities(); // API 호출

      if (data != null) {
        Set<Circle> loadedCircles = {};

        // List로 처리
        for (var value in data) {
          double lat = value['latitude'];
          double lng = value['longitude'];
          double radius = 1000.0; // 반경 값을 더 크게 설정해 확인
          String url = value['url']; // URL 값 사용 가능

          print("Adding circle for lat: $lat, lng: $lng, url: $url");

          // 원 추가
          loadedCircles.add(Circle(
            circleId: CircleId(url), // URL을 circleId로 사용
            center: LatLng(lat, lng),
            radius: radius,
            fillColor: Colors.red.withOpacity(0.5),
            strokeColor: Colors.red,
            strokeWidth: 2,
          ));
        }

        // State 업데이트
        setState(() {
          _circles = loadedCircles;
        });
      } else {
        print('No data returned from API');
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
