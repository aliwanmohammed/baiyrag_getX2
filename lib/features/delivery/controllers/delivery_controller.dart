import 'package:get/get.dart';
// import 'package:flutter/foundation.dart';

// import '../domain/repositories/delivery_repository.dart';
// import '../models/delivery_order_model.dart';

// class DeliveryController extends GetxController {
//   DeliveryController(this._repository);

//   final DeliveryRepository _repository;

//   List<DeliveryOrderModel> _availableOrders = [];
//   List<DeliveryOrderModel> _orders = [];

//   DeliveryOrderModel? _selectedOrder;

//   bool _isLoading = false;
//   bool _isClaiming = false;

//   String? _error;

//   // ===========================================================================
//   // Getters
//   // ===========================================================================

//   List<DeliveryOrderModel> get availableOrders =>
//       List.unmodifiable(_availableOrders);

//   List<DeliveryOrderModel> get orders => List.unmodifiable(_orders);

//   DeliveryOrderModel? get selectedOrder => _selectedOrder;

//   bool get isLoading => _isLoading;

//   bool get isClaiming => _isClaiming;

//   String? get error => _error;

//   bool get isEmpty =>
//       !_isLoading &&
//       _availableOrders.isEmpty &&
//       _orders.isEmpty &&
//       _error == null;

//   /// Orders currently assigned to this delivery driver and not finished.
//   List<DeliveryOrderModel> get activeOrders {
//     return _orders
//         .where(
//           (order) => order.status != 'delivered' && order.status != 'cancelled',
//         )
//         .toList();
//   }

//   /// Finished orders returned by the delivery endpoint.
//   List<DeliveryOrderModel> get historyOrders {
//     return _orders
//         .where(
//           (order) => order.status == 'delivered' || order.status == 'cancelled',
//         )
//         .toList();
//   }

//   // ===========================================================================
//   // Load available orders
//   // ===========================================================================

//   Future<void> loadAvailableOrders() async {
//     _isLoading = true;
//     _error = null;
//     update();

//     try {
//       final response = await _repository.getAvailableOrders();

//       if (response.isSuccess) {
//         _availableOrders = response.data ?? [];
//       } else {
//         _error = response.message.isNotEmpty
//             ? response.message
//             : 'تعذر تحميل الطلبات المتاحة';
//       }
//     } catch (error, stackTrace) {
//       debugPrint('[DeliveryController] loadAvailableOrders: $error');
//       debugPrintStack(stackTrace: stackTrace);
//       _error = 'تعذر تحميل الطلبات المتاحة';
//     } finally {
//       _isLoading = false;
//       update();
//     }
//   }

//   // ===========================================================================
//   // Load my assigned orders
//   // ===========================================================================

//   Future<void> loadOrders() async {
//     _isLoading = true;
//     _error = null;
//     update();

//     try {
//       final response = await _repository.getOrders();

//       if (response.isSuccess) {
//         _orders = response.data ?? [];
//       } else {
//         _error = response.message.isNotEmpty
//             ? response.message
//             : 'تعذر تحميل طلباتك';
//       }
//     } catch (error, stackTrace) {
//       debugPrint('[DeliveryController] loadOrders: $error');
//       debugPrintStack(stackTrace: stackTrace);
//       _error = 'تعذر تحميل طلباتك';
//     } finally {
//       _isLoading = false;
//       update();
//     }
//   }

//   // ===========================================================================
//   // Refresh
//   // ===========================================================================

//   Future<void> reload() async {
//     _error = null;
//     _isLoading = true;
//     update();

//     try {
//       final results = await Future.wait([
//         _repository.getAvailableOrders(),
//         _repository.getOrders(),
//       ]);

//       final availableResponse = results[0];
//       final ordersResponse = results[1];

//       var hasError = false;

//       if (availableResponse.isSuccess) {
//         _availableOrders = availableResponse.data ?? [];
//       } else {
//         hasError = true;
//         _error = availableResponse.message.isNotEmpty
//             ? availableResponse.message
//             : 'تعذر تحميل الطلبات المتاحة';
//       }

//       if (ordersResponse.isSuccess) {
//         _orders = ordersResponse.data ?? [];
//       } else {
//         hasError = true;
//         _error = ordersResponse.message.isNotEmpty
//             ? ordersResponse.message
//             : 'تعذر تحميل طلباتك';
//       }

//       if (!hasError) {
//         _error = null;
//       }
//     } catch (error, stackTrace) {
//       debugPrint('[DeliveryController] refresh: $error');
//       debugPrintStack(stackTrace: stackTrace);
//       _error = 'تعذر تحديث الطلبات';
//     } finally {
//       _isLoading = false;
//       update();
//     }
//   }

//   // ===========================================================================
//   // Claim order
//   // ===========================================================================

//   Future<String?> claimOrder(String orderId) async {
//     if (_isClaiming) {
//       return 'يوجد إجراء قيد التنفيذ';
//     }

//     _isClaiming = true;
//     _error = null;
//     update();

//     try {
//       final response = await _repository.claimOrder(orderId);

//       if (!response.isSuccess || response.data == null) {
//         return response.message.isNotEmpty
//             ? response.message
//             : 'تعذر استلام الطلب';
//       }

//       final claimedOrder = response.data!;

//       _availableOrders.removeWhere(
//         (order) => order.id == orderId,
//       );

//       _upsertOrder(claimedOrder);
//       _selectedOrder = claimedOrder;

//       return null;
//     } catch (error, stackTrace) {
//       debugPrint('[DeliveryController] claimOrder: $error');
//       debugPrintStack(stackTrace: stackTrace);
//       return 'تعذر استلام الطلب';
//     } finally {
//       _isClaiming = false;
//       update();
//     }
//   }

//   // ===========================================================================
//   // Order details
//   // ===========================================================================

//   Future<void> loadOrder(String id) async {
//     _selectedOrder = null;
//     _isLoading = true;
//     _error = null;
//     update();

//     try {
//       final response = await _repository.getOrderById(id);

//       if (response.isSuccess && response.data != null) {
//         final order = response.data!;

//         _selectedOrder = order;
//         _upsertOrder(order);
//         _replaceAvailableOrder(order);
//       } else {
//         _error = response.message.isNotEmpty
//             ? response.message
//             : 'تعذر تحميل تفاصيل الطلب';
//       }
//     } catch (error, stackTrace) {
//       debugPrint('[DeliveryController] loadOrder: $error');
//       debugPrintStack(stackTrace: stackTrace);
//       _error = 'تعذر تحميل تفاصيل الطلب';
//     } finally {
//       _isLoading = false;
//       update();
//     }
//   }

//   // ===========================================================================
//   // Local state helpers
//   // ===========================================================================

//   void _upsertOrder(DeliveryOrderModel order) {
//     final index = _orders.indexWhere(
//       (item) => item.id == order.id,
//     );

//     if (index == -1) {
//       _orders.insert(0, order);
//     } else {
//       _orders[index] = order;
//     }
//   }

//   void _replaceAvailableOrder(DeliveryOrderModel order) {
//     final index = _availableOrders.indexWhere(
//       (item) => item.id == order.id,
//     );

//     if (index != -1) {
//       _availableOrders[index] = order;
//     }
//   }

//   // ===========================================================================
//   // Clear error
//   // ===========================================================================

//   void clearError() {
//     if (_error == null) {
//       return;
//     }

//     _error = null;
//     update();
//   }
// }

import 'package:flutter/foundation.dart';

import '../domain/repositories/delivery_repository.dart';
import '../models/delivery_order_model.dart';

class DeliveryController extends GetxController {
  DeliveryController(this._repository);

  final DeliveryRepository _repository;

  List<DeliveryOrderModel> _availableOrders = [];
  List<DeliveryOrderModel> _orders = [];

  DeliveryOrderModel? _selectedOrder;

  bool _isLoading = false;
  bool _isClaiming = false;
  bool _isUpdatingStatus = false;

  String? _error;

  // ===========================================================================
  // Getters
  // ===========================================================================

  List<DeliveryOrderModel> get availableOrders =>
      List.unmodifiable(_availableOrders);

  List<DeliveryOrderModel> get orders => List.unmodifiable(_orders);

  DeliveryOrderModel? get selectedOrder => _selectedOrder;

  bool get isLoading => _isLoading;

  bool get isClaiming => _isClaiming;

  bool get isUpdatingStatus => _isUpdatingStatus;

  String? get error => _error;

  bool get isEmpty =>
      !_isLoading &&
      _availableOrders.isEmpty &&
      _orders.isEmpty &&
      _error == null;

  // ===========================================================================
  // Active orders
  // ===========================================================================

  List<DeliveryOrderModel> get activeOrders {
    return _orders
        .where(
          (order) => order.status != 'delivered' && order.status != 'cancelled',
        )
        .toList();
  }

  // ===========================================================================
  // History
  // ===========================================================================

  List<DeliveryOrderModel> get historyOrders {
    return _orders
        .where(
          (order) => order.status == 'delivered' || order.status == 'cancelled',
        )
        .toList();
  }

  // ===========================================================================
  // Load available orders
  // ===========================================================================

  Future<void> loadAvailableOrders() async {
    _isLoading = true;
    _error = null;

    update();

    try {
      final response = await _repository.getAvailableOrders();

      if (response.isSuccess) {
        _availableOrders = response.data ?? [];
      } else {
        _error = response.message.isNotEmpty
            ? response.message
            : 'تعذر تحميل الطلبات المتاحة';
      }
    } catch (error, stackTrace) {
      debugPrint(
        '[DeliveryController] loadAvailableOrders: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _error = 'تعذر تحميل الطلبات المتاحة';
    } finally {
      _isLoading = false;
      update();
    }
  }

  // ===========================================================================
  // Load my orders
  // ===========================================================================

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;

    update();

    try {
      final response = await _repository.getOrders();

      if (response.isSuccess) {
        _orders = response.data ?? [];
      } else {
        _error = response.message.isNotEmpty
            ? response.message
            : 'تعذر تحميل طلباتك';
      }
    } catch (error, stackTrace) {
      debugPrint(
        '[DeliveryController] loadOrders: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _error = 'تعذر تحميل طلباتك';
    } finally {
      _isLoading = false;
      update();
    }
  }

  // ===========================================================================
  // Refresh
  // ===========================================================================

  Future<void> reload() async {
    _error = null;
    _isLoading = true;

    update();

    try {
      final results = await Future.wait([
        _repository.getAvailableOrders(),
        _repository.getOrders(),
      ]);

      final availableResponse = results[0];
      final ordersResponse = results[1];

      var hasError = false;

      if (availableResponse.isSuccess) {
        _availableOrders = availableResponse.data ?? [];
      } else {
        hasError = true;

        _error = availableResponse.message.isNotEmpty
            ? availableResponse.message
            : 'تعذر تحميل الطلبات المتاحة';
      }

      if (ordersResponse.isSuccess) {
        _orders = ordersResponse.data ?? [];
      } else {
        hasError = true;

        _error = ordersResponse.message.isNotEmpty
            ? ordersResponse.message
            : 'تعذر تحميل طلباتك';
      }

      if (!hasError) {
        _error = null;
      }
    } catch (error, stackTrace) {
      debugPrint(
        '[DeliveryController] refresh: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _error = 'تعذر تحديث الطلبات';
    } finally {
      _isLoading = false;

      update();
    }
  }

  // ===========================================================================
  // Claim order
  // ===========================================================================

  Future<String?> claimOrder(
    String orderId,
  ) async {
    if (_isClaiming) {
      return 'يوجد إجراء قيد التنفيذ';
    }

    _isClaiming = true;
    _error = null;

    update();

    try {
      final response = await _repository.claimOrder(orderId);

      if (!response.isSuccess || response.data == null) {
        return response.message.isNotEmpty
            ? response.message
            : 'تعذر استلام الطلب';
      }

      final claimedOrder = response.data!;

      _availableOrders.removeWhere(
        (order) => order.id == orderId,
      );

      _upsertOrder(
        claimedOrder,
      );

      _selectedOrder = claimedOrder;

      return null;
    } catch (error, stackTrace) {
      debugPrint(
        '[DeliveryController] claimOrder: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return 'تعذر استلام الطلب';
    } finally {
      _isClaiming = false;

      update();
    }
  }

  // ===========================================================================
  // Update order status
  // ===========================================================================

  Future<String?> updateOrderStatus(
    String orderId, {
    required String status,
    required String paymentStatus,
  }) async {
    if (_isUpdatingStatus) {
      return 'يوجد إجراء قيد التنفيذ';
    }

    _isUpdatingStatus = true;
    _error = null;

    update();

    try {
      final response = await _repository.updateOrderStatus(
        orderId,
        status: status,
        paymentStatus: paymentStatus,
      );

      if (!response.isSuccess || response.data == null) {
        final message = response.message.isNotEmpty
            ? response.message
            : 'تعذر تحديث حالة الطلب';

        _error = message;

        return message;
      }

      final updatedOrder = response.data!;

      // Update the main orders list.
      _upsertOrder(
        updatedOrder,
      );

      // Update selected order.
      _selectedOrder = updatedOrder;

      // A delivered/cancelled order should not remain
      // in available orders.
      if (updatedOrder.status == 'delivered' ||
          updatedOrder.status == 'cancelled') {
        _availableOrders.removeWhere(
          (order) => order.id == orderId,
        );
      } else {
        _replaceAvailableOrder(
          updatedOrder,
        );
      }

      _error = null;

      return null;
    } catch (error, stackTrace) {
      debugPrint(
        '[DeliveryController] updateOrderStatus: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      const message = 'تعذر تحديث حالة الطلب';

      _error = message;

      return message;
    } finally {
      _isUpdatingStatus = false;

      update();
    }
  }

  // ===========================================================================
  // Load order details
  // ===========================================================================

  Future<void> loadOrder(
    String id,
  ) async {
    _selectedOrder = null;
    _isLoading = true;
    _error = null;

    update();

    try {
      final response = await _repository.getOrderById(id);

      if (response.isSuccess && response.data != null) {
        final order = response.data!;

        _selectedOrder = order;

        _upsertOrder(
          order,
        );

        _replaceAvailableOrder(
          order,
        );
      } else {
        _error = response.message.isNotEmpty
            ? response.message
            : 'تعذر تحميل تفاصيل الطلب';
      }
    } catch (error, stackTrace) {
      debugPrint(
        '[DeliveryController] loadOrder: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      _error = 'تعذر تحميل تفاصيل الطلب';
    } finally {
      _isLoading = false;

      update();
    }
  }

  // ===========================================================================
  // Local helpers
  // ===========================================================================

  void _upsertOrder(
    DeliveryOrderModel order,
  ) {
    final index = _orders.indexWhere(
      (item) => item.id == order.id,
    );

    if (index == -1) {
      _orders.insert(
        0,
        order,
      );
    } else {
      _orders[index] = order;
    }
  }

  void _replaceAvailableOrder(
    DeliveryOrderModel order,
  ) {
    final index = _availableOrders.indexWhere(
      (item) => item.id == order.id,
    );

    if (index != -1) {
      _availableOrders[index] = order;
    }
  }

  // ===========================================================================
  // Clear error
  // ===========================================================================

  void clearError() {
    if (_error == null) {
      return;
    }

    _error = null;

    update();
  }
}
