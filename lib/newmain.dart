//5.16 파일 정리. 크게 두가지 기능 구현. 카메라로 qr code를 인식하는 기능과 갤러리에서 qrcode를 가져오는 기능.
//     카메라 기능은 page/barcode_scanner_simple 파일을 사용했고 갤러리 기능은 example/lib 폴더의 barcode_scanner_controller를 참고하여 구현. 패키지에서 자체적으로 제공하는 imageAnalyse 함수를 이용하였음.
//     갤러리에서 qrcode를 가져올 땐 되도록 선명하고 밝은 사진을 사용할 것. 샘플 사진은 image 폴더에 넣어놨음
//     필요한 기능. qr code를 인식 후 해당 값을 넘기기위해 url추출 이후 전달하는 기능추가 필요
//5.21 패키지 정리. 기존 만들어져있던 패키지는 mobile_scaner 패키지를 그대로 깃허브에서 clone 해 온 것이기 때문에 기본 설정과 다르고 난잡한 부분이 많았다.
//     그래서 아예 패키지를 새로 만들어서 필요한 코드만 넣는 식으로 초기화 시키면서 정리했음.
//     변경점: android/app/build.gradle 의 minSdkVersion과 targetSdkVersion의 값을 각각 21, 34로 수정하여 버전문제로 에러 나던 것 해결
//기존 코드에 virustotal api 연결 추가
//9.26 integrate repository 에서 clone 해서 만들었음. 해당 코드가 내가 새로 뒤엎기 전 설정에서 만들어진 것 같아서 새로 만든 패키지로 위치 변경함. 가져온 파일 목록
// newmain.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '/page/barcode_scanner_simple.dart';
//import '/page/MapSample.dart';

void main() async {
  runApp(
    const MaterialApp(
      title: 'QR Code Scan',
      home: BarcodeScannerScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class BarcodeScannerScreen extends StatelessWidget {
  const BarcodeScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define button size for consistent appearance
    const buttonWidth = 120.0;
    const buttonHeight = 50.0;
    const buttonOpacity = 0.5; // 50% opacity

    return Scaffold(
      body: Stack(
        children: [
          //const BarcodeScannerSimple(), // Display the camera scanning view
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
                      onPressed: () => imageSelect(context),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SecondPage()),
                        );
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

Future<void> imageSelect(BuildContext context) async {
  final MobileScannerController controller = MobileScannerController(
    torchEnabled: true,
    useNewCameraSelector: true,
    returnImage: true,
  );
  final ImagePicker picker = ImagePicker();

  final XFile? image = await picker.pickImage(
    source: ImageSource.gallery,
  );

  if (image == null) {
    return;
  }

  final BarcodeCapture? barcodes = await controller.analyzeImage(
    image.path,
  );
  if (!context.mounted) {
    return;
  }
  late final String url;
  if (barcodes != null) {
    final Uri url0 = Uri.parse(barcodes.barcodes.firstOrNull!.displayValue!);
    url = url0.toString();
  }

  if (barcodes != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('URL: $url'),
        backgroundColor: Colors.green,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR code를 찾을 수 없습니다. 더 선명한 이미지를 사용해주세요'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Second Page'),
      ),
      body: const Center(
        child: Text(
          'Welcome to the Second Page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
