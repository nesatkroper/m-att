import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends HookWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isScanning = useState(true);
    final scanText = useState('Scanning...');

    // Scanner controller
    final scannerController = useMemoized(() => MobileScannerController(), []);

    // Animation controllers
    final overlayAnimation = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    final scanLineAnimation = useAnimationController(
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Start animations
    useEffect(() {
      overlayAnimation.forward();
      return null;
    }, const []);

    // Clean up controller on dispose
    useEffect(() {
      return () {
        scannerController.dispose();
        overlayAnimation.dispose();
        scanLineAnimation.dispose();
      };
    }, const []);

    // Handle scanner detection
    void onScannerDetection(BarcodeCapture capture) {
      if (!isScanning.value) return;

      final List<Barcode> barcodes = capture.barcodes;

      for (final barcode in barcodes) {
        if (barcode.rawValue != null) {
          final String qrCode = barcode.rawValue!;
          isScanning.value = false;
          scanText.value = 'QR Code detected!';

          // Delay to show success state before returning the result
          Future.delayed(const Duration(milliseconds: 800), () {
            if (context.mounted) {
              Navigator.of(context).pop(qrCode);
            }
          });

          break;
        }
      }
    }

    // Fade animation for overlay
    final fadeAnimation = CurvedAnimation(
      parent: overlayAnimation,
      curve: Curves.easeOut,
    );

    return Scaffold(
      body: Stack(
        children: [
          // QR Scanner
          MobileScanner(
            controller: scannerController,
            onDetect: onScannerDetection,
          ),

          // Overlay
          FadeTransition(
            opacity: fadeAnimation,
            child: SafeArea(
              child: Column(
                children: [
                  // App bar with close button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          color: Colors.white,
                        ),
                        Text(
                          'Scan QR Code',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => scannerController.toggleTorch(),
                          icon: const Icon(Icons.flash_on),
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Scan area overlay
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isScanning.value
                                  ? colorScheme.primary
                                  : Colors.green,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              // Scanner corners
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: isScanning.value
                                            ? colorScheme.primary
                                            : Colors.green,
                                        width: 6,
                                      ),
                                      left: BorderSide(
                                        color: isScanning.value
                                            ? colorScheme.primary
                                            : Colors.green,
                                        width: 6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: isScanning.value
                                            ? colorScheme.primary
                                            : Colors.green,
                                        width: 6,
                                      ),
                                      right: BorderSide(
                                        color: isScanning.value
                                            ? colorScheme.primary
                                            : Colors.green,
                                        width: 6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: isScanning.value
                                            ? colorScheme.primary
                                            : Colors.green,
                                        width: 6,
                                      ),
                                      left: BorderSide(
                                        color: isScanning.value
                                            ? colorScheme.primary
                                            : Colors.green,
                                        width: 6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: isScanning.value
                                            ? colorScheme.primary
                                            : Colors.green,
                                        width: 6,
                                      ),
                                      right: BorderSide(
                                        color: isScanning.value
                                            ? colorScheme.primary
                                            : Colors.green,
                                        width: 6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Scanning line animation
                              if (isScanning.value)
                                Positioned.fill(
                                  child: AnimatedBuilder(
                                    animation: scanLineAnimation,
                                    builder: (context, child) {
                                      return Align(
                                        alignment: Alignment(
                                          0,
                                          (scanLineAnimation.value * 2) - 1,
                                        ),
                                        child: child,
                                      );
                                    },
                                    child: Container(
                                      height: 2,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            colorScheme.primary
                                                .withOpacity(0.8),
                                            colorScheme.primary,
                                            colorScheme.primary
                                                .withOpacity(0.8),
                                            Colors.transparent,
                                          ],
                                          stops: const [
                                            0.0,
                                            0.2,
                                            0.5,
                                            0.8,
                                            1.0
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                              // Success icon
                              if (!isScanning.value)
                                const Center(
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 80,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Scan text
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              scanText.value,
                              key: ValueKey<String>(scanText.value),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Instructions
                  Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Position the QR code inside the frame to scan',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Dark overlay outside scan area
          Positioned.fill(
            child: FadeTransition(
              opacity: fadeAnimation,
              child: ClipPath(
                clipper: ScanAreaClipper(),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScanAreaClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final scanSize = 280.0;
    final left = (size.width - scanSize) / 2;
    final top = (size.height - scanSize) / 2;

    final cutOutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, scanSize, scanSize),
          const Radius.circular(12),
        ),
      );

    return Path.combine(PathOperation.difference, path, cutOutPath);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
