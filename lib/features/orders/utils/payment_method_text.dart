import '../../../app/localization/lang.dart';
String paymentMethodText(String value) {
  switch (value) {
    case "cash":
      return lang.t('cash_payment');

    case "card":
      return lang.t('bank_card_payment');

    default:
      return value;
  }
}
