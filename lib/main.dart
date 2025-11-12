import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wedding QR Access',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: QRScanPage(),
    );
  }
}

class QRScanPage extends StatefulWidget {
  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool scanned = false;
  String resultMessage = "";

  // Replace with your Apps Script URL
  final String baseUrl = "https://script.google.com/macros/s/AKfycbxilCBEeDIInOE5a2JWC8Jft9iLYb6gcT3mtemGOSk2SQVvzO2ORBAlu6vYcGNDc9X5/exec";

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  Future<void> checkQRCode(String id) async {
    final url = "$baseUrl?id=$id";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        String body = response.body.toLowerCase();
        setState(() {
          if (body.contains("already used")) {
            resultMessage = "⚠️ Already used";
          } else if (body.contains("access granted")) {
            resultMessage = "✅ Access granted";
          } else {
            resultMessage = "❌ Invalid QR code";
          }
          scanned = true;
        });
      } else {
        setState(() {
          resultMessage = "❌ Error: ${response.statusCode}";
          scanned = true;
        });
      }
    } catch (e) {
      setState(() {
        resultMessage = "❌ Network error";
        scanned = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wedding QR Scanner"),
      ),
      body: scanned
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(resultMessage, style: TextStyle(fontSize: 32)),
                  SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          scanned = false;
                        });
                        controller?.resumeCamera();
                      },
                      child: Text("Scan Again"))
                ],
              ),
            )
          : QRView(
              key: qrKey,
              onQRViewCreated: (QRViewController ctrl) {
                this.controller = ctrl;
                ctrl.scannedDataStream.listen((scanData) async {
                  if (!scanned) {
                    scanned = true;
                    controller?.pauseCamera();
                    String id = scanData.code ?? "";
                    await checkQRCode(id);
                  }
                });
              },
            ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
