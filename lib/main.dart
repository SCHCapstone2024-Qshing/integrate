import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '/page/barcode_scanner_simple.dart';
import '/page/MapSample.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp(); //해당 코드 쓰면 무한 로딩함(갤럭시 핸드폰)
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
          const BarcodeScannerSimple(), // Display the camera scanning view
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
                          MaterialPageRoute(builder: (context) => const MapSample()),
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


