//virustotal api와 상호작용, url을 스캔하고 스캔 보고서를 가져오는 기능

import 'dart:convert';
import 'package:http/http.dart' as http;

class VirusTotalService {
  final String apiKey;

  VirusTotalService({required this.apiKey});

  Future<Map<String, dynamic>> scanUrl(String url) async {
    final response = await http.post(
      Uri.parse('https://www.virustotal.com/api/v3/urls'),
      headers: {
        'x-apikey': apiKey,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'url=$url',
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to scan URL: ${response.body}');
    }
  }

//https://www.virustotal.com/api/v3/urls/{추가 id}
//url 스캔을 위해 virustotal로 보냄
  Future<Map<String, dynamic>> getUrlScanReport(String analysisId) async {
    final response = await http.get(
      Uri.parse('https://www.virustotal.com/api/v3/analyses/$analysisId'),
      headers: {
        'x-apikey': apiKey,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to retrieve scan report: ${response.body}');
    }
  }
}
