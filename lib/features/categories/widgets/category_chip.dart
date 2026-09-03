import 'package:bhm_supermarket/app/localization/lang.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/app_typography.dart';
import '../../../app/widgets/app_cached_image.dart';
import '../../../core/design_system/components/app_icon.dart';
import '../../../core/models/category_model.dart';

class CategoryChip extends StatelessWidget {
  final CategoryModel? category;
  final bool selected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    this.category,
    required this.selected,
    required this.onTap,
  });

  /// Semantic category icon resolver supporting Arabic & English keywords
  static IconData resolveCategoryIcon(String rawName) {
    if (rawName.isEmpty) return Icons.category_outlined;

    var name = rawName.trim().toLowerCase();
    name = name
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');

    // 1. Dairy / ألبان / حليب / جبن / قشطة / زبدة
    if (name.contains('لبن') ||
        name.contains('حليب') ||
        name.contains('جبن') ||
        name.contains('قشط') ||
        name.contains('زبد') ||
        name.contains('زباد') ||
        name.contains('dairy') ||
        name.contains('milk') ||
        name.contains('cheese') ||
        name.contains('butter') ||
        name.contains('yogurt')) {
      return Icons.egg_alt_outlined;
    }

    // 2. Beverages / Drinks / مشروبات / عصائر / مياه / شاي / قهوة
    if (name.contains('مشروب') ||
        name.contains('عصير') ||
        name.contains('عصاير') ||
        name.contains('مياه') ||
        name.contains('ماي') ||
        name.contains('ماء') ||
        name.contains('شاي') ||
        name.contains('قهو') ||
        name.contains('غازي') ||
        name.contains('beverage') ||
        name.contains('drink') ||
        name.contains('juice') ||
        name.contains('water') ||
        name.contains('tea') ||
        name.contains('coffee') ||
        name.contains('soda')) {
      return Icons.local_drink_outlined;
    }

    // 3. Vegetables & Fruits / خضروات / فواكه / طازج / تمور
    if (name.contains('خضار') ||
        name.contains('خضروات') ||
        name.contains('فواكه') ||
        name.contains('فاكه') ||
        name.contains('طازج') ||
        name.contains('تمر') ||
        name.contains('تمور') ||
        name.contains('vegetable') ||
        name.contains('fruit') ||
        name.contains('fresh') ||
        name.contains('date')) {
      return Icons.eco_outlined;
    }

    // 4. Meat / Poultry / Fish / لحوم / دجاج / دواجن / أسماك / بحريات
    if (name.contains('لحم') ||
        name.contains('لحوم') ||
        name.contains('دجاج') ||
        name.contains('دواجن') ||
        name.contains('سمك') ||
        name.contains('اسماك') ||
        name.contains('بحري') ||
        name.contains('meat') ||
        name.contains('chicken') ||
        name.contains('poultry') ||
        name.contains('fish') ||
        name.contains('seafood')) {
      return Icons.set_meal_outlined;
    }

    // 5. Bakery & Bread / مخبوزات / خبز / معجنات / كيك / حلويات
    if (name.contains('مخبوز') ||
        name.contains('خبز') ||
        name.contains('معجن') ||
        name.contains('كيك') ||
        name.contains('حلوي') ||
        name.contains('حلي') ||
        name.contains('شوكولات') ||
        name.contains('بسكويت') ||
        name.contains('bakery') ||
        name.contains('bread') ||
        name.contains('pastry') ||
        name.contains('cake') ||
        name.contains('sweet') ||
        name.contains('dessert') ||
        name.contains('chocolate')) {
      return Icons.bakery_dining_outlined;
    }

    // 6. Snacks & Chips / وجبات خفيفة / تسالي / مكسرات / شيبس / مقرمشات
    if (name.contains('وجب') ||
        name.contains('خفيف') ||
        name.contains('سناك') ||
        name.contains('شيبس') ||
        name.contains('تسال') ||
        name.contains('مكسر') ||
        name.contains('مقرمش') ||
        name.contains('فشار') ||
        name.contains('snack') ||
        name.contains('chips') ||
        name.contains('nuts') ||
        name.contains('popcorn') ||
        name.contains('cracker')) {
      return Icons.fastfood_outlined;
    }

    // 7. Frozen / مجمدات / مثلجات / آيس كريم
    if (name.contains('مجمد') ||
        name.contains('مثلج') ||
        name.contains('ايسكريم') ||
        name.contains('ايس كريم') ||
        name.contains('بوظ') ||
        name.contains('frozen') ||
        name.contains('ice cream') ||
        name.contains('icecream')) {
      return Icons.ac_unit_outlined;
    }

    // 8. Offers & Discounts / عروض / تخفيضات / خصومات / كوبونات
    if (name.contains('عرض') ||
        name.contains('عروض') ||
        name.contains(lang.t('discount')) ||
        name.contains('خصومات') ||
        name.contains('تخفيض') ||
        name.contains('كوبون') ||
        name.contains('توفير') ||
        name.contains('offer') ||
        name.contains('deal') ||
        name.contains('discount') ||
        name.contains('sale') ||
        name.contains('coupon')) {
      return Icons.local_offer_rounded;
    }

    // 9. Cleaning & Detergents / منظفات / نظافة / غسيل / مطهرات
    if (name.contains('نظاف') ||
        name.contains('منظف') ||
        name.contains('غسيل') ||
        name.contains('مطهر') ||
        name.contains('صابون') ||
        name.contains('شامبو') ||
        name.contains('cleaning') ||
        name.contains('detergent') ||
        name.contains('wash') ||
        name.contains('soap') ||
        name.contains('disinfectant')) {
      return Icons.cleaning_services_outlined;
    }

    // 10. Personal Care & Pharmacy / عناية شخصية / تجميل / عطور / صيدلية
    if (name.contains('عناي') ||
        name.contains('تجميل') ||
        name.contains('عطر') ||
        name.contains('عطور') ||
        name.contains('مكياج') ||
        name.contains('صيدل') ||
        name.contains('صحي') ||
        name.contains('personal') ||
        name.contains('care') ||
        name.contains('beauty') ||
        name.contains('perfume') ||
        name.contains('pharmacy') ||
        name.contains('health')) {
      return Icons.sanitizer_outlined;
    }

    // 11. Baby / أطفال / رضع / حفاضات / بيبي
    if (name.contains('طفل') ||
        name.contains('اطفال') ||
        name.contains('رضيع') ||
        name.contains('رضع') ||
        name.contains('حفاض') ||
        name.contains('بيبي') ||
        name.contains('baby') ||
        name.contains('kids') ||
        name.contains('diaper') ||
        name.contains('infant')) {
      return Icons.child_care_outlined;
    }

    // 12. Pantry & Canned / تموين / بقالة / معلبات / أرز / زيت / سكر / بهارات / عطارة
    if (name.contains('تموين') ||
        name.contains('بقال') ||
        name.contains('معلب') ||
        name.contains('ارز') ||
        name.contains('رز') ||
        name.contains('زيت') ||
        name.contains('سكر') ||
        name.contains('بهار') ||
        name.contains('عطار') ||
        name.contains('بقول') ||
        name.contains('حبوب') ||
        name.contains('طحين') ||
        name.contains('دقيق') ||
        name.contains('مكرون') ||
        name.contains('صلص') ||
        name.contains('pantry') ||
        name.contains('grocery') ||
        name.contains('canned') ||
        name.contains('rice') ||
        name.contains('oil') ||
        name.contains('sugar') ||
        name.contains('spice') ||
        name.contains('pasta') ||
        name.contains('flour') ||
        name.contains('grain')) {
      return Icons.kitchen_outlined;
    }

    return Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final title = category?.name ?? 'الكل';
    final isSpecialOffers = category?.id == 'special_offers';
    final isAll = category == null;

    return SizedBox(
      width: 62,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Rounded Square Card matching reference image ────────────
            AnimatedContainer(
              duration: Duration(milliseconds: 180),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isAll && selected
                      ? Color(0xFFD97706)
                      : (isSpecialOffers && selected
                          ? Color(0xFFE53935)
                          : (selected ? Color(0xFFD97706) : Color(0xFFEEEEEE))),
                  width: selected ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(alpha: selected ? 0.08 : 0.03),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: isAll
                    ? Center(
                        child: AppIcon(
                          Icons.grid_view_rounded,
                          color: Color(0xFFD97706),
                          size: AppIconSize.medium,
                        ),
                      )
                    : isSpecialOffers
                        ? Center(
                            child: AppIcon(
                              Icons.local_offer_rounded,
                              color: Color(0xFFE53935),
                              size: AppIconSize.medium,
                            ),
                          )
                        : Hero(
                            tag: 'cat_${category!.id}',
                            child: category!.imageUrl.isNotEmpty
                                ? AppCachedImage(
                                    imageUrl: category!.imageUrl,
                                    fit: BoxFit.contain,
                                    radius: 0,
                                  )
                                : Center(
                                    child: AppIcon(
                                      resolveCategoryIcon(category!.name),
                                      color: selected
                                          ? Color(0xFFD97706)
                                          : Color(0xFF424242),
                                      size: AppIconSize.medium,
                                    ),
                                  ),
                          ),
              ),
            ),
            SizedBox(height: 5),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 11.5,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: isAll
                    ? Color(0xFFD97706)
                    : (isSpecialOffers
                        ? (selected ? Color(0xFFE53935) : Color(0xFF2D2D2D))
                        : (selected ? Color(0xFFD97706) : Color(0xFF2D2D2D))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
