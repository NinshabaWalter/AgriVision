import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../app_config.dart';
import 'storage_service.dart';

class ApiService {
  static late Dio _dio;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_LoggingInterceptor());
    _dio.interceptors.add(_ErrorInterceptor());
    
    if (AppConfig.isDevelopment) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print(obj),
      ));
    }

    _isInitialized = true;
  }

  static Future<bool> isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Authentication endpoints
  static Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('ApiService: Attempting login for $email');
      print('ApiService: Base URL: ${_dio.options.baseUrl}');
      
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      
      print('ApiService: Login response status: ${response.statusCode}');
      print('ApiService: Login response data: ${response.data}');
      
      return ApiResponse.success(response.data);
    } catch (e) {
      print('ApiService: Login error: $e');
      if (e is DioException) {
        print('ApiService: DioException details: ${e.response?.data}');
        print('ApiService: DioException status: ${e.response?.statusCode}');
      }
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
      });
      
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> refreshToken() async {
    try {
      final response = await _dio.post('/auth/refresh');
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Disease detection endpoints
  static Future<ApiResponse<Map<String, dynamic>>> detectDisease({
    required File imageFile,
    int? cropId,
    double? locationLat,
    double? locationLng,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path),
        if (cropId != null) 'crop_id': cropId,
        if (locationLat != null) 'location_lat': locationLat,
        if (locationLng != null) 'location_lng': locationLng,
      });

      final response = await _dio.post('/disease-detection/detect', data: formData);
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getDiseaseDetections({
    int skip = 0,
    int limit = 20,
    int? cropId,
    String? statusFilter,
  }) async {
    try {
      final response = await _dio.get('/disease-detection/detections', queryParameters: {
        'skip': skip,
        'limit': limit,
        if (cropId != null) 'crop_id': cropId,
        if (statusFilter != null) 'status_filter': statusFilter,
      });
      
      return ApiResponse.success(List<Map<String, dynamic>>.from(response.data));
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Weather endpoints
  static Future<ApiResponse<Map<String, dynamic>>> getCurrentWeather({
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _dio.get('/weather/current', queryParameters: {
        'lat': lat,
        'lng': lng,
      });
      
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<List<Map<String, dynamic>>>> getWeatherForecast({
    required double lat,
    required double lng,
    int days = 7,
  }) async {
    try {
      final response = await _dio.get('/weather/forecast', queryParameters: {
        'lat': lat,
        'lng': lng,
        'days': days,
      });
      
      return ApiResponse.success(List<Map<String, dynamic>>.from(response.data));
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Market endpoints
  static Future<ApiResponse<List<Map<String, dynamic>>>> getMarketPrices({
    String? cropType,
    String? location,
    int days = 30,
  }) async {
    try {
      final response = await _dio.get('/market/prices', queryParameters: {
        if (cropType != null) 'crop_type': cropType,
        if (location != null) 'location': location,
        'days': days,
      });
      
      return ApiResponse.success(List<Map<String, dynamic>>.from(response.data));
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Farm endpoints
  static Future<ApiResponse<List<Map<String, dynamic>>>> getFarms() async {
    try {
      final response = await _dio.get('/farms');
      return ApiResponse.success(List<Map<String, dynamic>>.from(response.data));
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> createFarm({
    required String name,
    required double lat,
    required double lng,
    double? sizeHectares,
    String? description,
  }) async {
    try {
      final response = await _dio.post('/farms', data: {
        'name': name,
        'location_lat': lat,
        'location_lng': lng,
        if (sizeHectares != null) 'size_hectares': sizeHectares,
        if (description != null) 'description': description,
      });
      
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Soil endpoints
  static Future<ApiResponse<Map<String, dynamic>>> submitSoilTest({
    required int farmId,
    required Map<String, dynamic> testResults,
  }) async {
    try {
      final response = await _dio.post('/soil/tests', data: {
        'farm_id': farmId,
        'test_results': testResults,
      });
      
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Finance endpoints
  static Future<ApiResponse<List<Map<String, dynamic>>>> getLoanOptions() async {
    try {
      final response = await _dio.get('/finance/loans');
      return ApiResponse.success(List<Map<String, dynamic>>.from(response.data));
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> applyForLoan({
    required double amount,
    required String purpose,
    required int termMonths,
  }) async {
    try {
      final response = await _dio.post('/finance/loans/apply', data: {
        'amount': amount,
        'purpose': purpose,
        'term_months': termMonths,
      });
      
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Supply chain endpoints
  static Future<ApiResponse<List<Map<String, dynamic>>>> getSupplyChainEvents({
    required int batchId,
  }) async {
    try {
      final response = await _dio.get('/supply-chain/events', queryParameters: {
        'batch_id': batchId,
      });
      
      return ApiResponse.success(List<Map<String, dynamic>>.from(response.data));
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static String _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please check your internet connection.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final message = error.response?.data?['detail'] ?? 
                          error.response?.data?['message'] ?? 
                          'Server error occurred';
          return '$message (Status: $statusCode)';
        case DioExceptionType.cancel:
          return 'Request was cancelled';
        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return 'No internet connection';
          }
          return 'An unexpected error occurred';
        default:
          return 'Network error occurred';
      }
    }
    return error.toString();
  }

  static bool get isInitialized => _isInitialized;
}

class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ApiResponse.success(this.data) : error = null, isSuccess = true;
  ApiResponse.error(this.error) : data = null, isSuccess = false;
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await StorageService.getAuthToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      try {
        final refreshResponse = await ApiService.refreshToken();
        if (refreshResponse.isSuccess && refreshResponse.data != null) {
          final newToken = refreshResponse.data!['access_token'];
          await StorageService.setAuthToken(newToken);
          
          // Retry original request
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';
          
          final response = await Dio().fetch(options);
          handler.resolve(response);
          return;
        }
      } catch (e) {
        // Refresh failed, clear auth data
        await StorageService.clearAuthToken();
        await StorageService.clearUserData();
      }
    }
    handler.next(err);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST: ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('ERROR: ${err.response?.statusCode} ${err.requestOptions.path}');
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log errors for debugging
    print('API Error: ${err.message}');
    if (err.response != null) {
      print('Response data: ${err.response?.data}');
    }
    handler.next(err);
  }
}