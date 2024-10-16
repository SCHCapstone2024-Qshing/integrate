import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import '/services/url_scan.dart';
import '../API/api.dart';
import 'package:geolocator/geolocator.dart';
import '/page/MapSample.dart';

class GalleryScan {
  final UrlScan urlCheck;
  final MobileScannerController controller = MobileScannerController(
    torchEnabled: true,
    useNewCameraSelector: true,
    returnImage: true,
  );

  final ApiService apiService = ApiService();

  GalleryScan(this.urlCheck);

  Future<void> imageSelect(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    final BarcodeCapture? barcodes = await controller.analyzeImage(image.path);

    if (!context.mounted) {
      return;
    }

    late final String url;
    if (barcodes != null) {
      try {
        final Uri url0 =
            Uri.parse(barcodes.barcodes.firstOrNull!.displayValue!);
        url = url0.toString();
      } catch (err) {
        return; // URL이 유효하지 않을 경우 무시합니다.
      }
    }

    if (barcodes != null) {
      await _showLoadingDialog(context);

      try {
        final malicious = await urlCheck.isMalicious(url);

        // async 작업 후 context.mounted 체크
        if (!context.mounted) return;
        Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

        if (malicious > 0) {
          Position position = await _getCurrentLocation();

          if (!context.mounted) return;
          final int? count = await apiService.sendUserLocationWithUrl(
              position.latitude, position.longitude, url);

          if (!context.mounted) return;

          if (count != null) {
            _showScanReportDialog(
                context, malicious, Uri.parse(url), count, position);
          } else {
            _showErrorDialog(context, '서버로 데이터를 보내는 데 실패했습니다.');
          }
        } else {
          await Future.delayed(const Duration(seconds: 2));
          if (!context.mounted) return;
          _showScanReportDialog(context, malicious, Uri.parse(url), 0, null);
        }
      } catch (e) {
        if (!context.mounted) return;
        Navigator.of(context).pop();
        _showErrorDialog(context, e.toString());
      }
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR 코드를 찾을 수 없습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Position> _getCurrentLocation() async {
    return await apiService.getCurrentLocation();
  }

  Future<void> _showLoadingDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('결과 로딩 중...'),
            ],
          ),
        );
      },
    );
  }

  void _showScanReportDialog(BuildContext context, int malicious, Uri url,
      int count, Position? position) {
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
                Text('악성 여부: $malicious'),
                if (malicious > 0)
                  const Text('악성코드가 발견되었습니다!',
                      style: TextStyle(color: Colors.red)),
                if (malicious == 0)
                  const Text('악성코드가 발견되지 않았습니다.',
                      style: TextStyle(color: Colors.green)),
                if (position != null)
                  Text(
                      '이 URL은 $count번째 제보입니다. (위도: ${position.latitude}, 경도: ${position.longitude})',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text('현재 위치를 지도에 표시하시겠습니까?'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (position != null) {
                  Navigator.of(context).pop(); // 스캔 리포트 다이얼로그 닫기
                  await _navigateToMap(context, position, url);
                }
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 스캔 리포트 다이얼로그 닫기
                // URL 연결 여부 확인 다이얼로그 호출
                _showLaunchUrlConfirmationDialog(context, url);
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToMap(
      BuildContext context, Position position, Uri url) async {
    await Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => MapSample(
            latitude: position.latitude, longitude: position.longitude),
      ),
    )
        .then((_) {
      if (context.mounted) {
        _showLaunchUrlConfirmationDialog(context, url);
      }
    });
  }

  Future<void> _showLaunchUrlConfirmationDialog(BuildContext context, Uri url) {
    if (!context.mounted) {
      return Future.value(); // context가 유효하지 않으면 빈 Future 반환
    }

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('URL로 이동하시겠습니까?'),
          content: Text('사이트: $url'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // URL 다이얼로그 닫기
                await _launchUrl(url);
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // URL 다이얼로그 닫기
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

  void _showErrorDialog(BuildContext context, String message) {
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
}
