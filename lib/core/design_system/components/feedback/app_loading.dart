import 'dart:math' as math;
import 'package:flutter/material.dart';

enum AppLoadingType { ring, dots, pulse, bars }

class AppLoading extends StatelessWidget {
  final AppLoadingType type;
  final double size;
  final Color? color;
  final String? message;
  final EdgeInsetsGeometry? padding;

  const AppLoading({
    super.key,
    this.type = AppLoadingType.ring,
    this.size = 36,
    this.color,
    this.message,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget loadingIndicator;
    final activeColor = color ?? Theme.of(context).colorScheme.primary;

    switch (type) {
      case AppLoadingType.ring:
        loadingIndicator = SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: math.max(2.0, size / 12.0),
            color: activeColor,
          ),
        );
        break;
      case AppLoadingType.dots:
        loadingIndicator = _DotsLoading(size: size, color: activeColor);
        break;
      case AppLoadingType.pulse:
        loadingIndicator = _PulseLoading(size: size, color: activeColor);
        break;
      case AppLoadingType.bars:
        loadingIndicator = _BarsLoading(size: size, color: activeColor);
        break;
    }

    if (message == null) {
      return padding != null ? Padding(padding: padding!, child: loadingIndicator) : loadingIndicator;
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        loadingIndicator,
        const SizedBox(height: 14),
        Text(
          message!,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    );

    return padding != null ? Padding(padding: padding!, child: content) : content;
  }
}

// ════════════════════════════════════════════════════════════
// Internal Animations (Copied from legacy with refactoring)
// ════════════════════════════════════════════════════════════

class _DotsLoading extends StatefulWidget {
  final double size;
  final Color color;
  const _DotsLoading({required this.size, required this.color});

  @override
  State<_DotsLoading> createState() => _DotsLoadingState();
}

class _DotsLoadingState extends State<_DotsLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
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
              final delay = index * 0.2;
              var value = _controller.value - delay;
              if (value < 0) value += 1.0;
              final scale = 0.5 + 0.5 * math.sin(value * math.pi * 2);

              return Transform.scale(scale: scale.clamp(0.0, 1.0), child: child);
            },
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
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

class _PulseLoadingState extends State<_PulseLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _opacityAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(opacity: _opacityAnimation.value, child: child),
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
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

class _BarsLoadingState extends State<_BarsLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();
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
              final delay = index * 0.2;
              var value = _controller.value - delay;
              if (value < 0) value += 1.0;
              final scaleY = 0.4 + 0.6 * math.sin(value * math.pi);

              return Transform.scale(scaleY: scaleY.clamp(0.0, 1.0), child: child);
            },
            child: Container(
              width: barWidth,
              height: widget.size,
              decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(barWidth / 2)),
            ),
          );
        }),
      ),
    );
  }
}
