import '../../../../app/localization/lang.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/design_system/components/feedback/app_loading.dart';
import '../../../core/widgets/app_message.dart';
import '../../products/widgets/product_details_sheet.dart';
import '../controllers/barcode_scanner_controller.dart';
import 'widgets/manual_barcode_sheet.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with SingleTickerProviderStateMixin {
  late final MobileScannerController _scannerController;
  late final AnimationController _animController;
  late final Animation<double> _scanLineAnimation;

  bool _isProcessing = false;
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcodeDetected(String rawCode) async {
    if (_isProcessing || !mounted) return;

    final code = rawCode.trim();
    if (code.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    HapticFeedback.mediumImpact();
    await _scannerController.stop();

    if (!mounted) return;

    final controller = Get.find<BarcodeScannerController>();
    final product = await controller.lookupBarcode(code);

    if (!mounted) return;

    if (product != null) {
      // Product found: display ProductDetailsSheet
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ProductDetailsSheet(
          product: product,
          initialUnitIndex: controller.selectedUnitIndex,
        ),
      );

      // Once sheet is closed, prepare scanner for next scan
      if (mounted) {
        controller.reset();
        setState(() {
          _isProcessing = false;
        });
        await _scannerController.start();
      }
    } else {
      // Not found
      AppMessage.error(
        context,
        controller.errorMessage ?? lang.t('no_product_for_barcode_generic'),
      );

      await Future.delayed(Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        await _scannerController.start();
      }
    }
  }

  void _openManualEntry() {
    ManualBarcodeSheet.show(
      context: context,
      onSubmit: (code) async {
        await _handleBarcodeDetected(code);
      },
    );
  }

  void _toggleTorch() {
    _scannerController.toggleTorch();
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
  }

  @override
  Widget build(BuildContext context) {
  return GetBuilder<BarcodeScannerController>(
    builder: (_) => _buildGetX0(context));
  }

  Widget _buildGetX0(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.find<BarcodeScannerController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Camera Viewfinder
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              if (_isProcessing) return;
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final val = barcode.rawValue;
                if (val != null && val.isNotEmpty) {
                  _handleBarcodeDetected(val);
                  break;
                }
              }
            },
            errorBuilder: (context, error) {
              return _buildCameraFallback(
                message: lang.t('scanner_camera_error'),
              );
            },
          ),

          // 2. Scan Reticle Overlay
          if (!_isProcessing) _buildScannerOverlay(context),

          // 3. Top App Bar Header
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: AppIcon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: AppIconSize.medium,
                      ),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          lang.t('barcode_scanner'),
                          style: AppTypography.headlineSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          lang.t('point_camera_barcode'),
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Torch button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: AppIcon(
                        _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        color: _isTorchOn ? AppColors.accent : Colors.white,
                        size: AppIconSize.medium,
                      ),
                      onPressed: _toggleTorch,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Loading Overlay when searching
          if (_isProcessing || controller.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppLoading(
                        type: AppLoadingType.ring,
                        size: 36,
                        color: AppColors.primary,
                      ),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        lang.t('searching_product'),
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (controller.lastScannedBarcode != null) ...[
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          controller.lastScannedBarcode!,
                          style: AppTypography.labelSmall.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

          // 5. Bottom Action Bar (Manual Entry Button)
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: lang.t('enter_barcode_manual'),
                        icon: AppIcon(
                          Icons.keyboard_alt_outlined,
                          size: AppIconSize.small,
                          color: Colors.white,
                        ),
                        variant: AppButtonVariant.primary,
                        size: AppButtonSize.large,
                        onPressed: _openManualEntry,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanAreaSize = size.width * 0.72;

    return Center(
      child: SizedBox(
        width: scanAreaSize,
        height: scanAreaSize,
        child: Stack(
          children: [
            // Reticle Border Frame
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.6),
                  width: 2,
                ),
              ),
            ),

            // Corner Accents
            ..._buildCorners(),

            // Animated Laser Scan Line
            AnimatedBuilder(
              animation: _scanLineAnimation,
              builder: (context, _) {
                return Positioned(
                  top: scanAreaSize * _scanLineAnimation.value,
                  left: 8,
                  right: 8,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCorners() {
    const cornerSize = 24.0;
    const thickness = 4.0;
    const color = AppColors.primary;

    return [
      // Top-Left
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: thickness),
              left: BorderSide(color: color, width: thickness),
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.lg),
            ),
          ),
        ),
      ),
      // Top-Right
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: thickness),
              right: BorderSide(color: color, width: thickness),
            ),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(AppRadius.lg),
            ),
          ),
        ),
      ),
      // Bottom-Left
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: thickness),
              left: BorderSide(color: color, width: thickness),
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(AppRadius.lg),
            ),
          ),
        ),
      ),
      // Bottom-Right
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: thickness),
              right: BorderSide(color: color, width: thickness),
            ),
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(AppRadius.lg),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildCameraFallback({required String message}) {
    return Container(
      color: Colors.grey.shade900,
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: AppIconSize.large,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            AppButton(
              text: lang.t('enter_barcode_manual'),
              icon: AppIcon(
                Icons.keyboard_alt_outlined,
                size: AppIconSize.small,
                color: Colors.white,
              ),
              variant: AppButtonVariant.primary,
              size: AppButtonSize.large,
              onPressed: _openManualEntry,
            ),
          ],
        ),
      ),
    );
  }
}
