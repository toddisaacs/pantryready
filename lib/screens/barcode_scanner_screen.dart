import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pantryready/constants/app_constants.dart';

class BarcodeScannerScreen extends StatefulWidget {
  final ScanMode? scanMode;

  const BarcodeScannerScreen({super.key, this.scanMode});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with WidgetsBindingObserver {
  late MobileScannerController controller;
  bool isScanned = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = MobileScannerController(autoStart: false);
    controller.start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        controller.start();
      case AppLifecycleState.inactive:
        controller.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (isScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      setState(() {
        isScanned = true;
      });

      HapticFeedback.mediumImpact();
      Navigator.of(context).pop(barcodes.first.rawValue);
    }
  }

  void _toggleFlash() {
    controller.toggleTorch();
  }

  void _switchCamera() {
    controller.switchCamera();
  }

  Color get _modeColor {
    switch (widget.scanMode) {
      case ScanMode.shelve:
        return AppConstants.successColor;
      case ScanMode.remove:
        return AppConstants.errorColor;
      case ScanMode.check:
        return const Color(0xFF2196F3);
      case null:
        return Colors.white;
    }
  }

  String get _modeLabel {
    switch (widget.scanMode) {
      case ScanMode.shelve:
        return 'SHELVING';
      case ScanMode.remove:
        return 'REMOVING';
      case ScanMode.check:
        return 'CHECKING';
      case null:
        return '';
    }
  }

  String get _modeHint {
    switch (widget.scanMode) {
      case ScanMode.shelve:
        return 'Scan to add items';
      case ScanMode.remove:
        return 'Scan to remove items';
      case ScanMode.check:
        return 'Scan to check stock';
      case null:
        return 'Position the barcode within the frame to scan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _toggleFlash,
            icon: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                );
              },
            ),
          ),
          IconButton(
            onPressed: _switchCamera,
            icon: const Icon(Icons.camera_rear),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: _onBarcodeDetected),
          // Overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
            ),
            child: Stack(
              children: [
                // Mode banner
                if (widget.scanMode != null)
                  Positioned(
                    top: 24,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _modeColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _modeLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Corner bracket overlay
                Center(
                  child: SizedBox(
                    width: 280,
                    height: 180,
                    child: CustomPaint(
                      painter: _CornerBracketPainter(color: _modeColor),
                    ),
                  ),
                ),
                // Instructions
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _modeHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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

class _CornerBracketPainter extends CustomPainter {
  final Color color;

  _CornerBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    const len = 30.0;

    // Top-left
    canvas.drawLine(const Offset(0, len), Offset.zero, paint);
    canvas.drawLine(Offset.zero, const Offset(len, 0), paint);

    // Top-right
    canvas.drawLine(Offset(size.width - len, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);

    // Bottom-left
    canvas.drawLine(
      Offset(0, size.height - len),
      Offset(0, size.height),
      paint,
    );
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);

    // Bottom-right
    canvas.drawLine(
      Offset(size.width, size.height - len),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - len, size.height),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
