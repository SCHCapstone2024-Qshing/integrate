import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart'; // 위치 정보 가져오기
import '/page/error/scanner_error_widget.dart';
import 'package:http/http.dart' as http;
import '/API/api.dart';
import '/services/url_scan.dart';
import 'dart:convert';
import '/page/MapSample.dart';

class BarcodeScannerSimple extends StatefulWidget {
  final UrlScan urlCheck;
  const BarcodeScannerSimple({required this.urlCheck, super.key});

  @override
  State<BarcodeScannerSimple> createState() => _BarcodeScannerSimpleState();
}

class _BarcodeScannerSimpleState extends State<BarcodeScannerSimple> {
  Barcode? _barcode;
  bool isScanning = false; // 스캔 중인지 여부 추가
  UrlScan? urlCheck;
  final MobileScannerController controller = MobileScannerController();

  @override
  void initState() {
    urlCheck = UrlScan();
    urlCheck!.initState();
    super.initState();
  }

  // 사용자 위치 가져오기
  Future<Position> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
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

  // URL과 위치 정보를 서버로 보내기
  Future<void> _sendDataToServer(Uri url, Position position) async {
    try {
      final data = {
        'url': url.toString(),
        'latitude': position.latitude,
        'longitude': position.longitude,
      };

      final response = await http.post(
        Uri.parse('http://34.29.7.131:3000/cities'), // 백엔드 API 엔드포인트
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Data sent successfully');
      } else {
        print('Failed to send data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending data to server: $e');
    }
  }

  Widget _buildBarcode(Barcode? value) {
    if (value == null) {
      return const Text(
        'Scan something!',
        overflow: TextOverflow.fade,
        style: TextStyle(color: Colors.white),
      );
    }
    return Text(
      value.displayValue ?? 'No display value.',
      overflow: TextOverflow.fade,
      style: const TextStyle(color: Colors.white),
    );
  }

  Future<void> showLoadingDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('결과 로딩중...'),
            ],
          ),
        );
      },
    );
  }

  void _handleBarcode(BarcodeCapture barcodes) async {
    if (mounted && !isScanning) {
      setState(() {
        isScanning = true;
        _barcode = barcodes.barcodes.firstOrNull;
      });

      if (_barcode != null && _barcode!.displayValue != null) {
        final Uri url = Uri.parse(_barcode!.displayValue!);

        controller.stop(); // 카메라 멈추기
        await showLoadingDialog();

        try {
          // URL이 악성인지 검사
          final malicious = await urlCheck!.isMalicious(url.toString());

          if (malicious > 0) {
            // **악성일 경우에만 데이터 전송**
            // 위치 정보 가져오기
            final position = await _getUserLocation();

            // URL, 위치 정보, 및 악성 여부 데이터를 서버로 전송
            final ApiService apiService = ApiService();

            final int? count = await apiService.sendUserLocationWithUrl(
                position.latitude, position.longitude, url.toString());

            if (count != null) {
              // 결과 다이얼로그에 count 값 포함하여 표시
              await Future.delayed(const Duration(seconds: 2));
              Navigator.of(context).pop();
              _showScanReportDialog(malicious, url, position, count);
            } else {
              _showErrorDialog('서버로 데이터를 보내는 데 실패했습니다.');
            }
          } else {
            // 정상 URL일 경우 알림창 표시하고 서버로 데이터 전송하지 않음
            await Future.delayed(const Duration(seconds: 2));
            Navigator.of(context).pop();
            _showScanReportDialog(
                malicious, url, null, 0); // 정상일 경우 count는 0으로 표시
          }
        } catch (e) {
          Navigator.of(context).pop();
          _showErrorDialog(e.toString());
        }
      }

      setState(() {
        isScanning = false; // 스캔 완료 후 스캔 상태 해제
      });
    }
  }

  void _showScanReportDialog(int num, Uri url, Position? position, int count) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('VirusTotal Scan Report'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('URL: $url'),
                Text('Malicious: $num'),
                if (num > 0)
                  const Text('악성코드가 발견되었습니다!!!!',
                      style: TextStyle(color: Colors.red)),
                if (num == 0)
                  const Text('악성코드가 발견되지 않았습니다!!!!',
                      style: TextStyle(color: Colors.green)),
                if (position != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이 URL은 $count번째 제보입니다. (${position.latitude}, ${position.longitude})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                const Text('현재 위치를 지도에 표시하시겠습니까?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                // 지도로 직접 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapSample(
                      latitude: position!.latitude,
                      longitude: position.longitude,
                    ), // 좌표를 MapSample로 전달
                  ),
                ).then((_) {
                  // 지도 화면이 닫힌 후 사이트로 이동할지 여부 묻기
                  _showSiteLaunchDialog(url);
                });
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                _showSiteLaunchDialog(url); // 사이트로 이동할지 묻기
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _showSiteLaunchDialog(Uri url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('사이트로 이동'),
          content: const Text('이 URL로 이동하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _launchUrl(url); // URL 열기
                controller.start(); // 카메라 재시작
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.start(); // 카메라 재시작
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scan')),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
            errorBuilder: (context, error, child) {
              return ScannerErrorWidget(error: error);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.bottomCenter,
              height: 100,
              color: Colors.black.withOpacity(0.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: Center(child: _buildBarcode(_barcode))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
