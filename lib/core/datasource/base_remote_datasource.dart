import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../network/api_response.dart';
import '../network/dio_exception_mapper.dart';
import '../utils/json_parser.dart';
import '../pagination/pagination_meta.dart';

abstract class BaseRemoteDataSource {
  BaseRemoteDataSource(this.dio);

  final Dio dio;

  // ===========================================================================
  // GET + Pagination Meta
  // ===========================================================================

  Future<ApiResponse<PaginatedResult<T>>> getWithMeta<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: query,
      );

      final map = JsonParser.map(response.data);
      final metaMap = JsonParser.map(map['meta']);

      return ApiResponse<PaginatedResult<T>>.success(
        PaginatedResult<T>(
          items: parser(map['data']),
          meta: PaginationMeta.fromJson(metaMap),
        ),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return apiResponseFromDioError<PaginatedResult<T>>(error);
    } catch (error, stackTrace) {
      debugPrint('GET with meta error: $error');
      debugPrintStack(stackTrace: stackTrace);

      return ApiResponse<PaginatedResult<T>>.failure(
        'خطأ في جلب البيانات',
      );
    }
  }

  // ===========================================================================
  // GET Paginated
  // ===========================================================================

  Future<ApiResponse<T>> getPaginated<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: query,
      );

      return ApiResponse<T>.success(
        parser(response.data['data']),
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return apiResponseFromDioError<T>(error);
    } catch (error, stackTrace) {
      debugPrint('GET paginated error: $error');
      debugPrintStack(stackTrace: stackTrace);

      return ApiResponse<T>.failure(
        'حدث خطأ غير متوقع',
      );
    }
  }

  // ===========================================================================
  // GET Envelope
  // ===========================================================================

  Future<ApiResponse<T>> getEnvelope<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: query,
      );

      return ApiResponse<T>.fromEnvelope(
        response.data,
        parser: parser,
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return apiResponseFromDioError<T>(error);
    } catch (error, stackTrace) {
      debugPrint('GET envelope error: $error');
      debugPrintStack(stackTrace: stackTrace);

      return ApiResponse<T>.failure(
        'حدث خطأ غير متوقع',
      );
    }
  }

  // ===========================================================================
  // POST Envelope
  // ===========================================================================

  Future<ApiResponse<T>> postEnvelope<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
      );

      return ApiResponse<T>.fromEnvelope(
        response.data,
        parser: parser,
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return apiResponseFromDioError<T>(error);
    } catch (error, stackTrace) {
      debugPrint('POST envelope error: $error');
      debugPrintStack(stackTrace: stackTrace);

      return ApiResponse<T>.failure(
        'حدث خطأ غير متوقع',
      );
    }
  }

  // ===========================================================================
  // PUT Envelope
  // ===========================================================================

  Future<ApiResponse<T>> putEnvelope<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) parser,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
      );

      return ApiResponse<T>.fromEnvelope(
        response.data,
        parser: parser,
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return apiResponseFromDioError<T>(error);
    } catch (error, stackTrace) {
      debugPrint('PUT envelope error: $error');
      debugPrintStack(stackTrace: stackTrace);

      return ApiResponse<T>.failure(
        'حدث خطأ غير متوقع',
      );
    }
  }

  // ===========================================================================
  // DELETE Envelope
  // ===========================================================================

  Future<ApiResponse<void>> deleteEnvelope(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
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
        return ApiResponse<void>.failure(
          message,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse<void>.success(
        null,
        message: message,
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return apiResponseFromDioError<void>(error);
    } catch (error, stackTrace) {
      debugPrint('DELETE envelope error: $error');
      debugPrintStack(stackTrace: stackTrace);

      return ApiResponse<void>.failure(
        'حدث خطأ غير متوقع',
      );
    }
  }

  // ===========================================================================
  // PATCH Void
  // ===========================================================================

  Future<ApiResponse<void>> patchVoid(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await dio.patch(
        path,
        data: data,
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
        return ApiResponse<void>.failure(
          message,
          statusCode: response.statusCode,
        );
      }

      return ApiResponse<void>.success(
        null,
        message: message,
        statusCode: response.statusCode,
      );
    } on DioException catch (error) {
      return apiResponseFromDioError<void>(error);
    } catch (error, stackTrace) {
      debugPrint('PATCH void error: $error');
      debugPrintStack(stackTrace: stackTrace);

      return ApiResponse<void>.failure(
        'حدث خطأ غير متوقع',
      );
    }
  }
}
