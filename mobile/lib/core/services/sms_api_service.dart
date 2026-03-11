import 'dart:convert';
import 'package:http/http.dart' as http;

class SmsApiService {
  // Africa's Talking API configuration
  static const String _baseUrl = 'https://api.africastalking.com/version1';
  static const String _username = 'YOUR_AT_USERNAME'; // Replace with actual username
  static const String _apiKey = 'YOUR_AT_API_KEY'; // Replace with actual API key
  
  // Send SMS alert
  static Future<bool> sendSmsAlert(String phoneNumber, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/messaging'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
          'apiKey': _apiKey,
        },
        body: {
          'username': _username,
          'to': phoneNumber,
          'message': message,
          'from': 'AgriVision', // Your sender ID
        },
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['SMSMessageData']['Recipients'][0]['status'] == 'Success';
      }
      return false;
    } catch (e) {
      print('SMS sending error: $e');
      return false;
    }
  }
  
  // Send bulk SMS alerts
  static Future<Map<String, dynamic>> sendBulkSms(List<String> phoneNumbers, String message) async {
    try {
      final recipients = phoneNumbers.join(',');
      final response = await http.post(
        Uri.parse('$_baseUrl/messaging'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
          'apiKey': _apiKey,
        },
        body: {
          'username': _username,
          'to': recipients,
          'message': message,
          'from': 'AgriVision',
        },
      );
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      return {'success': false, 'error': 'Failed to send bulk SMS'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // USSD session handling
  static Future<String> handleUssdSession(String sessionId, String phoneNumber, String text) async {
    try {
      // This would typically connect to your USSD application logic
      final response = await http.post(
        Uri.parse('$_baseUrl/ussd'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
          'apiKey': _apiKey,
        },
        body: {
          'sessionId': sessionId,
          'phoneNumber': phoneNumber,
          'text': text,
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['response'] ?? 'END Service temporarily unavailable';
      }
      return 'END Service error';
    } catch (e) {
      return 'END Service temporarily unavailable';
    }
  }
  
  // Get SMS delivery reports
  static Future<List<Map<String, dynamic>>> getDeliveryReports() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/messaging/reports'),
        headers: {
          'Accept': 'application/json',
          'apiKey': _apiKey,
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['reports'] ?? []);
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}