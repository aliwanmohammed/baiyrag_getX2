import 'package:bhm_supermarket/app/localization/lang.dart';

enum PaymentMethod { cash, card, unknown }

extension PaymentMethodExt on PaymentMethod {
  static PaymentMethod fromString(String value) {
    switch (value.toLowerCase()) {
      case 'cash':
        return PaymentMethod.cash;
      case 'card':
        return PaymentMethod.card;
      default:
        return PaymentMethod.unknown;
    }
  }

  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'نقدًا';
      case PaymentMethod.card:
        return 'بطاقة بنكية';
      case PaymentMethod.unknown:
        return lang.t('unknown');
    }
  }

  String get apiValue {
    switch (this) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.card:
        return 'card';
      case PaymentMethod.unknown:
        return 'unknown';
    }
  }
}
