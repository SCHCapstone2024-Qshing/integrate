//5.16 파일 정리. 크게 두가지 기능 구현. 카메라로 qr code를 인식하는 기능과 갤러리에서 qrcode를 가져오는 기능.
//     카메라 기능은 barcode_scanner_simple 파일을 사용했고 갤러리 기능은 example 폴더의 barcode_scanner_controller를 참고하여 구현. 패키지에서 자체적으로 제공하는 imageAnalyse 함수를 이용하였음.
//     갤러리에서 qrcode를 가져올 땐 되도록 선명하고 밝은 사진을 사용할 것. 샘플 사진은 image 폴더에 넣어놨음
//     필요한 기능. qr code를 인식 후 해당 값을 넘기기위해 url추출 이후 전달하는 기능추가 필요

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobile_scanner_example/barcode_scanner_simple.dart';

void main() {
  runApp(
    const MaterialApp(
      title: 'QRcode Scan',
      home: MyHome(),
    ),
  );
}

class MyHome extends StatelessWidget {
  const MyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QRcode Scan')),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerSimple(),
                  ),
                );
              },
              child: const Text('Camera'),
            ),
            ElevatedButton(
              onPressed: () => imageSelect(context),
              child: const Text('Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> imageSelect(BuildContext context) async {
  final MobileScannerController controller = MobileScannerController(
    torchEnabled: true, useNewCameraSelector: true,
    // formats: [BarcodeFormat.qrCode]
    // facing: CameraFacing.front,
    // detectionSpeed: DetectionSpeed.normal
    // detectionTimeoutMs: 1000,
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
    print('-------------');
    final Uri _url = Uri.parse(barcodes.barcodes.firstOrNull!.displayValue!);
    url = _url.toString();
    print(url);
    print('--------------');
  }
  final SnackBar snackbar = barcodes != null
      ? SnackBar(
          content: Text(url),
          backgroundColor: Colors.green,
        )
      : const SnackBar(
          content: Text('QR code를 찾을 수 없습니다.'),
          backgroundColor: Colors.red,
        );

  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}
