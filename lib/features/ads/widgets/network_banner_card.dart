import 'package:bhm_supermarket/app/localization/lang.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_typography.dart';
import '../../../app/widgets/app_cached_image.dart';
import '../models/ad_model.dart';

class NetworkBannerCard extends StatelessWidget {
  final AdModel ad;

  const NetworkBannerCard({super.key, required this.ad});

  Future<void> _openUrl() async {
    if (ad.url.isEmpty) return;

    final uri = Uri.tryParse(ad.url);
    if (uri == null) return;

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: ad.url.isEmpty ? null : _openUrl,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ─────────────────────────────────────────────────────────
          // 1. Background Image
          // ─────────────────────────────────────────────────────────
          AppCachedImage(imageUrl: ad.image, fit: BoxFit.cover),

          // ─────────────────────────────────────────────────────────
          // 2. Top & Bottom Contrast Gradients
          // ─────────────────────────────────────────────────────────
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.40),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.50),
                ],
                stops: [0.0, 0.40, 1.0],
              ),
            ),
          ),

          // Side Gradient for Text Readability
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: rtl ? Alignment.centerRight : Alignment.centerLeft,
                end: rtl ? Alignment.centerLeft : Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),

          // ─────────────────────────────────────────────────────────
          // 3. Content Area (Below Header Overlay)
          // ─────────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(20, 68, 20, 24),
            child: Align(
              alignment: rtl ? Alignment.centerRight : Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 240),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      rtl ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ad.title.isNotEmpty)
                      Text(
                        ad.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: rtl ? TextAlign.right : TextAlign.left,
                        style: AppTypography.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 21,
                          height: 1.2,
                        ),
                      ),
                    if (ad.description.isNotEmpty) ...[
                      SizedBox(height: 5),
                      Text(
                        ad.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: rtl ? TextAlign.right : TextAlign.left,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5,
                          height: 1.3,
                        ),
                      ),
                    ],
                    if (ad.url.isNotEmpty) ...[
                      SizedBox(height: 10),
                      _BannerAction(rtl: rtl, onTap: _openUrl),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerAction extends StatelessWidget {
  final bool rtl;
  final VoidCallback onTap;

  const _BannerAction({required this.rtl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Color(0xFFFF5722),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFFF5722).withValues(alpha: 0.35),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            lang.t('see_coupons_offers'),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
            ),
          ),
        ),
      ),
    );
  }
}
