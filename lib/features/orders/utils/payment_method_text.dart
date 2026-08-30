String paymentMethodText(String value) {
  switch (value) {
    case "cash":
      return "الدفع نقداً";

    case "card":
      return "بطاقة بنكية";

    default:
      return value;
  }
}
