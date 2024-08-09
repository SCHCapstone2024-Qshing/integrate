import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    _loadCircles(); // 화면 로딩 시 원 데이터 불러오기
  }

  Future<void> _loadCircles() async {
    // Firestore에서 모든 'location' 문서를 가져옵니다.
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('location').get();
    Set<Circle> loadedCircles = {};

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // 각 문서에서 위도, 경도, 반경 데이터를 읽습니다.
      double lat = (data['latitude'] as num).toDouble();
      double lng = (data['longitude'] as num).toDouble();
      double radius = (data['radius'] as num).toDouble();

      // 새 Circle 객체를 생성하여 Set에 추가합니다.
      loadedCircles.add(Circle(
        circleId: CircleId(doc.id), // 문서 ID를 사용하여 고유한 CircleId 생성
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
