import 'dart:async' show Completer;
import 'dart:math' show pi, sin;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_radius.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ============================================================
  // Controllers
  // ============================================================

  late final AnimationController _mainController;
  late final AnimationController _particleController;
  late final AnimationController _gradientController;
  late final AnimationController _pulseController;

  // ============================================================
  // Animations
  // ============================================================

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  late final Animation<Offset> _titleOffset;
  late final Animation<double> _titleOpacity;

  late final Animation<Offset> _subtitleOffset;
  late final Animation<double> _subtitleOpacity;

  late final Animation<double> _loaderOpacity;
  late final Animation<double> _progressValue;

  @override
  void initState() {
    super.initState();

    // ------------------------------------------------------------
    // Main controller
    // ------------------------------------------------------------

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // ------------------------------------------------------------
    // Kept for project compatibility
    // ------------------------------------------------------------

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // ============================================================
    // Logo animation
    // ============================================================

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.00, 0.30, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.00, 0.38, curve: Curves.easeOutCubic),
      ),
    );

    // ============================================================
    // Title animation
    // ============================================================

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.20, 0.48, curve: Curves.easeOut),
      ),
    );

    _titleOffset =
        Tween<Offset>(begin: const Offset(0.0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.20, 0.48, curve: Curves.easeOutCubic),
      ),
    );

    // ============================================================
    // Subtitle animation
    // ============================================================

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.58, curve: Curves.easeOut),
      ),
    );

    _subtitleOffset =
        Tween<Offset>(begin: const Offset(0.0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.35, 0.58, curve: Curves.easeOutCubic),
      ),
    );

    // ============================================================
    // Loader animation
    // ============================================================

    _loaderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.55, 0.80, curve: Curves.easeOut),
      ),
    );

    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.58, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    // ============================================================
    // Navigation logic — KEEP AS IS
    // ============================================================

    _start();
  }

  // ============================================================
  // Navigation Logic
  // ============================================================

  Future<void> _start() async {
    await _mainController.forward();

    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_completed') ?? false;

    if (!mounted) return;

    final auth = Get.find<AuthController>();

    if (!auth.sessionInitialized) {
      final completer = Completer<void>();

      void listener() {
        if (auth.sessionInitialized && !completer.isCompleted) {
          completer.complete();
        }
      }

      auth.addListener(listener);

      try {
        await completer.future;
      } finally {
        auth.removeListener(listener);
      }
    }

    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    if (!completed) {
      context.go(AppRoutes.onboarding);
      return;
    }

    if (!auth.isLoggedIn) {
      context.go(AppRoutes.home);
      return;
    }

    switch (auth.user!.role) {
      case UserRole.admin:
        context.go(AppRoutes.adminReports);

      case UserRole.delivery:
        context.go(AppRoutes.deliveryHome);
        break;

      case UserRole.customer:
        final redirect = auth.consumePendingRedirect();
        context.go(redirect);
        break;
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    _gradientController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Color.fromARGB(255, 26, 17, 0),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 56, 41, 0),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            return Stack(
              fit: StackFit.expand,
              children: [
                // =================================================
                // Main background
                // =================================================
                _buildBackground(),

                // =================================================
                // Very subtle background texture
                // =================================================
                _buildSubtleTexture(),

                // =================================================
                // Bottom waves
                // =================================================
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: height * 0.19,
                  child: AnimatedBuilder(
                    animation: _gradientController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _BottomWavePainter(
                          animationValue: _gradientController.value,
                        ),
                        child: const SizedBox.expand(),
                      );
                    },
                  ),
                ),

                // =================================================
                // Main content
                // =================================================
                SafeArea(
                  child: Stack(
                    children: [
                      // ------------------------------------------------
                      // Logo
                      // ------------------------------------------------
                      Positioned(
                        top: height * 0.285,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: FadeTransition(
                            opacity: _logoOpacity,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: _buildLogo(width: width * 0.35),
                            ),
                          ),
                        ),
                      ),

                      // ------------------------------------------------
                      // Brand
                      // ------------------------------------------------
                      Positioned(
                        top: height * 0.458,
                        left: 0,
                        right: 0,
                        child: FadeTransition(
                          opacity: _titleOpacity,
                          child: SlideTransition(
                            position: _titleOffset,
                            // child: _buildBrand(),
                          ),
                        ),
                      ),

                      // ------------------------------------------------
                      // Subtitle
                      // ------------------------------------------------
                      Positioned(
                        top: height * 0.628,
                        left: 18,
                        right: 18,
                        child: FadeTransition(
                          opacity: _subtitleOpacity,
                          child: SlideTransition(
                            position: _subtitleOffset,
                            child: const Text(
                              'جودة تستحقها.. أسعار تناسبك',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFFEFE8FF),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ------------------------------------------------
                      // Bottom progress indicator
                      // ------------------------------------------------
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: height * 0.055,
                        child: FadeTransition(
                          opacity: _loaderOpacity,
                          child: Center(child: _buildProgressBar()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // Background
  // ============================================================

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        final t = _gradientController.value;

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: const Alignment(-0.85, -1.0),
              end: const Alignment(0.9, 1.0),
              colors: [
                Color.lerp(
                  const Color.fromARGB(255, 197, 161, 0),
                  const Color.fromARGB(255, 151, 121, 23),
                  t,
                )!,
                Color.lerp(
                  const Color.fromARGB(255, 145, 123, 23),
                  const Color.fromARGB(255, 167, 118, 26),
                  t,
                )!,
                Color.lerp(
                  const Color.fromARGB(255, 145, 133, 23),
                  const Color.fromARGB(255, 151, 149, 23),
                  t,
                )!,
              ],
              stops: const [0.0, 0.52, 1.0],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // Very subtle decorative texture
  // ============================================================

  Widget _buildSubtleTexture() {
    return IgnorePointer(
      child: CustomPaint(
        painter: _TexturePainter(),
        child: const SizedBox.expand(),
      ),
    );
  }

  // ============================================================
  // Logo
  // ============================================================

  Widget _buildLogo({required double width}) {
    return Image.asset(
      'assets/images/logos/logo2.png',
      width: width,
      fit: BoxFit.contain,
    );
  }

  // ============================================================
  // Brand
  // ============================================================

  // ============================================================
  // Progress bar
  // ============================================================

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressValue,
      builder: (context, child) {
        return SizedBox(
          width: 62,
          height: 4,
          child: ClipRRect(
            borderRadius: AppRadius.pillRadius,
            child: Stack(
              children: [
                // Track
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                    ),
                  ),
                ),

                // Progress
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: _progressValue.value,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.pillRadius,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ================================================================
// Bottom Wave Painter
// ================================================================

class _BottomWavePainter extends CustomPainter {
  final double animationValue;

  const _BottomWavePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final shift = sin(animationValue * pi * 2) * 3;

    // ------------------------------------------------------------
    // Back wave
    // ------------------------------------------------------------

    final backPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color.fromARGB(82, 189, 129, 0);

    final backPath = Path();

    backPath.moveTo(0, size.height * 0.56);

    backPath.cubicTo(
      size.width * 0.14,
      size.height * 0.39 + shift,
      size.width * 0.27,
      size.height * 0.48,
      size.width * 0.39,
      size.height * 0.59,
    );

    backPath.cubicTo(
      size.width * 0.56,
      size.height * 0.73,
      size.width * 0.71,
      size.height * 0.54,
      size.width * 0.83,
      size.height * 0.47,
    );

    backPath.cubicTo(
      size.width * 0.92,
      size.height * 0.42,
      size.width * 0.97,
      size.height * 0.49,
      size.width,
      size.height * 0.46,
    );

    backPath.lineTo(size.width, size.height);

    backPath.lineTo(0, size.height);

    backPath.close();

    canvas.drawPath(backPath, backPaint);

    // ------------------------------------------------------------
    // Front wave
    // ------------------------------------------------------------

    final frontPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color.fromARGB(82, 255, 217, 0);

    final frontPath = Path();

    frontPath.moveTo(0, size.height * 0.73);

    frontPath.cubicTo(
      size.width * 0.16,
      size.height * 0.56,
      size.width * 0.29,
      size.height * 0.72,
      size.width * 0.44,
      size.height * 0.75,
    );

    frontPath.cubicTo(
      size.width * 0.58,
      size.height * 0.79,
      size.width * 0.72,
      size.height * 0.64,
      size.width * 0.84,
      size.height * 0.61,
    );

    frontPath.cubicTo(
      size.width * 0.92,
      size.height * 0.58,
      size.width * 0.97,
      size.height * 0.61,
      size.width,
      size.height * 0.58,
    );

    frontPath.lineTo(size.width, size.height);

    frontPath.lineTo(0, size.height);

    frontPath.close();

    canvas.drawPath(frontPath, frontPaint);
  }

  @override
  bool shouldRepaint(covariant _BottomWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// ================================================================
// Subtle Texture Painter
// ================================================================

class _TexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.018);

    const dotSize = 1.2;

    for (double y = 20; y < size.height * 0.72; y += 24) {
      for (double x = 18; x < size.width; x += 24) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
