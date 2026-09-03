import 'package:bhm_supermarket/app/localization/lang.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/design_system/components/app_icon.dart';
import '../../../core/design_system/patterns/app_responsive.dart';
import '../../../core/design_system/tokens/app_spacing.dart';
import '../../../core/design_system/tokens/app_typography.dart';
import '../../../core/utils/json_parser.dart';
import '../../../core/widgets/app_page_header.dart';
import '../controllers/info_controller.dart';
import '../models/about_us_model.dart';
import '../models/contact_info_model.dart';
import '../models/faq_model.dart';
import '../models/privacy_policy_model.dart';

enum InfoPageType { aboutUs, contactUs, faq, privacyPolicy }

/// Public content pages backed by the Content Management APIs.
///
/// The old hard-coded text has intentionally been removed: content now comes
/// from the backend and only active records are displayed.
class StaticInfoScreen extends StatefulWidget {
  final InfoPageType type;

  const StaticInfoScreen({super.key, required this.type});

  @override
  State<StaticInfoScreen> createState() => _StaticInfoScreenState();
}

class _StaticInfoScreenState extends State<StaticInfoScreen> {
  late final InfoController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<InfoController>();
    _load();
  }

  Future<void> _load() {
    switch (widget.type) {
      case InfoPageType.aboutUs:
        return controller.loadAboutUs();
      case InfoPageType.contactUs:
        return controller.loadContactInfos();
      case InfoPageType.faq:
        return controller.loadFaqs();
      case InfoPageType.privacyPolicy:
        return controller.loadPrivacyPolicies();
    }
  }

  String get _title {
    switch (widget.type) {
      case InfoPageType.aboutUs:
        return lang.t('about_us');
      case InfoPageType.contactUs:
        return lang.t('contact_us');
      case InfoPageType.faq:
        return lang.t('faq');
      case InfoPageType.privacyPolicy:
        return lang.t('privacy_policy');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppPageHeader(title: _title),
      body: GetBuilder<InfoController>(
        builder: (controller) {
          if (controller.isLoading && _isEmpty(controller)) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null && _isEmpty(controller)) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyLarge,
                    ),
                    SizedBox(height: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: _load,
                      icon: Icon(Icons.refresh),
                      label: Text(lang.t('retry')),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _load,
            child: AppConstrainedContent(
              child: _buildContent(context, controller),
            ),
          );
        },
      ),
    );
  }

  bool _isEmpty(InfoController c) {
    switch (widget.type) {
      case InfoPageType.aboutUs:
        return c.aboutUs.isEmpty;
      case InfoPageType.contactUs:
        return c.contactInfos.isEmpty;
      case InfoPageType.faq:
        return c.faqs.isEmpty;
      case InfoPageType.privacyPolicy:
        return c.privacyPolicies.isEmpty;
    }
  }

  Widget _buildContent(BuildContext context, InfoController c) {
    switch (widget.type) {
      case InfoPageType.aboutUs:
        return _AboutUsContent(items: c.aboutUs);
      case InfoPageType.contactUs:
        return _ContactContent(items: c.contactInfos);
      case InfoPageType.faq:
        return _FaqContent(items: c.faqs);
      case InfoPageType.privacyPolicy:
        return _PrivacyContent(items: c.privacyPolicies);
    }
  }
}

bool get _isArabic => JsonParser.currentLanguage == 'ar';

class _AboutUsContent extends StatelessWidget {
  final List<AboutUsModel> items;
  const _AboutUsContent({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _EmptyContent();
    return ListView.separated(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppSpacing.lg),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.lg),
      itemBuilder: (_, i) {
        final item = items[i];
        return _ContentCard(
          title: item.title(_isArabic),
          child: Text(
            item.description(_isArabic),
            style: AppTypography.bodyLarge.copyWith(height: 1.8),
          ),
        );
      },
    );
  }
}

class _ContactContent extends StatelessWidget {
  final List<ContactInfoModel> items;
  const _ContactContent({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _EmptyContent();
    return ListView.separated(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) {
        final item = items[i];
        return ListTile(
          leading: AppIcon(
            _iconForType(item.type),
            color: Theme.of(context).colorScheme.primary,
            size: AppIconSize.medium,
          ),
          title: Text(item.title(_isArabic), style: AppTypography.titleMedium),
          subtitle: Text(item.value(_isArabic)),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
        );
      },
    );
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'phone':
      case 'telephone':
        return Icons.phone_outlined;
      case 'whatsapp':
        return Icons.chat_outlined;
      case 'email':
        return Icons.email_outlined;
      case 'website':
        return Icons.language_outlined;
      case 'location':
        return Icons.location_on_outlined;
      default:
        return Icons.contact_support_outlined;
    }
  }
}

class _FaqContent extends StatelessWidget {
  final List<FaqModel> items;
  const _FaqContent({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _EmptyContent();
    return ListView.separated(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) {
        final item = items[i];
        return Card(
          child: ExpansionTile(
            title: Text(item.question(_isArabic),
                style: AppTypography.titleMedium),
            childrenPadding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  item.answer(_isArabic),
                  style: AppTypography.bodyLarge.copyWith(height: 1.7),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PrivacyContent extends StatelessWidget {
  final List<PrivacyPolicyModel> items;
  const _PrivacyContent({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _EmptyContent();
    return ListView.separated(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppSpacing.lg),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSpacing.lg),
      itemBuilder: (_, i) {
        final item = items[i];
        return _ContentCard(
          title: item.title(_isArabic),
          child: Text(
            item.content(_isArabic),
            style: AppTypography.bodyLarge.copyWith(height: 1.8),
          ),
        );
      },
    );
  }
}

class _ContentCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _ContentCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.titleLarge),
            SizedBox(height: AppSpacing.sm),
            child,
          ],
        ),
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Text(lang.t('no_data_available')),
      ),
    );
  }
}
