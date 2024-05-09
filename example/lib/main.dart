import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobile_scanner_example/barcode_scanner_controller.dart';
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

              /*
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerListView(),
                  ),
                );
              },
              */
              child: const Text('Gallery'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerWithController(),
                  ),
                );
              },
              child: const Text(' Controller'),
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
  print('-------------');
  // final Uri _url = Uri.parse(barcodes.barcodes.firstOrNull!.displayValue!);
  // final String url = _url.toString();
  // print(url);
  print('--------------');
  final SnackBar snackbar = barcodes != null
      ? const SnackBar(
          content: Text('find'),
          backgroundColor: Colors.green,
        )
      : const SnackBar(
          content: Text('no'),
          backgroundColor: Colors.red,
        );

  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}
