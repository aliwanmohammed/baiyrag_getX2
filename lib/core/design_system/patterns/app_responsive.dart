import 'package:flutter/material.dart';

import 'app_breakpoints.dart';

/// AppConstrainedContent: Automatically manages maximum layout width and horizontal padding.
/// Usage: Wrap your top-level Feature screens in this widget so that when they are viewed
/// on Desktop or Tablets, the UI doesn't stretch infinitely.
class AppConstrainedContent extends StatelessWidget {
  final Widget child;
  final bool addHorizontalPadding;

  const AppConstrainedContent({
    super.key,
    required this.child,
    this.addHorizontalPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppLayout.maxPageWidth),
        child: Padding(
          padding: addHorizontalPadding ? AppLayout.getHorizontalPadding(context) : EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}

/// AppAdaptiveGrid: Responsive Grid layout helper.
/// Automatically calculates cross axis count based on available width and a minimum item width constraint.
class AppAdaptiveGrid extends StatelessWidget {
  final double minItemWidth;
  final double spacing;
  final double runSpacing;
  final int? maxColumns;
  final Widget Function(BuildContext, int) itemBuilder;
  final int itemCount;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final double childAspectRatio;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;

  const AppAdaptiveGrid({
    super.key,
    required this.minItemWidth,
    required this.itemCount,
    required this.itemBuilder,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.maxColumns,
    this.shrinkWrap = false,
    this.physics,
    this.childAspectRatio = 1.0,
    this.controller,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = (constraints.maxWidth / minItemWidth).floor();
        if (crossAxisCount < 1) crossAxisCount = 1;
        if (maxColumns != null && crossAxisCount > maxColumns!) {
          crossAxisCount = maxColumns!;
        }

        return GridView.builder(
          controller: controller,
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}
