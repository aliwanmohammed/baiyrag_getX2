/// Validators مركزية - تُستخدم في Flutter والتحقق من المدخلات.
/// الـ Backend (Laravel) يتحقق مستقلاً بنفس القواعد (Defense in Depth).
class Validators {
  Validators._();

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'رقم الهاتف مطلوب';
    final cleaned = v.trim().replaceAll(RegExp(r'[\s\-+]'), '');
    if (!RegExp(r'^7[0-9]{8}$').hasMatch(cleaned)) return 'رقم الهاتف غير صحيح';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'البريد الإلكتروني مطلوب';
    if (!RegExp(r'^[\w.%+-]+@[\w.-]+\.[a-zA-Z]{2,}$').hasMatch(v.trim())) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  static String? required(String? v, [String field = 'هذا الحقل']) {
    if (v == null || v.trim().isEmpty) return '$field مطلوب';
    return null;
  }

  static String? minLength(String? v, int min, [String field = 'الحقل']) {
    if (v == null || v.trim().length < min) {
      return '$field يجب أن يكون $min أحرف على الأقل';
    }
    return null;
  }

  static String? price(String? v) {
    if (v == null || v.trim().isEmpty) return 'السعر مطلوب';
    if (double.tryParse(v.trim()) == null) return 'سعر غير صحيح';
    if (double.parse(v.trim()) <= 0) return 'السعر يجب أن يكون أكبر من صفر';
    return null;
  }

  static String? otp(String? v) {
    if (v == null || v.trim().isEmpty) return 'رمز التحقق مطلوب';
    if (!RegExp(r'^[0-9]{4}$').hasMatch(v.trim())) {
      return 'رمز التحقق يجب أن يكون 4 أرقام';
    }
    return null;
  }
}
