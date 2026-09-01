import '../../../../app/localization/lang.dart';
// import 'package:flutter/foundation.dart';
// import 'package:bhm_supermarket/core/network/dio_exception_mapper.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';

// import '../../../../core/api/api_endpoints.dart';
// import '../../../../core/datasource/base_remote_datasource.dart';
// import '../../../../core/network/api_response.dart';
// import '../../../../core/utils/json_parser.dart';
// import '../../models/delivery_order_model.dart';

// /// Remote data source for the delivery-driver APIs.
// ///
// /// Supported backend flow:
// /// 1. GET  /delivery/available-orders
// /// 2. PATCH /delivery/orders/{id}/claim
// /// 3. GET  /delivery/orders
// /// 4. GET  /delivery/orders/{id}
// ///
// /// Status mutation is intentionally not exposed here. The delivery feature
// /// must only use operations that are currently part of the supported driver
// /// workflow.
// class DeliveryRemoteDataSource extends BaseRemoteDataSource {
//   DeliveryRemoteDataSource(super.dio);

//   // ===========================================================================
//   // GET /api/delivery/orders
//   // ===========================================================================

//   Future<ApiResponse<List<DeliveryOrderModel>>> fetchOrders() {
//     return getPaginated<List<DeliveryOrderModel>>(
//       ApiEndpoints.deliveryOrders,
//       parser: (json) => JsonParser.list(
//         json,
//         DeliveryOrderModel.fromJson,
//       ),
//     );
//   }

//   // ===========================================================================
//   // GET /api/delivery/orders/{id}
//   // ===========================================================================

//   Future<ApiResponse<DeliveryOrderModel>> fetchOrderById(
//     String id,
//   ) {
//     return getEnvelope<DeliveryOrderModel>(
//       ApiEndpoints.deliveryOrder(id),
//       parser: (json) => DeliveryOrderModel.fromJson(
//         json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
//       ),
//     );
//   }

//   // ===========================================================================
//   // GET /api/delivery/available-orders
//   // ===========================================================================

//   Future<ApiResponse<List<DeliveryOrderModel>>> fetchAvailableOrders() {
//     return getPaginated<List<DeliveryOrderModel>>(
//       ApiEndpoints.deliveryAvailableOrders,
//       parser: (json) => JsonParser.list(
//         json,
//         DeliveryOrderModel.fromJson,
//       ),
//     );
//   }

//   // ===========================================================================
//   // PATCH /api/delivery/orders/{id}/claim
//   // ===========================================================================

//   Future<ApiResponse<DeliveryOrderModel>> claimOrder(
//     String id,
//   ) {
//     return _patchOrder(
//       ApiEndpoints.deliveryOrderClaim(id),
//       errorMessage: lang.t('claim_order_error'),
//     );
//   }

//   // ===========================================================================
//   // Internal
//   // ===========================================================================

//   Future<ApiResponse<DeliveryOrderModel>> _patchOrder(
//     String path, {
//     required String errorMessage,
//   }) async {
//     try {
//       final response = await dio.patch(path);
//       final map = JsonParser.map(response.data);

//       final success = JsonParser.boolValue(
//         map['success'],
//         fallback: true,
//       );

//       final message = JsonParser.string(map['message']);

//       if (!success) {
//         return ApiResponse<DeliveryOrderModel>.failure(
//           message.isNotEmpty ? message : errorMessage,
//           statusCode: response.statusCode,
//         );
//       }

//       final rawData = map['data'];

//       if (rawData is! Map) {
//         return ApiResponse<DeliveryOrderModel>.failure(
//           lang.t('invalid_order_data'),
//           statusCode: response.statusCode,
//         );
//       }

//       return ApiResponse<DeliveryOrderModel>.success(
//         DeliveryOrderModel.fromJson(
//           Map<String, dynamic>.from(rawData),
//         ),
//         message: message,
//         statusCode: response.statusCode,
//       );
//     } on DioException catch (error) {
//       return apiResponseFromDioError<DeliveryOrderModel>(error);
//     } catch (error, stackTrace) {
//       debugPrint('Delivery claim error: $error');
//       debugPrintStack(stackTrace: stackTrace);

//       return ApiResponse<DeliveryOrderModel>.failure(
//         errorMessage,
//       );
//     }
//   }
// }

import 'package:bhm_supermarket/core/network/dio_exception_mapper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/api/api_endpoints.dart';
import '../../../../core/datasource/base_remote_datasource.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/json_parser.dart';
import '../../models/delivery_order_model.dart';

/// Remote data source for the delivery-driver APIs.
///
/// Supported backend flow:
/// 1. GET   /delivery/available-orders
/// 2. PATCH /delivery/orders/{id}/claim
/// 3. GET   /delivery/orders
/// 4. GET   /delivery/orders/{id}
/// 5. PATCH /delivery/orders/{id}/status
class DeliveryRemoteDataSource extends BaseRemoteDataSource {
  DeliveryRemoteDataSource(super.dio);

  // ===========================================================================
  // GET /api/delivery/orders
  // ===========================================================================

  Future<ApiResponse<List<DeliveryOrderModel>>> fetchOrders() {
    return getPaginated<List<DeliveryOrderModel>>(
      ApiEndpoints.deliveryOrders,
      parser: (json) => JsonParser.list(
        json,
        DeliveryOrderModel.fromJson,
      ),
    );
  }

  // ===========================================================================
  // GET /api/delivery/orders/{id}
  // ===========================================================================

  Future<ApiResponse<DeliveryOrderModel>> fetchOrderById(
    String id,
  ) {
    return getEnvelope<DeliveryOrderModel>(
      ApiEndpoints.deliveryOrder(id),
      parser: (json) => DeliveryOrderModel.fromJson(
        json is Map ? Map<String, dynamic>.from(json) : <String, dynamic>{},
      ),
    );
  }

  // ===========================================================================
  // GET /api/delivery/available-orders
  // ===========================================================================

  Future<ApiResponse<List<DeliveryOrderModel>>> fetchAvailableOrders() {
    return getPaginated<List<DeliveryOrderModel>>(
      ApiEndpoints.deliveryAvailableOrders,
      parser: (json) => JsonParser.list(
        json,
        DeliveryOrderModel.fromJson,
      ),
    );
  }

  // ===========================================================================
  // PATCH /api/delivery/orders/{id}/claim
  // ===========================================================================

  Future<ApiResponse<DeliveryOrderModel>> claimOrder(
    String id,
  ) {
    return _patchOrder(
      ApiEndpoints.deliveryOrderClaim(id),
      errorMessage: lang.t('claim_order_error'),
    );
  }

  // ===========================================================================
  // PATCH /api/delivery/orders/{id}/status
  //
  // Backend expects:
  //
  // {
  //   "status": "delivered",
  //   "payment_status": "paid"
  // }
  // ===========================================================================

  Future<ApiResponse<DeliveryOrderModel>> updateOrderStatus(
    String id, {
    required String status,
    required String paymentStatus,
  }) async {
    try {
      final response = await dio.patch(
        ApiEndpoints.deliveryOrderStatus(id),
        data: {
          'status': status,
          'payment_status': paymentStatus,
        },
      );

      final map = JsonParser.map(response.data);

      final success = JsonParser.boolValue(
        map['success'],
        fallback: true,
      );

      final message = JsonParser.string(
        map['message'],
      );

      if (!success) {
        return ApiResponse<DeliveryOrderModel>.failure(
          message.isNotEmpty ? message : lang.t('order_status_update_error'),
          statusCode: response.statusCode,
        );
      }

      final rawData = map['data'];

      if (rawData is! Map) {
        return ApiResponse<DeliveryOrderModel>.failure(
          lang.t('invalid_updated_order_data'),
          statusCode: response.statusCode,
        );
      }

      return ApiResponse<DeliveryOrderModel>.success(
        DeliveryOrderModel.fromJson(
          Map<String, dynamic>.from(rawData),
        ),
        message: message,
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return apiResponseFromDioError<DeliveryOrderModel>(
        error,
      );
    } catch (error, stackTrace) {
      debugPrint(
        '[DeliveryRemoteDataSource] updateOrderStatus: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return ApiResponse<DeliveryOrderModel>.failure(
        lang.t('order_status_update_error'),
      );
    }
  }

  // ===========================================================================
  // Internal PATCH helper
  // ===========================================================================

  Future<ApiResponse<DeliveryOrderModel>> _patchOrder(
    String path, {
    required String errorMessage,
  }) async {
    try {
      final response = await dio.patch(path);

      final map = JsonParser.map(
        response.data,
      );

      final success = JsonParser.boolValue(
        map['success'],
        fallback: true,
      );

      final message = JsonParser.string(
        map['message'],
      );

      if (!success) {
        return ApiResponse<DeliveryOrderModel>.failure(
          message.isNotEmpty ? message : errorMessage,
          statusCode: response.statusCode,
        );
      }

      final rawData = map['data'];

      if (rawData is! Map) {
        return ApiResponse<DeliveryOrderModel>.failure(
          lang.t('invalid_order_data'),
          statusCode: response.statusCode,
        );
      }

      return ApiResponse<DeliveryOrderModel>.success(
        DeliveryOrderModel.fromJson(
          Map<String, dynamic>.from(rawData),
        ),
        message: message,
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return apiResponseFromDioError<DeliveryOrderModel>(
        error,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Delivery claim error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      return ApiResponse<DeliveryOrderModel>.failure(
        errorMessage,
      );
    }
  }
}
