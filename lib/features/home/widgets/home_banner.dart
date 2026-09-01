import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/design_system/components/feedback/app_loading.dart';
import 'package:get/get.dart';

import 'package:bhm_supermarket/app/design/app_curves.dart';
import 'package:bhm_supermarket/app/design/app_durations.dart';
import 'package:bhm_supermarket/features/ads/controllers/ads_controller.dart';

import '../../ads/widgets/network_banner_card.dart';
import 'home_header.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  late final PageController _controller;

  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();

    _controller = PageController(viewportFraction: 1.0);

    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _autoScroll());
  }

  void _autoScroll() {
    if (!_controller.hasClients) return;

    final ads = Get.find<AdsController>().ads;

    if (ads.length <= 1) return;

    final nextPage = (_page + 1) % ads.length;

    _controller.animateToPage(
      nextPage,
      duration: AppDurations.slow,
      curve: AppCurves.standard,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  return GetBuilder<AdsController>(
    builder: (_) => _buildGetX0(context));
  }

  Widget _buildGetX0(BuildContext context) {
    final controller = Get.find<AdsController>();
    final ads = controller.ads;

    if (controller.loading) {
      return const SizedBox(
        height: 245,
        child: Center(child: AppLoading(type: AppLoadingType.dots, size: 18)),
      );
    }

    if (ads.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 245,
      child: Stack(
        children: [
          // ─────────────────────────────────────────────────────────
          // 1. Banner PageView (The actual visual background)
          // ─────────────────────────────────────────────────────────
          Positioned.fill(
            child: PageView.builder(
              controller: _controller,
              itemCount: ads.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                if (!mounted) return;

                setState(() {
                  _page = index;
                });
              },
              itemBuilder: (context, index) {
                return NetworkBannerCard(ad: ads[index]);
              },
            ),
          ),

          // ─────────────────────────────────────────────────────────
          // 2. Header Overlay (Top Overlay)
          // ─────────────────────────────────────────────────────────
          Positioned(
            top: 8,
            left: 16,
            right: 16,
            child: HomeHeader(isOverlay: true),
          ),

          // ─────────────────────────────────────────────────────────
          // 3. Page Indicators (Bottom Overlay)
          // ─────────────────────────────────────────────────────────
          if (ads.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(ads.length, (index) {
                  final active = index == _page;

                  return AnimatedContainer(
                    duration: AppDurations.normal,
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: active ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
