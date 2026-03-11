import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherApiService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String _apiKey = 'YOUR_OPENWEATHER_API_KEY'; // Replace with actual key
  
  // Get current weather
  static Future<Map<String, dynamic>> getCurrentWeather(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Get 5-day forecast
  static Future<Map<String, dynamic>> getForecast(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load forecast data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Get weather alerts
  static Future<Map<String, dynamic>> getWeatherAlerts(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/onecall?lat=$lat&lon=$lon&appid=$_apiKey&exclude=minutely,hourly'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load weather alerts');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}