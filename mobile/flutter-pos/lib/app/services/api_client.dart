import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../app/constants/app_constants.dart';
import '../../data/response/api_response.dart';
import 'storage_service.dart';

/// Centralized Dio API client. Wraps every request into the
/// `{success, message, data}` envelope used by the Laravel backend.
class ApiClient extends GetxService {
  static ApiClient get to => Get.find<ApiClient>();

  late final Dio dio;

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
      headers: {
        'Accept': 'application/json',
        'Host':
            'laravel-api.test', // <-- KUNCI SUKSES: Memaksa Herd mengenali project Anda
      },
    ));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = StorageService.to.token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<ApiResponse<T>> _send<T>(
    String method,
    String path, {
    dynamic body,
    Map<String, dynamic>? query,
    T Function(dynamic)? fromData,
  }) async {
    try {
      final response = await dio.request(
        path,
        data: body,
        queryParameters: query,
        options: Options(method: method),
      );
      return ApiResponse<T>.fromJson(response.data, fromData);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        return ApiResponse<T>(
          success: false,
          message: data['message'] as String? ?? 'Request failed',
          errors: data['errors'] as Map<String, dynamic>?,
        );
      }
      return ApiResponse<T>(
        success: false,
        message: e.message ?? 'Network error',
      );
    } catch (e) {
      return ApiResponse<T>(success: false, message: e.toString());
    }
  }

  Future<ApiResponse<T>> get<T>(String path,
          {Map<String, dynamic>? query, T Function(dynamic)? fromData}) =>
      _send('GET', path, query: query, fromData: fromData);

  Future<ApiResponse<T>> post<T>(String path,
          {dynamic body, T Function(dynamic)? fromData}) =>
      _send('POST', path, body: body, fromData: fromData);

  Future<ApiResponse<T>> put<T>(String path,
          {dynamic body, T Function(dynamic)? fromData}) =>
      _send('PUT', path, body: body, fromData: fromData);

  Future<ApiResponse<T>> delete<T>(String path,
          {T Function(dynamic)? fromData}) =>
      _send('DELETE', path, fromData: fromData);
}
