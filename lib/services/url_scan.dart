import './virustotal_service.dart';
//import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UrlScan {
  late VirusTotalService _virusTotalService;

  void initState() async {
    _virusTotalService = VirusTotalService(apiKey: dotenv.get("VIRUSTOTALAPI"));
  }

  Future<int> isMalicious(String url) async {
    var data = await _virusTotalService.scanUrl(url);
    var report = await _virusTotalService.getUrlScanReport(data['data']['id']);
    var value = report['data']['attributes']['stats']['malicious'];
    return value;
  }
}
