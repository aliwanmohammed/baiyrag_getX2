/// Laravel REST endpoints (relative to [ApiConfig.baseUrl]).
class ApiEndpoints {
  ApiEndpoints._();

  static const authRegister = '/register';
  static const authLogin = '/login';
  static const authLogout = '/logout';
  static const me = '/me';
  static const refresh = '/refresh';

  // Ads
  static const ads = '/ads';

  static String ad(String id) => '/ads/$id';

  // Catalog
  // categories
  static const categories = '/categories';
  // products
  static const products = '/products';
  static String product(String id) => '/products/$id';

  // Orders
  static const orders = '/orders';
  static String order(String id) => '/orders/$id';
  static String orderTrack(String orderNumber) => '/orders/$orderNumber/track';

  // Users
  static const users = '/users';
  // Locations
  static const locations = '/locations';

  // Addresses
  static const addresses = '/addresses';
  static String address(String id) => '/addresses/$id';

  // Favorites
  static const favorites = '/favorites';
  static String favoriteToggle(String productId) =>
      '/favorites/$productId/toggle';

  static const myOrders = "/my-orders";

  // Profile
  // static const profile = '/profile';

  // Notifications
  static const notifications = '/notifications';

  // Admin
  static const adminReports = '/admin/reports';
  // Reports

  static const reportsSales = '/reports/sales';
  static const reportsCustomers = '/reports/customers';
  static const reportsProducts = '/reports/products';
  static const reportsOrders = '/reports/orders';
  static const reportsDeliveryDrivers = '/reports/delivery-drivers';

  static String reportsDeliveryDriver(int id) =>
      '/reports/delivery-drivers/$id';

  static const reportsLocations = '/reports/locations';

// ── Delivery ─────────────────────────────────────────────────────────────

  static const deliveryAvailableOrders = '/delivery/available-orders';

  static const deliveryOrders = '/delivery/orders';

  static String deliveryOrder(String id) => '/delivery/orders/$id';

  static String deliveryOrderClaim(String id) => '/delivery/orders/$id/claim';

  static String deliveryOrderStatus(String id) => '/delivery/orders/$id/status';

  static String assignDeliveryDriver(String id) =>
      '/orders/$id/delivery-driver';

  static String orderStatus(String orderId) {
    return '/orders/$orderId/status';
  }

  // Offers
  static const offers = '/offers';

  static String offer(String id) => '/offers/$id';

  // Upload
  static const upload = '/upload';

  // Coupons
  static const coupons = '/coupons';
  static String coupon(String id) => '/coupons/$id';
  static const checkCoupon = '/coupons/check';
}
