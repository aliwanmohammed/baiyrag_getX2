import '../../features/auth/controllers/auth_controller.dart';
import 'app_routes.dart';

class AppRedirects {
  AppRedirects._();

  static String afterLogin(AuthController auth) {
    // إذا كان المستخدم حاول فتح صفحة محمية
    final pending = auth.consumePendingRedirect();

    if (pending != AppRoutes.home) {
      return pending;
    }

    // Admin
    if (auth.isAdmin) {
      return AppRoutes.adminReports;
    }

    // Delivery
    if (auth.isDelivery) {
      return AppRoutes.deliveryHome;
    }

    // Customer
    return AppRoutes.home;
  }
}
