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
  bool isChecking = false;
  String resultMessage = "";

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  Future<void> checkQRCode(String scannedUrl) async {
    setState(() {
      isChecking = true;
    });

    print("Scanned URL: $scannedUrl"); // Debug log

    // The QR code contains the full URL, use it directly
    try {
      // Add timeout to prevent hanging
      final response = await http.get(
        Uri.parse(scannedUrl),
      ).timeout(Duration(seconds: 30));
      
      print("Response Status: ${response.statusCode}"); // Debug log
      print("Response Body: ${response.body}"); // Debug log
      
      if (response.statusCode == 200) {
        String body = response.body.toLowerCase();
        
        setState(() {
          // Check for different responses from the server
          if (body.contains("already used") || body.contains("already been scanned")) {
            resultMessage = "⚠️ Already Used\nThis guest was already checked in";
          } else if (body.contains("access granted") || body.contains("welcome")) {
            resultMessage = "✅ Access Granted\nGuest verified successfully";
          } else if (body.contains("invalid") || body.contains("not found")) {
            resultMessage = "❌ Invalid QR Code\nGuest ID not recognized";
          } else {
            resultMessage = "❌ Unknown Response\nPlease contact support";
          }
          scanned = true;
          isChecking = false;
        });
      } else {
        setState(() {
          resultMessage = "❌ Server Error\nStatus: ${response.statusCode}";
          scanned = true;
          isChecking = false;
        });
      }
    } catch (e) {
      print("Error: $e"); // Debug log
      setState(() {
        resultMessage = "❌ Network Error\n${e.toString()}";
        scanned = true;
        isChecking = false;
      });
    }
  }

  // Get gradient colors based on result
  List<Color> _getGradientColors() {
    if (resultMessage.contains("✅")) {
      return [Colors.green.shade400, Colors.green.shade700];
    } else if (resultMessage.contains("⚠️")) {
      return [Colors.orange.shade400, Colors.orange.shade700];
    } else {
      return [Colors.red.shade400, Colors.red.shade700];
    }
  }

  // Get icon based on result
  IconData _getResultIcon() {
    if (resultMessage.contains("✅")) {
      return Icons.check_circle_outline;
    } else if (resultMessage.contains("⚠️")) {
      return Icons.warning_amber_rounded;
    } else {
      return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wedding QR Scanner"),
        centerTitle: true,
        elevation: 0,
      ),
      body: isChecking
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                    strokeWidth: 5,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Verifying...",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )
          : scanned
              ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: _getGradientColors(),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getResultIcon(),
                          size: 100,
                          color: Colors.white,
                        ),
                        SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            resultMessage,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 40),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              scanned = false;
                              resultMessage = "";
                            });
                            controller?.resumeCamera();
                          },
                          icon: Icon(Icons.qr_code_scanner, size: 24),
                          label: Text(
                            "Scan Next Guest",
                            style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.pink,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    QRView(
                      key: qrKey,
                      onQRViewCreated: (QRViewController ctrl) {
                        this.controller = ctrl;
                        ctrl.scannedDataStream.listen((scanData) async {
                          if (!scanned && !isChecking) {
                            scanned = true;
                            controller?.pauseCamera();
                            String id = scanData.code ?? "";
                            await checkQRCode(id);
                          }
                        });
                      },
                    ),
                    // Scanning frame overlay
                    Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.pink, width: 3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    // Instructions at bottom
                    Positioned(
                      bottom: 50,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        margin: EdgeInsets.symmetric(horizontal: 30),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Align QR code within frame",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
