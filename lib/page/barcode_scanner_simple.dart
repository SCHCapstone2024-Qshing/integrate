// buildBarcode 함수에서 url 출력하는 함수 사용 중
// 해당 함수 내부의 launchUrl 함수를 사용해 해당 url을 처리할 수 있을 것으로 보임
//스캔한 URL을 VirusTotal에 제출하여 스캔한 보고서를 사용자에게 표시하는 기능 추가

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '/services/virustotal_service.dart';
import '/page/error/scanner_error_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class BarcodeScannerSimple extends StatefulWidget {
  const BarcodeScannerSimple({super.key});

  @override
  State<BarcodeScannerSimple> createState() => _BarcodeScannerSimpleState();
}

class _BarcodeScannerSimpleState extends State<BarcodeScannerSimple> {
  Barcode? _barcode;
  late VirusTotalService _virusTotalService;

  @override
  void initState() {
    super.initState();
    _virusTotalService = VirusTotalService(
        apiKey:
            '4642fb3585fe6d00495d2395b2c0ab4a6c1363ad5a76b0f5d7807ae3b872687b');
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

  void _handleBarcode(BarcodeCapture barcodes) async {
    if (mounted) {
      setState(() {
        _barcode = barcodes.barcodes.firstOrNull;
      });
      if (_barcode != null && _barcode!.displayValue != null) {
        final Uri url = Uri.parse(_barcode!.displayValue!);
        try {
          final scanResult = await _virusTotalService.scanUrl(url.toString());
          final analysisId = scanResult['data']['id'];
          final report = await _virusTotalService.getUrlScanReport(analysisId);
          _showScanReportDialog(report, url);
        } catch (e) {
          _showErrorDialog(e.toString());
        }
      }
    }
  }

  void _showScanReportDialog(Map<String, dynamic> report, Uri url) {
    final attributes = report['data']['attributes'];
    final stats = attributes['stats'];

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
                Text('Total Scans: ${stats['total']}'),
                Text('Malicious: ${stats['malicious']}'),
                const SizedBox(height: 10),
                if (stats['malicious'] > 0)
                  const Text('악성코드가 발견되었습니다!',
                      style: TextStyle(color: Colors.red)),
                if (stats['malicious'] == 0)
                  const Text('악성코드가 발견되지 않았습니다!',
                      style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (stats['malicious'] == 0) {
                  await _launchUrl(url);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((_) {});
  }

//VirusTotal 보고서를 기반으로 사용자에게 스캔 결과를 표시
//stats['malicious'] 값이 0보다 크면 악성 URL로 판단하고, 그렇지 않으면 안전한 URL로 판단
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
      appBar: AppBar(title: const Text('QRcode Scan')),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
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
