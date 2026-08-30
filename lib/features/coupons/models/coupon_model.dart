class CouponModel {
  final String id;
  final String code;
  final String type;
  final double value;
  final double minimumOrderAmount;
  final int usageLimit;
  final int usedCount;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  const CouponModel({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.minimumOrderAmount,
    required this.usageLimit,
    required this.usedCount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  bool get isPercentage => type == 'percentage';

  bool get isFixed => type == 'fixed';

  double calculateDiscount(double subtotal) {
    if (subtotal < minimumOrderAmount) {
      return 0;
    }

    if (isPercentage) {
      return subtotal * (value / 100);
    }

    return value > subtotal ? subtotal : value;
  }

  CouponModel copyWith({
    String? id,
    String? code,
    String? type,
    double? value,
    double? minimumOrderAmount,
    int? usageLimit,
    int? usedCount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return CouponModel(
      id: id ?? this.id,
      code: code ?? this.code,
      type: type ?? this.type,
      value: value ?? this.value,
      minimumOrderAmount: minimumOrderAmount ?? this.minimumOrderAmount,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      type: json['type']?.toString() ?? 'percentage',
      value: _toDouble(json['value']),
      minimumOrderAmount: _toDouble(json['minimum_order_amount']),
      usageLimit: _toInt(json['usage_limit']),
      usedCount: _toInt(json['used_count']),
      startDate: _parseDate(json['start_date']),
      endDate: _parseDate(json['end_date']),
      isActive: _toBool(json['is_active']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'type': type,
      'value': value,
      'minimum_order_amount': minimumOrderAmount,
      'usage_limit': usageLimit,
      'used_count': usedCount,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
    };
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;

    if (value is num) {
      return value != 0;
    }

    final text = value?.toString().toLowerCase();

    return text == 'true' || text == '1';
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}
