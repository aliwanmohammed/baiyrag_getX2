import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/utils/json_parser.dart';

class LanguageController extends GetxController {
  Locale _locale = const Locale('ar');

  LanguageController();

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }
  Future<void> _loadLanguage() async {
    final lang = await SecureStorageService.instance.readLanguage();

    JsonParser.currentLanguage = lang;

    _locale = Locale(lang);

    update();
  }

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';

  Future<void> setArabic() async {
    JsonParser.currentLanguage = 'ar';

    _locale = const Locale('ar');

    await SecureStorageService.instance.saveLanguage('ar');

    update();
  }

  Future<void> setEnglish() async {
    JsonParser.currentLanguage = 'en';

    _locale = const Locale('en');

    await SecureStorageService.instance.saveLanguage('en');

    update();
  }

  Future<void> toggle() async {
    if (isArabic) {
      await setEnglish();
    } else {
      await setArabic();
    }
  }

  String t(String key) => AppStrings.of(_locale.languageCode)[key] ?? key;
}

class AppStrings {
  static Map<String, String> of(String lang) => lang == 'en' ? _en : _ar;

  static const _ar = {
    // General
    'app_name': 'البيرق هايبر ماركت',
    'save': 'حفظ',
    'cancel': 'إلغاء',
    'delete': 'حذف',
    'edit': 'تعديل',
    'close': 'إغلاق',
    'confirm': 'تأكيد',
    'search': 'بحث',
    'loading': 'جاري التحميل...',
    'error': 'خطأ',
    'success': 'تم بنجاح',
    'no_data': 'لا توجد بيانات',
    'retry': 'إعادة المحاولة',
    // Auth
    'login': 'تسجيل الدخول',
    'logout': 'تسجيل الخروج',
    'register': 'إنشاء حساب',
    'phone': 'رقم الهاتف',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'login_with_phone': 'الدخول برقم الهاتف',
    'login_with_email': 'الدخول بالبريد الإلكتروني',
    'otp_title': 'رمز التحقق',
    'otp_sent_phone': 'تم إرسال رمز التحقق إلى',
    'otp_sent_email': 'تم إرسال رمز التحقق إلى بريدك',
    'resend': 'إعادة الإرسال',
    'no_account': 'ليس لديك حساب؟',
    // Home
    'home': 'الرئيسية',
    'categories': 'الأقسام',
    'cart': 'السلة',
    'profile': 'حسابي',
    'favorites': 'المفضلة',
    'orders': 'طلباتي',
    'notifications': 'الإشعارات',
    // Product
    'add_to_cart': 'إضافة للسلة',
    'add_to_favorites': 'إضافة للمفضلة',
    'remove_from_favorites': 'إزالة من المفضلة',
    'unit': 'الوحدة',
    'price': 'السعر',
    'quantity': 'الكمية',
    'in_stock': 'متوفر',
    'out_of_stock': 'غير متوفر',
    'select_unit': 'اختر الوحدة',
    // Cart
    'cart_empty': 'السلة فارغة',
    'subtotal': 'المجموع الجزئي',
    'delivery_fee': 'رسوم التوصيل',
    'total': 'الإجمالي',
    'checkout': 'إتمام الطلب',
    'clear_cart': 'تفريغ السلة',
    // Checkout
    'delivery_address': 'عنوان التوصيل',
    'payment_method': 'طريقة الدفع',
    'coupon': 'كوبون الخصم',
    'place_order': 'تأكيد الطلب',
    'order_summary': 'ملخص الطلب',
    // Orders
    'order_number': 'رقم الطلب',
    'order_status': 'حالة الطلب',
    'track_order': 'تتبع الطلب',
    // Address
    'add_address': 'إضافة عنوان',
    'delivery_addresses': 'عناوين التوصيل',
    'default_address': 'افتراضي',
    // Admin
    'manage_products': 'إدارة المنتجات',
    'manage_orders': 'إدارة الطلبات',
    'manage_users': 'إدارة المستخدمين',
    'manage_delivery': 'إدارة التوصيل',
    'reports': 'التقارير',
    'total_sales': 'إجمالي المبيعات',
    'total_orders': 'إجمالي الطلبات',
    'active_users': 'المستخدمون النشطون',
    'pending_orders': 'الطلبات المعلقة',
    // Delivery
    'my_deliveries': 'توصيلاتي',
    'current_order': 'الطلب الحالي',
    'delivery_history': 'سجل التوصيل',
    'start_delivery': 'بدء التوصيل',
    'complete_delivery': 'إتمام التوصيل',
    // Settings
    'settings': 'الإعدادات',
    'dark_mode': 'الوضع الليلي',
    'language': 'اللغة',
    'arabic': 'العربية',
    'english': 'الإنجليزية',
    // Info
    'about_us': 'من نحن',
    'contact_us': 'اتصل بنا',
    'faq': 'الأسئلة الشائعة',
    'privacy_policy': 'سياسة الخصوصية',
    'terms': 'شروط الاستخدام',
  };

  static const _en = {
    // General
    'app_name': 'BHM Supermarket',
    'save': 'Save',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'edit': 'Edit',
    'close': 'Close',
    'confirm': 'Confirm',
    'search': 'Search',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'no_data': 'No data',
    'retry': 'Retry',
    // Auth
    'login': 'Login',
    'logout': 'Logout',
    'register': 'Register',
    'phone': 'Phone Number',
    'email': 'Email',
    'password': 'Password',
    'login_with_phone': 'Login with Phone',
    'login_with_email': 'Login with Email',
    'otp_title': 'Verification Code',
    'otp_sent_phone': 'Code sent to',
    'otp_sent_email': 'Code sent to your email',
    'resend': 'Resend',
    'no_account': 'No account?',
    // Home
    'home': 'Home',
    'categories': 'Categories',
    'cart': 'Cart',
    'profile': 'Profile',
    'favorites': 'Favorites',
    'orders': 'Orders',
    'notifications': 'Notifications',
    // Product
    'add_to_cart': 'Add to Cart',
    'add_to_favorites': 'Add to Favorites',
    'remove_from_favorites': 'Remove from Favorites',
    'unit': 'Unit',
    'price': 'Price',
    'quantity': 'Quantity',
    'in_stock': 'In Stock',
    'out_of_stock': 'Out of Stock',
    'select_unit': 'Select Unit',
    // Cart
    'cart_empty': 'Cart is Empty',
    'subtotal': 'Subtotal',
    'delivery_fee': 'Delivery Fee',
    'total': 'Total',
    'checkout': 'Checkout',
    'clear_cart': 'Clear Cart',
    // Checkout
    'delivery_address': 'Delivery Address',
    'payment_method': 'Payment Method',
    'coupon': 'Discount Coupon',
    'place_order': 'Place Order',
    'order_summary': 'Order Summary',
    // Orders
    'order_number': 'Order Number',
    'order_status': 'Status',
    'track_order': 'Track Order',
    // Address
    'add_address': 'Add Address',
    'delivery_addresses': 'Delivery Addresses',
    'default_address': 'Default',
    // Admin
    'manage_products': 'Manage Products',
    'manage_orders': 'Manage Orders',
    'manage_users': 'Manage Users',
    'manage_delivery': 'Manage Delivery',
    'reports': 'Reports',
    'total_sales': 'Total Sales',
    'total_orders': 'Total Orders',
    'active_users': 'Active Users',
    'pending_orders': 'Pending Orders',
    // Delivery
    'my_deliveries': 'My Deliveries',
    'current_order': 'Current Order',
    'delivery_history': 'Delivery History',
    'start_delivery': 'Start Delivery',
    'complete_delivery': 'Complete Delivery',
    // Settings
    'settings': 'Settings',
    'dark_mode': 'Dark Mode',
    'language': 'Language',
    'arabic': 'Arabic',
    'english': 'English',
    // Info
    'about_us': 'About Us',
    'contact_us': 'Contact Us',
    'faq': 'FAQ',
    'privacy_policy': 'Privacy Policy',
    'terms': 'Terms of Use',
  };
}
