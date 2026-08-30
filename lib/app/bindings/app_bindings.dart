import 'package:get/get.dart';

import '../di/dependency_injection.dart';
import '../localization/language_controller.dart';
import '../theme/theme_controller.dart';
import '../../features/address/controllers/address_controller.dart';
import '../../features/admin/controllers/admin_reports_controller.dart';
import '../../features/ads/controllers/ads_controller.dart';
import '../../features/ads/controllers/offers_controller.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/cart/controllers/cart_controller.dart';
import '../../features/categories/controllers/category_controller.dart';
import '../../features/coupons/controllers/coupon_controller.dart';
import '../../features/checkout/controllers/checkout_controller.dart';
import '../../features/delivery/controllers/delivery_controller.dart';
import '../../features/favorites/controllers/favorites_controller.dart';
import '../../features/home/controllers/home_controller.dart';
import '../../features/navigation/controllers/navigation_controller.dart';
import '../../features/orders/controllers/orders_controller.dart';
import '../../features/products/controllers/product_controller.dart';
import '../../features/search/controllers/product_search_controller.dart';
import '../../features/scanner/controllers/barcode_scanner_controller.dart';

/// Application composition root.
///
/// Infrastructure/repositories are lazy and recreated only when required.
/// Long-lived application state is permanent; feature controllers use fenix
/// so their instances can be recreated after disposal.
class AppBindings extends Bindings {
  @override
  void dependencies() {
    DependencyInjection.register();

    Get.put<ThemeController>(
      ThemeController(),
      permanent: true,
    );

    Get.put<LanguageController>(
      LanguageController(),
      permanent: true,
    );

    Get.put<AuthController>(
      AuthController(Get.find()),
      permanent: true,
    );

    Get.lazyPut<CartController>(
      () => CartController(Get.find(), Get.find()),
      fenix: true,
    );

    Get.lazyPut<FavoritesController>(
      () => FavoritesController(
        Get.find(),
        Get.find(),
        Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut<NavigationController>(
      NavigationController.new,
      fenix: true,
    );

    Get.lazyPut<AddressController>(
      () => AddressController(Get.find()),
      fenix: true,
    );

    Get.lazyPut<CategoryController>(
      () => CategoryController(Get.find()),
      fenix: true,
    );

    Get.lazyPut<HomeController>(
      () => HomeController(Get.find()),
      fenix: true,
    );

    Get.lazyPut<ProductController>(
      () => ProductController(Get.find()),
      fenix: true,
    );

    Get.lazyPut<ProductSearchController>(
      () => ProductSearchController(Get.find()),
      fenix: true,
    );

    Get.lazyPut<AdsController>(
      () => AdsController(Get.find()),
      fenix: true,
    );

    Get.lazyPut<OffersController>(
      () => OffersController(Get.find()),
      fenix: true,
    );

    Get.lazyPut<OrdersController>(
      () => OrdersController(
        Get.find(),
        Get.find<AuthController>(),
      ),
      fenix: true,
    );

    Get.lazyPut<DeliveryController>(
      () => DeliveryController(Get.find()),
      fenix: true,
    );

    Get.lazyPut<CouponController>(
      () => CouponController(Get.find()),
      fenix: true,
    );

    Get.lazyPut<CheckoutController>(
      () => CheckoutController(
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find(),
      ),
      fenix: true,
    );

    Get.lazyPut<AdminReportsController>(
      () => AdminReportsController(Get.find()),
      fenix: true,
    );

    Get.lazyPut<BarcodeScannerController>(
      () => BarcodeScannerController(Get.find()),
      fenix: true,
    );
  }
}
