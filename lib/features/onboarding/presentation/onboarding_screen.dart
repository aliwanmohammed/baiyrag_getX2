import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/localization/language_controller.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/design_system/components/app_button.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/design_system/patterns/app_responsive.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // Page Controller
  // ============================================================

  late final PageController _pageController;

  // ============================================================
  // Existing animation structure
  // ============================================================

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // ============================================================
  // Current page
  // ============================================================

  int _currentPage = 0;

  // ============================================================
  // Onboarding data
  // ============================================================

  final List<OnboardingItem> _pages = const [
    OnboardingItem(
      image: 'assets/images/logos/onpo1.png',
      titleAr: 'تسوق كل ما تحتاجه',
      titleEn: 'Shop Everything You Need',
      descriptionAr:
          'آلاف المنتجات بجودة عالية واختيارات تناسب احتياجاتك اليومية.',
      descriptionEn:
          'Thousands of quality products and choices for all your daily needs.',
    ),
    OnboardingItem(
      image: 'assets/images/logos/onpo2.png',
      titleAr: 'توصيل سريع وآمن',
      titleEn: 'Fast & Secure Delivery',
      descriptionAr:
          'نصل إليك أينما كنت وفي الوقت الذي يناسبك، بكل سرعة وأمان.',
      descriptionEn:
          'We deliver wherever you are, whenever you need it, quickly and safely.',
    ),
    OnboardingItem(
      image: 'assets/images/logos/onpo3.png',
      titleAr: 'طرق دفع متعددة وآمنة',
      titleEn: 'Multiple & Secure Payments',
      descriptionAr:
          'اختر طريقة الدفع التي تناسبك وتمتع بتجربة تسوق آمنة وموثوقة.',
      descriptionEn:
          'Choose the payment method that suits you for a secure shopping experience.',
    ),
    OnboardingItem(
      image: 'assets/images/logos/onpo4.png',
      titleAr: 'تجربة تسوق مميزة',
      titleEn: 'A Better Shopping Experience',
      descriptionAr:
          'نحن هنا لنجعل حياتك أسهل ونوفر لك كل ما تحتاجه في مكان واحد.',
      descriptionEn:
          'We are here to make your life easier with everything you need in one place.',
    ),
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _pageController = PageController();

    // ------------------------------------------------------------
    // Existing animation controller retained
    // ------------------------------------------------------------

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // Complete onboarding
  // ============================================================

  Future<void> _completeOnboarding(String targetRoute) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('onboarding_completed', true);

    if (!mounted) return;

    context.go(targetRoute);
  }

  // ============================================================
  // Next page
  // ============================================================

  Future<void> _nextPage() async {
    if (_currentPage >= _pages.length - 1) {
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  // ============================================================
  // Start shopping
  // ============================================================

  Future<void> _startShopping() async {
    await _completeOnboarding(AppRoutes.home);
  }

  // ============================================================
  // Skip onboarding
  // ============================================================

  Future<void> _skipOnboarding() async {
    await _completeOnboarding(AppRoutes.home);
  }

  // ============================================================
  // Page changed
  // ============================================================

  void _onPageChanged(int page) {
    if (!mounted) return;

    setState(() {
      _currentPage = page;
    });

    // Restart page animation
    _animationController.reset();
    _animationController.forward();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(
      builder: (_) => _buildWithLanguage(context),
    );
  }

  Widget _buildWithLanguage(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final isArabic = languageController.isArabic;

    final size = MediaQuery.sizeOf(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: AppConstrainedContent(
          child: Column(
            children: [
              // ======================================================
              // TOP BAR
              // ======================================================
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ------------------------------------------------
                    // Language
                    // ------------------------------------------------
                    _buildLanguageButton(languageController, isArabic, colorScheme),

                    // ------------------------------------------------
                    // Skip
                    // ------------------------------------------------
                    TextButton(
                      onPressed: _skipOnboarding,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        isArabic ? 'تخطي' : 'Skip',
                        style: AppTypography.bodyMedium.copyWith(
                          color: colorScheme.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ======================================================
              // PAGE VIEW
              // ======================================================
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: _onPageChanged,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = _pages[index];

                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildPage(
                          item: item,
                          isArabic: isArabic,
                          size: size,
                          colorScheme: colorScheme,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ======================================================
              // BOTTOM NAVIGATION
              // ======================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                child: Column(
                  children: [
                    // ------------------------------------------------
                    // Page indicators
                    // ------------------------------------------------
                    _buildPageIndicator(colorScheme),

                    const SizedBox(height: AppSpacing.xl),

                    // ------------------------------------------------
                    // Navigation
                    // ------------------------------------------------
                    _buildBottomNavigation(
                      isArabic: isArabic,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PAGE
  // ============================================================

  Widget _buildPage({
    required OnboardingItem item,
    required bool isArabic,
    required Size size,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
      ),
      child: Column(
        children: [
          // ======================================================
          // IMAGE AREA
          // ======================================================

          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
                child: Image.asset(
                  item.image,
                  width: size.width * 0.68,
                  height: size.height * 0.34,
                  fit: BoxFit.contain,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return _buildImageError(colorScheme);
                  },
                ),
              ),
            ),
          ),

          // ======================================================
          // TEXT AREA
          // ======================================================

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --------------------------------------------------
              // TITLE
              // --------------------------------------------------

              Text(
                isArabic ? item.titleAr : item.titleEn,
                textAlign: TextAlign.center,
                style: AppTypography.headlineSmall.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),

              // --------------------------------------------------
              // SPACE BETWEEN TITLE AND DESCRIPTION
              // --------------------------------------------------

              const SizedBox(
                height: AppSpacing.lg,
              ),

              // --------------------------------------------------
              // DESCRIPTION
              // --------------------------------------------------

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
                child: Text(
                  isArabic ? item.descriptionAr : item.descriptionEn,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colorScheme.outline,
                    height: 1.7,
                  ),
                ),
              ),
            ],
          ),

          // ======================================================
          // SPACE BEFORE BOTTOM NAVIGATION
          // ======================================================

          const SizedBox(
            height: AppSpacing.xl,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LANGUAGE BUTTON
  // ============================================================

  Widget _buildLanguageButton(
    LanguageController languageController,
    bool isArabic,
    ColorScheme colorScheme,
  ) {
    return TextButton(
      onPressed: () {
        languageController.toggle();
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(
            Icons.language_rounded,
            size: AppIconSize.small,
            color: colorScheme.outline,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            isArabic ? 'English' : 'العربية',
            style: AppTypography.bodySmall.copyWith(
              color: colorScheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAGE INDICATOR
  // ============================================================

  Widget _buildPageIndicator(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        final isActive = index == _currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 22 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  Widget _buildBottomNavigation({
    required bool isArabic,
    required ColorScheme colorScheme,
  }) {
    final isLastPage = _currentPage == _pages.length - 1;

    return SizedBox(
      height: 52,
      child: Row(
        children: [
          if (!isLastPage)
            TextButton(
              onPressed: _nextPage,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                ),
              ),
              child: Text(
                isArabic ? 'التالي' : 'Next',
                style: AppTypography.bodyMedium.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (isLastPage)
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: AppButton(
                  text: isArabic ? 'ابدأ بالتسوق الآن' : 'Start Shopping Now',
                  onPressed: _startShopping,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // IMAGE ERROR
  // ============================================================

  Widget _buildImageError(ColorScheme colorScheme) {
    return Center(
      child: AppIcon(
        Icons.image_not_supported_outlined,
        color: colorScheme.surfaceContainerHighest,
        size: AppIconSize.large,
      ),
    );
  }
}

// ================================================================
// ONBOARDING ITEM MODEL
// ================================================================

class OnboardingItem {
  final String image;

  final String titleAr;
  final String titleEn;

  final String descriptionAr;
  final String descriptionEn;

  const OnboardingItem({
    required this.image,
    required this.titleAr,
    required this.titleEn,
    required this.descriptionAr,
    required this.descriptionEn,
  });
}
