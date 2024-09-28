// buildBarcode 함수에서 url 출력하는 함수 사용 중
// 해당 함수 내부의 launchUrl 함수를 사용해 해당 url을 처리할 수 있을 것으로 보임
//스캔한 URL을 VirusTotal에 제출하여 스캔한 보고서를 사용자에게 표시하는 기능 추가

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '/page/error/scanner_error_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '/services/url_scan.dart';

//고쳐야할 것. qr code 스캔이 되고 작업을 진행 중인데도 계속해서 qr code를 스캔. 알림창이 여러개가 뜸.(스캔 이후 카메라 스탑시키기)
//controller 추가(작동여부 불확실)
//카메라로 qrcode 스캔시 _showErrorDialog 함수 실행 됨
//링크 안전 여부 알려준 후 접속 할 건지 yes/ no 버튼 만들기

class BarcodeScannerSimple extends StatefulWidget {
  final UrlScan urlCheck;
  const BarcodeScannerSimple({required this.urlCheck, super.key});
  //const BarcodeScannerSimple({Key? key, required this.urlCheck}) : super(key: key);

  @override
  State<BarcodeScannerSimple> createState() => _BarcodeScannerSimpleState();
}

class _BarcodeScannerSimpleState extends State<BarcodeScannerSimple> {
  Barcode? _barcode;
  UrlScan? urlCheck;

  //late VirusTotalService _virusTotalService;

  @override
  void initState() {
    urlCheck = UrlScan();
    urlCheck!.initState();
    super.initState();
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
          final malicious = await urlCheck!.isMalicious(url.toString());
          // final scanResult = await _virusTotalService.scanUrl(url.toString());
          // final analysisId = scanResult['data']['id'];
          // //전처리 필요
          // final report = await _virusTotalService.getUrlScanReport(analysisId);
          _showScanReportDialog(malicious, url);
        } catch (e) {
          _showErrorDialog(e.toString());
        }
      }
    }
  }

  void _showScanReportDialog(int num, Uri url) {
    // final attributes = report['data']['attributes'];
    // final stats = attributes['stats'];
//변수 이름 data.attribute.last_analysis_stats.harmless
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
                Text('Malicious: $num'),
                const SizedBox(height: 10),
                if (num > 0)
                  const Text('악성코드가 발견되었습니다!',
                      style: TextStyle(color: Colors.red)),
                if (num == 0)
                  const Text('악성코드가 발견되지 않았습니다!',
                      style: TextStyle(color: Colors.green)),
                //접속하시겠습니까? yes/no 버튼
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (num == 0) {
                  //await _launchUrl(url);
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
      appBar: AppBar(title: const Text('QR Code Scan')),
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
