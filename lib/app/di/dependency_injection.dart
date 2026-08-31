import 'package:get/get.dart';

import '../../core/api/api_client.dart';
import '../../core/services/secure_storage_service.dart';
import '../../features/address/data/datasources/address_remote_datasource.dart';
import '../../features/address/data/repositories/address_repository_impl.dart';
import '../../features/address/domain/repositories/address_repository.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/categories/data/datasources/category_remote_datasource.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/orders/data/datasources/order_remote_datasource.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/products/data/datasources/product_remote_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/cart/data/datasource/cart_remote_datasource.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/favorites/data/datasources/favorites_remote_datasource.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/ads/data/datasources/ads_remote_datasource.dart';
import '../../features/ads/data/repositories/ads_repository_impl.dart';
import '../../features/ads/domain/repositories/ads_repository.dart';
import '../../features/ads/data/datasources/offers_remote_datasource.dart';
import '../../features/ads/data/repositories/offers_repository_impl.dart';
import '../../features/ads/domain/repositories/offers_repository.dart';
import '../../features/delivery/data/datasources/delivery_remote_datasource.dart';
import '../../features/delivery/data/repositories/delivery_repository_impl.dart';
import '../../features/delivery/domain/repositories/delivery_repository.dart';
import '../../features/coupons/data/datasources/coupon_remote_datasource.dart';
import '../../features/coupons/data/repositories/coupon_repository_impl.dart';
import '../../features/coupons/domain/repositories/coupon_repository.dart';
import '../../features/admin/data/datasources/admin_reports_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_reports_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_reports_repository.dart';
import '../../features/info/data/datasources/info_remote_datasource.dart';
import '../../features/info/data/repositories/info_repository_impl.dart';
import '../../features/info/domain/repositories/info_repository.dart';

/// GetX dependency composition root.
///
/// All infrastructure and repository dependencies are registered lazily here.
/// Feature controllers resolve their dependencies through Get.find(), which
/// keeps construction centralized and makes the graph replaceable in tests.
class DependencyInjection {
  DependencyInjection._();

  static void register() {
    Get.lazyPut<ApiClient>(() => ApiClient.instance, fenix: true);
    Get.lazyPut<SecureStorageService>(
      () => SecureStorageService.instance,
      fenix: true,
    );

    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        AuthRemoteDataSource(Get.find<ApiClient>().dio),
        Get.find<SecureStorageService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ProductRepository>(
      () => ProductRepositoryImpl(
        ProductRemoteDataSource(Get.find<ApiClient>().dio),
      ),
      fenix: true,
    );

    Get.lazyPut<AdsRepository>(
      () => AdsRepositoryImpl(
        AdsRemoteDataSource(Get.find<ApiClient>().dio),
      ),
      fenix: true,
    );

    Get.lazyPut<OffersRepository>(
      () => OffersRepositoryImpl(
        OffersRemoteDataSource(Get.find<ApiClient>().dio),
      ),
      fenix: true,
    );

    Get.lazyPut<CartRepository>(
      () => CartRepositoryImpl(
        CartRemoteDataSource(Get.find<ApiClient>().dio),
      ),
      fenix: true,
    );

    Get.lazyPut<FavoritesRepository>(
      () => FavoritesRepositoryImpl(
        FavoritesRemoteDataSource(Get.find<ApiClient>().dio),
      ),
      fenix: true,
    );

    Get.lazyPut<CategoryRepository>(
      () => CategoryRepositoryImpl(
        CategoryRemoteDataSource(Get.find<ApiClient>().dio),
      ),
      fenix: true,
    );

    Get.lazyPut<OrderRepository>(
      () => OrderRepositoryImpl(
        OrderRemoteDataSource(Get.find<ApiClient>().dio),
      ),
      fenix: true,
    );

    Get.lazyPut<AddressRepository>(
      () => AddressRepositoryImpl(
        AddressRemoteDataSource(Get.find<ApiClient>().dio),
      ),
      fenix: true,
    );

    Get.lazyPut<DeliveryRepository>(
      () => DeliveryRepositoryImpl(
        DeliveryRemoteDataSource(Get.find<ApiClient>().dio),
      ),
      fenix: true,
    );

    Get.lazyPut<CouponRepository>(
      () => CouponRepositoryImpl(
        CouponRemoteDataSource(Get.find<ApiClient>().dio),
      ),
      fenix: true,
    );

    Get.lazyPut<InfoRepository>(
      () => InfoRepositoryImpl(
        InfoRemoteDataSource(Get.find<ApiClient>().dio),
      ),
      fenix: true,
    );

    Get.lazyPut<AdminReportsRepository>(
      () => AdminReportsRepositoryImpl(
        AdminReportsRemoteDataSource(Get.find<ApiClient>().dio),
      ),
      fenix: true,
    );
  }
}
