import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String _baseUrl = String.fromEnvironment('GATEWAY_URL', defaultValue: 'http://localhost:3000/api'); // Override via --dart-define for devices
  static const Duration _timeout = Duration(seconds: 30);
  
  static final Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Weather API
  static Future<Map<String, dynamic>> getCurrentWeather(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather/current?lat=$lat&lon=$lon'),
        headers: _defaultHeaders,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('Failed to fetch weather data', response.statusCode);
      }
    } on SocketException {
      throw ApiException('No internet connection', 0);
    } on HttpException {
      throw ApiException('HTTP error occurred', 0);
    } catch (e) {
      throw ApiException('Unexpected error: $e', 0);
    }
  }

  // SMS API
  static Future<Map<String, dynamic>> sendSms(String to, String message, {String type = 'alert'}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/sms/send'),
        headers: _defaultHeaders,
        body: json.encode({
          'to': to,
          'message': message,
          'type': type,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('Failed to send SMS', response.statusCode);
      }
    } catch (e) {
      throw ApiException('SMS sending failed: $e', 0);
    }
  }

  // Market Data API
  static Future<Map<String, dynamic>> getMarketPrices({String? country, String? crop}) async {
    try {
      String url = '$_baseUrl/market/prices';
      List<String> params = [];
      
      if (country != null) params.add('country=$country');
      if (crop != null) params.add('crop=$crop');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _defaultHeaders,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('Failed to fetch market prices', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Market data fetch failed: $e', 0);
    }
  }

  // Price History API
  static Future<Map<String, dynamic>> getPriceHistory(String crop, {int days = 30}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/market/history/$crop?days=$days'),
        headers: _defaultHeaders,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('Failed to fetch price history', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Price history fetch failed: $e', 0);
    }
  }

  // M-Pesa STK Push
  static Future<Map<String, dynamic>> initiateMpesaPayment({
    required String phone,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/mpesa/stkpush'),
        headers: _defaultHeaders,
        body: json.encode({
          'phone': phone,
          'amount': amount,
          'account_reference': accountReference,
          'transaction_desc': transactionDesc,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('Payment initiation failed', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Payment failed: $e', 0);
    }
  }

  // Geocoding API
  static Future<Map<String, dynamic>> geocodeAddress(String address) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/geocode?address=${Uri.encodeComponent(address)}'),
        headers: _defaultHeaders,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('Geocoding failed', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Geocoding error: $e', 0);
    }
  }

  // Reverse Geocoding API
  static Future<Map<String, dynamic>> reverseGeocode(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/reverse-geocode?lat=$lat&lon=$lon'),
        headers: _defaultHeaders,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('Reverse geocoding failed', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Reverse geocoding error: $e', 0);
    }
  }

  // Push Notifications API
  static Future<Map<String, dynamic>> sendPushNotification({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/notifications/send'),
        headers: _defaultHeaders,
        body: json.encode({
          'token': token,
          'title': title,
          'body': body,
          'data': data ?? {},
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('Push notification failed', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Notification error: $e', 0);
    }
  }

  // Agora Token API
  static Future<Map<String, dynamic>> getAgoraToken({
    required String channelName,
    required String uid,
    int role = 1,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/agora/token'),
        headers: _defaultHeaders,
        body: json.encode({
          'channelName': channelName,
          'uid': uid,
          'role': role,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('Agora token generation failed', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Agora token error: $e', 0);
    }
  }

  // AI Disease Detection API
  static Future<Map<String, dynamic>> detectDisease({
    required String imageBase64,
    String? cropType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/ai/detect-disease'),
        headers: _defaultHeaders,
        body: json.encode({
          'image_base64': imageBase64,
          'crop_type': cropType,
        }),
      ).timeout(const Duration(seconds: 60)); // Longer timeout for AI processing

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('Disease detection failed', response.statusCode);
      }
    } catch (e) {
      throw ApiException('AI detection error: $e', 0);
    }
  }

  // Expert Consultation APIs
  static Future<Map<String, dynamic>> getExperts({
    String? specialty,
    String? language,
  }) async {
    try {
      String url = '$_baseUrl/experts';
      List<String> params = [];
      
      if (specialty != null) params.add('specialty=$specialty');
      if (language != null) params.add('language=$language');
      
      if (params.isNotEmpty) {
        url += '?${params.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _defaultHeaders,
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('Failed to fetch experts', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Experts fetch error: $e', 0);
    }
  }

  static Future<Map<String, dynamic>> bookConsultation({
    required String expertId,
    required String date,
    required String time,
    int? duration,
    String? topic,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/experts/book'),
        headers: _defaultHeaders,
        body: json.encode({
          'expert_id': expertId,
          'date': date,
          'time': time,
          'duration': duration,
          'topic': topic,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('Booking failed', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Booking error: $e', 0);
    }
  }

  // Health Check
  static Future<Map<String, dynamic>> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('${_baseUrl.replaceAll('/api', '')}/health'),
        headers: _defaultHeaders,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('Health check failed', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Health check error: $e', 0);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

// Response wrapper for consistent API responses
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse(
      success: true,
      data: data,
    );
  }

  factory ApiResponse.error(String error, [int? statusCode]) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }
}