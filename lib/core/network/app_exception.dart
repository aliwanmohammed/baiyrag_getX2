import 'package:flutter/foundation.dart';

/// هرمية الاستثناءات - لا نُظهر Stack Trace للمستخدم النهائي أبداً.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException() : super('لا يوجد اتصال بالإنترنت');
}

class TimeoutException extends AppException {
  const TimeoutException() : super('انتهت مهلة الاتصال، حاول مجدداً');
}

class ServerException extends AppException {
  const ServerException([super.msg = 'خطأ في الخادم، حاول لاحقاً']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('انتهت جلستك، سجّل الدخول مجدداً');
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException() : super('العنصر غير موجود');
}

/// تحويل أي استثناء لـ AppException آمن (لا نكشف تفاصيل للمستخدم)
AppException mapException(Object e) {
  if (e is AppException) return e;
  debugPrint('[AppException] $e');
  return const ServerException();
}
