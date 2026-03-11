import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketApiService {
  // Multiple API endpoints for redundancy
  static const String _faoApiUrl = 'https://www.fao.org/giews/food-prices/api';
  static const String _kaceApiUrl = 'https://kacekenya.co.ke/api';
  static const String _backupApiUrl = 'https://your-backend-api.com/api';
  
  // Get current market prices
  static Future<List<Map<String, dynamic>>> getMarketPrices(String country) async {
    try {
      // Try primary API first
      final response = await http.get(
        Uri.parse('$_backupApiUrl/market-prices?country=$country'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['prices']);
      } else {
        // Fallback to mock data if API fails
        return _getMockPrices();
      }
    } catch (e) {
      // Return mock data on error
      return _getMockPrices();
    }
  }
  
  // Get price history for charts
  static Future<List<Map<String, dynamic>>> getPriceHistory(String crop, String period) async {
    try {
      final response = await http.get(
        Uri.parse('$_backupApiUrl/price-history?crop=$crop&period=$period'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['history']);
      } else {
        return _getMockPriceHistory(crop);
      }
    } catch (e) {
      return _getMockPriceHistory(crop);
    }
  }
  
  // Get buyers/sellers
  static Future<List<Map<String, dynamic>>> getBuyers(String crop, String location) async {
    try {
      final response = await http.get(
        Uri.parse('$_backupApiUrl/buyers?crop=$crop&location=$location'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['buyers']);
      } else {
        return _getMockBuyers();
      }
    } catch (e) {
      return _getMockBuyers();
    }
  }
  
  // Mock data methods (fallback)
  static List<Map<String, dynamic>> _getMockPrices() {
    return [
      {
        'crop': 'Maize',
        'price': 45.50,
        'unit': 'KES/kg',
        'change': 2.3,
        'market': 'Nairobi',
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      {
        'crop': 'Coffee',
        'price': 280.00,
        'unit': 'KES/kg',
        'change': -1.5,
        'market': 'Mombasa',
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      // Add more mock data...
    ];
  }
  
  static List<Map<String, dynamic>> _getMockPriceHistory(String crop) {
    return List.generate(30, (index) => {
      'date': DateTime.now().subtract(Duration(days: 29 - index)).toIso8601String(),
      'price': 45.0 + (index * 0.5) + (index % 3 * 2),
    });
  }
  
  static List<Map<String, dynamic>> _getMockBuyers() {
    return [
      {
        'name': 'Kenya Grain Traders Ltd',
        'contact': '+254700123456',
        'location': 'Nairobi',
        'crops': ['Maize', 'Wheat', 'Beans'],
        'rating': 4.8,
        'verified': true,
      },
      // Add more mock buyers...
    ];
  }
}