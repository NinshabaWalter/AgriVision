import 'dart:convert';
import 'package:http/http.dart' as http;

class FinancialApiService {
  // M-Pesa API configuration
  static const String _mpesaBaseUrl = 'https://sandbox.safaricom.co.ke'; // Use production URL for live
  static const String _consumerKey = 'YOUR_MPESA_CONSUMER_KEY';
  static const String _consumerSecret = 'YOUR_MPESA_CONSUMER_SECRET';
  
  // Banking API configuration
  static const String _bankingApiUrl = 'https://your-banking-partner-api.com';
  static const String _bankingApiKey = 'YOUR_BANKING_API_KEY';
  
  // Get M-Pesa access token
  static Future<String?> getMpesaAccessToken() async {
    try {
      final credentials = base64Encode(utf8.encode('$_consumerKey:$_consumerSecret'));
      final response = await http.get(
        Uri.parse('$_mpesaBaseUrl/oauth/v1/generate?grant_type=client_credentials'),
        headers: {
          'Authorization': 'Basic $credentials',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['access_token'];
      }
      return null;
    } catch (e) {
      print('M-Pesa token error: $e');
      return null;
    }
  }
  
  // Initiate STK Push (M-Pesa payment)
  static Future<Map<String, dynamic>> initiateStkPush({
    required String phoneNumber,
    required double amount,
    required String accountReference,
    required String transactionDesc,
  }) async {
    try {
      final accessToken = await getMpesaAccessToken();
      if (accessToken == null) {
        return {'success': false, 'error': 'Failed to get access token'};
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final password = base64Encode(utf8.encode('YOUR_SHORTCODE$YOUR_PASSKEY$timestamp'));
      
      final response = await http.post(
        Uri.parse('$_mpesaBaseUrl/mpesa/stkpush/v1/processrequest'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'BusinessShortCode': 'YOUR_SHORTCODE',
          'Password': password,
          'Timestamp': timestamp,
          'TransactionType': 'CustomerPayBillOnline',
          'Amount': amount.toInt(),
          'PartyA': phoneNumber,
          'PartyB': 'YOUR_SHORTCODE',
          'PhoneNumber': phoneNumber,
          'CallBackURL': 'https://your-callback-url.com/callback',
          'AccountReference': accountReference,
          'TransactionDesc': transactionDesc,
        }),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'success': false, 'error': 'Payment initiation failed'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Get loan products
  static Future<List<Map<String, dynamic>>> getLoanProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$_bankingApiUrl/loan-products'),
        headers: {
          'Authorization': 'Bearer $_bankingApiKey',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['products']);
      } else {
        return _getMockLoanProducts();
      }
    } catch (e) {
      return _getMockLoanProducts();
    }
  }
  
  // Apply for loan
  static Future<Map<String, dynamic>> applyForLoan({
    required String loanType,
    required double amount,
    required int termMonths,
    required Map<String, dynamic> applicantData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_bankingApiUrl/loan-applications'),
        headers: {
          'Authorization': 'Bearer $_bankingApiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'loanType': loanType,
          'amount': amount,
          'termMonths': termMonths,
          'applicant': applicantData,
          'applicationDate': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      return {'success': false, 'error': 'Loan application failed'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Get insurance products
  static Future<List<Map<String, dynamic>>> getInsuranceProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$_bankingApiUrl/insurance-products'),
        headers: {
          'Authorization': 'Bearer $_bankingApiKey',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['products']);
      } else {
        return _getMockInsuranceProducts();
      }
    } catch (e) {
      return _getMockInsuranceProducts();
    }
  }
  
  // Get transaction history
  static Future<List<Map<String, dynamic>>> getTransactionHistory(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_bankingApiUrl/transactions/$userId'),
        headers: {
          'Authorization': 'Bearer $_bankingApiKey',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['transactions']);
      } else {
        return _getMockTransactions();
      }
    } catch (e) {
      return _getMockTransactions();
    }
  }
  
  // Mock data methods
  static List<Map<String, dynamic>> _getMockLoanProducts() {
    return [
      {
        'id': '1',
        'name': 'Agricultural Input Loan',
        'description': 'Short-term loan for seeds, fertilizers, and farming inputs',
        'minAmount': 5000,
        'maxAmount': 500000,
        'interestRate': 12.5,
        'termMonths': [3, 6, 12],
        'requirements': ['Valid ID', 'Farm ownership proof', 'Previous harvest records'],
      },
      {
        'id': '2',
        'name': 'Equipment Finance',
        'description': 'Long-term financing for farm equipment and machinery',
        'minAmount': 50000,
        'maxAmount': 2000000,
        'interestRate': 15.0,
        'termMonths': [12, 24, 36, 48],
        'requirements': ['Valid ID', 'Business registration', 'Collateral'],
      },
    ];
  }
  
  static List<Map<String, dynamic>> _getMockInsuranceProducts() {
    return [
      {
        'id': '1',
        'name': 'Crop Insurance',
        'description': 'Protection against weather-related crop losses',
        'premium': 5.0, // Percentage of sum insured
        'coverage': ['Drought', 'Flood', 'Hail', 'Pest damage'],
        'maxCoverage': 1000000,
      },
      {
        'id': '2',
        'name': 'Livestock Insurance',
        'description': 'Coverage for cattle, goats, and poultry',
        'premium': 8.0,
        'coverage': ['Disease', 'Accident', 'Theft'],
        'maxCoverage': 500000,
      },
    ];
  }
  
  static List<Map<String, dynamic>> _getMockTransactions() {
    return [
      {
        'id': 'TXN001',
        'type': 'income',
        'amount': 45000,
        'description': 'Maize sale to local buyer',
        'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'category': 'Sales',
      },
      {
        'id': 'TXN002',
        'type': 'expense',
        'amount': 8500,
        'description': 'Fertilizer purchase',
        'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'category': 'Inputs',
      },
    ];
  }
}