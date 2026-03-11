import 'dart:io';
import 'dart:convert';

void main() async {
  print('Testing API connection...');
  
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('http://127.0.0.1:3000/api/auth/login'));
    request.headers.set('Content-Type', 'application/json');
    
    final body = jsonEncode({
      'email': 'farmer@example.com',
      'password': 'password123',
    });
    
    request.write(body);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('Status Code: ${response.statusCode}');
    print('Response: $responseBody');
    
    client.close();
  } catch (e) {
    print('Error: $e');
  }
}