import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import '../API/api.dart'; // API 파일 임포트
import 'package:intl/intl.dart'; // 날짜 포맷을 위한 패키지

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  GoogleMapController? mapController;
  Set<Circle> _circles = {}; // 원을 저장할 Set 초기화
  Set<Marker> _markers = {}; // 마커를 저장할 Set 초기화
  final LatLng _center = const LatLng(37.5665, 126.9780); // 기본 중심 좌표 (서울 시청)
  final ApiService apiService = ApiService(); // API 서비스 인스턴스 생성
  Map<String, String> circleInfo = {}; // 원에 대한 정보를 저장할 Map

  @override
  void initState() {
    super.initState();
    _loadCirclesAndMarkersFromApi(); // 원과 마커 데이터를 불러오기
  }

  // API에서 원과 마커 데이터를 불러오는 함수
  Future<void> _loadCirclesAndMarkersFromApi() async {
    try {
      final data = await apiService.fetchCities(); // API 호출

      if (data != null) {
        Set<Circle> loadedCircles = {};
        Set<Marker> loadedMarkers = {};

        for (var value in data) {
          double lat = value['latitude'];
          double lng = value['longitude'];
          int count = value['count']; // count는 int형
          double radius = count.toDouble() * 5; // count에 비례한 반경 값 설정
          double maxRadius = 1000.0;

          // 현재 시간을 포맷하여 기록 (YYYY-MM-DD HH:MM:SS 형식)
          String reportedTime =
              DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

          if (radius > maxRadius) {
            radius = maxRadius;
          }
          String url = value['url'];

          // 기존에 같은 URL을 가진 마커가 있는지 확인 (비슷한 위치와 URL 검사)
          bool isDuplicate = loadedMarkers.any((marker) {
            final distance = calculateDistance(
                lat, lng, marker.position.latitude, marker.position.longitude);
            return marker.markerId.value == url &&
                distance < 100; // 100m 이내의 동일 URL 검사
          });

          if (!isDuplicate) {
            // 중복이 없을 때만 Circle과 Marker 추가
            loadedCircles.add(Circle(
              circleId: CircleId(url),
              center: LatLng(lat, lng),
              radius: radius,
              fillColor: Colors.red.withOpacity(0.5),
              strokeColor: Colors.red,
              strokeWidth: 2,
            ));

            loadedMarkers.add(Marker(
              markerId: MarkerId(url),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: 'URL: $url',
                snippet: '자세히 보기', // 간결하게 "자세히 보기"로 설정
                onTap: () {
                  // 다이얼로그를 띄워 모든 정보를 표시
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Reported URL Information'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: [
                              Text('URL\n$url'),
                              Text('Reported on\n$reportedTime'),
                              Text('제보된 수: $count'),
                              // 필요한 다른 정보들 추가
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
            ));
          }
        }

        // State 업데이트
        setState(() {
          _circles = loadedCircles;
          _markers = loadedMarkers;
        });
      } else {
        print('No data returned from API');
      }
    } catch (e) {
      print('Error loading circles and markers from API: $e');
    }
  }

  // 두 좌표 간 거리 계산 함수 (미터 단위)
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // 지구 반경 (단위: 미터)
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) {
    return deg * (pi / 180);
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
        markers: _markers,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }
}
