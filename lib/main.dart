//5.16 파일 정리. 크게 두가지 기능 구현. 카메라로 qr code를 인식하는 기능과 갤러리에서 qrcode를 가져오는 기능.
//     카메라 기능은 page/barcode_scanner_simple 파일을 사용했고 갤러리 기능은 example/lib 폴더의 barcode_scanner_controller를 참고하여 구현. 패키지에서 자체적으로 제공하는 imageAnalyse 함수를 이용하였음.
//     갤러리에서 qrcode를 가져올 땐 되도록 선명하고 밝은 사진을 사용할 것. 샘플 사진은 image 폴더에 넣어놨음
//     필요한 기능. qr code를 인식 후 해당 값을 넘기기위해 url추출 이후 전달하는 기능추가 필요
//5.21 패키지 정리. 기존 만들어져있던 패키지는 mobile_scaner 패키지를 그대로 깃허브에서 clone 해 온 것이기 때문에 기본 설정과 다르고 난잡한 부분이 많았다.
//     그래서 아예 패키지를 새로 만들어서 필요한 코드만 넣는 식으로 초기화 시키면서 정리했음.
//     변경점: android/app/build.gradle 의 minSdkVersion과 targetSdkVersion의 값을 각각 21, 34로 수정하여 버전문제로 에러 나던 것 해결
//기존 코드에 virustotal api 연결 추가
//9.26 integrate repository 에서 clone 해서 만들었음. 해당 코드가 내가 새로 뒤엎기 전 설정에서 만들어진 것 같아서 새로 만든 패키지로 위치 변경함. 가져온 파일 목록
// newmain.dart의 코드를 가져옴
// 기존에 연결되어있던 sample map 파일은 임의로 second page로 임시 페이지 하나 만들어서 대체 하였음 나중에 map은 합칠때 연결할 예정
// dot env 설치해서 virustotal API KEY를 .ENV 파일로 이동시켰음.(git ignore에 .env 추가, pubspec.yaml 파일에 asset에 .env 추가 완료)
// malicious 값 가져오는 것 확인하였고 해당 함수를 urlScan.dart에 작성하였음. urlScand의 isMalicious는 malicious 값을 int로 리턴함.
// 카메라 역할을 하는 barcode_scanner_simple에서 바코드를 스캔했을 때도 새로 만든 함수를 이용해 malicious 값을 가져오게 할 예정
// 9.28 카메라로 스캔해도 정상적으로 malicious 값을 가져오는 것을 확임 현재 문제가 1번째 요청을 했을 때 가끔씩 0을 리턴하는 것인데 아마 요청을 받아오기 전에 실행이 되기 때문에 발행하는 문제인 것으로 보임
// 스캔 이후 잠시 기다리라는 로딩 문구와 일정시간 기다리는 구문을 추가할 예정()
// new main의 내용도 대부분 main으로 이동 완료. 추후에 newmain 파일은 삭제예정-삭제완료
//10.5 맵 연동 시작
//google_maps_flutter: ^2.6.1 pubspec.yaml 파일에 추가. backend 폴더 추가. MapSample.dart 파일 추가
//main file 수정(노션에 나와있던 app/ 밑 파일도 일부 수정)
//10.15  갤러리로 스캔 시 url이 나오지 않아 스캔 대상이 무엇인지 확인이 힘듬(수정 완료)
//  앱을 키고 첫 번째로 악성 url을 입력시켰을 때 malicious 값이 0이 나오는 경우가 있음. 한 번 더 확인이 필요한데 virustotal에서 0을 리턴한 것 같음
//      확인해보니 virustotal의 responce status가 status: queued 로 되어있는데 리턴으로 받아오는 경우가 있을때 0을 리턴함을 알아냄. 상태가 queued일경우 다시 요청하는 코드 작성

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '/page/barcode_scanner_simple.dart';
import '/services/url_scan.dart';
import '/page/MapSample.dart';
import '/page/gallery_scan.dart';
import 'package:geolocator/geolocator.dart'; // 위치 정보를 위한 패키지

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    const MaterialApp(
      title: 'QR Code Scan',
      home: BarcodeScannerScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  late UrlScan urlCheck;
  late GalleryScan galleryScan;

  @override
  void initState() {
    super.initState();
    urlCheck = UrlScan();
    urlCheck.initState();
    galleryScan = GalleryScan(urlCheck);
  }

  Future<Position> _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
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
  }

  Future<void> imageSelect(BuildContext context) async {
    final MobileScannerController controller = MobileScannerController(
      torchEnabled: true,
      useNewCameraSelector: true,
      returnImage: true,
    );
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
        return; // URL이 아닐 경우 따로 처리
      }
    }
    if (barcodes != null) {
      final currentContext = context;
      final malicious = await urlCheck.isMalicious(url);
      if (!currentContext.mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        SnackBar(
          content: Text('URL: $url, malicious: $malicious'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR code를 찾을 수 없습니다.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const buttonWidth = 120.0;
    const buttonHeight = 50.0;
    const buttonOpacity = 0.5; // 50% opacity
    return Scaffold(
      body: Stack(
        children: [
          BarcodeScannerSimple(
              urlCheck: urlCheck), // Display the camera scanning view
          Positioned(
            bottom: 120,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Opacity(
                  opacity: buttonOpacity,
                  child: SizedBox(
                    width: buttonWidth,
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: () => galleryScan.imageSelect(context),
                      child: const Text('Gallery'),
                    ),
                  ),
                ),
                Opacity(
                  opacity: buttonOpacity,
                  child: SizedBox(
                    width: buttonWidth,
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          Position position =
                              await _getUserLocation(); // 위치 정보 가져오기
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapSample(
                                latitude: position.latitude, // 위도 전달
                                longitude: position.longitude, // 경도 전달
                              ),
                            ),
                          );
                        } catch (e) {
                          _showErrorDialog(
                              '위치를 가져오는 데 실패했습니다: ${e.toString()}');
                        }
                      },
                      child: const Text('Map'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
