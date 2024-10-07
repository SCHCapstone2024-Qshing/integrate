//갤러리에서 image 선택, qr코드 스캔해서 결과 보고서 보여주는 기능
//barcode_scanner_simple.dart 파일 속 코드와 거의 동일
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import '/services/url_scan.dart';

class GalleryScan {
  final UrlScan urlCheck;
  final MobileScannerController controller = MobileScannerController(
    torchEnabled: true,
    useNewCameraSelector: true,
    returnImage: true,
  );

  GalleryScan(this.urlCheck);

  // 이미지 선택 후 QR 코드 스캔
  Future<void> imageSelect(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      return;
    }

    // 선택한 이미지에서 QR 코드 분석
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
        return; // QR 코드가 URL이 아닐 경우 처리
      }
    }

    if (barcodes != null) {
      // 로딩창 표시
      await _showLoadingDialog(context);

      try {
        // URL 안전성 검사
        final malicious = await urlCheck.isMalicious(url);

        // 로딩창 닫기
        Navigator.of(context).pop();

        // 스캔 결과 다이얼로그 표시
        _showScanReportDialog(context, malicious, Uri.parse(url));
      } catch (e) {
        Navigator.of(context).pop();
        _showErrorDialog(context, e.toString());
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR 코드를 찾을 수 없습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // 로딩 다이얼로그 표시
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

  // 스캔 결과 다이얼로그 표시 (Yes/No)
  void _showScanReportDialog(BuildContext context, int malicious, Uri url) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('VirusTotal Scan Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Malicious: $malicious'),
              if (malicious > 0)
                const Text('악성코드가 발견되었습니다!',
                    style: TextStyle(color: Colors.red)),
              if (malicious == 0)
                const Text('악성코드가 발견되지 않았습니다!',
                    style: TextStyle(color: Colors.green)),
              const Text('이 URL로 이동하시겠습니까?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                await _launchUrl(url); // Yes를 누르면 URL 열기
                controller.start(); // 카메라 재시작
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                controller.start(); // 카메라 재시작
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

//VirusTotal 보고서를 기반으로 사용자에게 스캔 결과를 표시
//stats['malicious'] 값이 0보다 크면 악성 URL로 판단하고, 그렇지 않으면 안전한 URL로 판단
  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  // 에러 다이얼로그 표시
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
