import 'dart:math' as math;
import 'package:flutter/material.dart';

enum AppLoadingType { ring, dots, pulse, bars }

/// Unified loading component.
///
/// `AppLoading()` is the standard compact indicator.
/// `AppLoading.fullPage()` is the standard page/section loading state.
///
/// The full-page animation is built with Flutter primitives (no network,
/// no external animation file), so it remains reliable offline and on release.
class AppLoading extends StatelessWidget {
  final AppLoadingType type;
  final double size;
  final Color? color;
  final String? message;
  final EdgeInsetsGeometry? padding;
  final bool fullPage;

  const AppLoading({
    super.key,
    this.type = AppLoadingType.ring,
    this.size = 36,
    this.color,
    this.message,
    this.padding,
    this.fullPage = false,
  });

  const AppLoading.fullPage({
    super.key,
    this.size = 76,
    this.color,
    this.message,
    this.padding,
  })  : type = AppLoadingType.pulse,
        fullPage = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = color ?? theme.colorScheme.primary;

    final indicator = fullPage
        ? _PremiumPageLoading(size: size, color: activeColor)
        : _compactIndicator(activeColor);

    Widget content;
    if (fullPage) {
      content = Center(
        child: Padding(
          padding: padding ?? const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              indicator,
              const SizedBox(height: 18),
              Text(
                message ?? 'جاري التحميل...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (message == null) {
      content = indicator;
    } else {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(height: 14),
          Text(
            message!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    return padding != null && !fullPage
        ? Padding(padding: padding!, child: content)
        : content;
  }

  Widget _compactIndicator(Color activeColor) {
    switch (type) {
      case AppLoadingType.ring:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: math.max(2.0, size / 12.0),
            color: activeColor,
          ),
        );
      case AppLoadingType.dots:
        return _DotsLoading(size: size, color: activeColor);
      case AppLoadingType.pulse:
        return _PulseLoading(size: size, color: activeColor);
      case AppLoadingType.bars:
        return _BarsLoading(size: size, color: activeColor);
    }
  }
}

class _PremiumPageLoading extends StatefulWidget {
  final double size;
  final Color color;

  const _PremiumPageLoading({required this.size, required this.color});

  @override
  State<_PremiumPageLoading> createState() => _PremiumPageLoadingState();
}

class _PremiumPageLoadingState extends State<_PremiumPageLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoAsset = 'assets/images/logos/bhm_logo.png';

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final pulse = 0.94 + (math.sin(t * math.pi * 2) + 1) * 0.035;
        final rotation = t * math.pi * 2;

        return SizedBox(
          width: widget.size + 34,
          height: widget.size + 34,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: rotation,
                child: CustomPaint(
                  size: Size.square(widget.size + 24),
                  painter: _OrbitPainter(
                    color: widget.color,
                    progress: t,
                  ),
                ),
              ),
              Transform.scale(
                scale: pulse,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.18),
                        blurRadius: 22,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    logoAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.shopping_basket_rounded,
                      color: widget.color,
                      size: widget.size * .52,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final Color color;
  final double progress;

  const _OrbitPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 4;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = color.withValues(alpha: .12);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3
      ..color = color;

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      progress * math.pi * 2,
      math.pi * .72,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _DotsLoading extends StatefulWidget {
  final double size;
  final Color color;
  const _DotsLoading({required this.size, required this.color});

  @override
  State<_DotsLoading> createState() => _DotsLoadingState();
}

class _DotsLoadingState extends State<_DotsLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = widget.size / 4;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              var value = _controller.value - index * .2;
              if (value < 0) value += 1;
              final scale = .5 + .5 * math.sin(value * math.pi * 2);
              return Transform.scale(
                scale: scale.clamp(.0, 1.0),
                child: child,
              );
            },
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PulseLoading extends StatefulWidget {
  final double size;
  final Color color;
  const _PulseLoading({required this.size, required this.color});

  @override
  State<_PulseLoading> createState() => _PulseLoadingState();
}

class _PulseLoadingState extends State<_PulseLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: .65 + _controller.value * .35,
        child: Opacity(
          opacity: .45 + _controller.value * .55,
          child: child,
        ),
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _BarsLoading extends StatefulWidget {
  final double size;
  final Color color;
  const _BarsLoading({required this.size, required this.color});

  @override
  State<_BarsLoading> createState() => _BarsLoadingState();
}

class _BarsLoadingState extends State<_BarsLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barWidth = widget.size / 5;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              var value = _controller.value - index * .2;
              if (value < 0) value += 1;
              final scaleY = .4 + .6 * math.sin(value * math.pi);
              return Transform.scale(
                scaleY: scaleY.clamp(.0, 1.0),
                child: child,
              );
            },
            child: Container(
              width: barWidth,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(barWidth / 2),
              ),
            ),
          );
        }),
      ),
    );
  }
}
