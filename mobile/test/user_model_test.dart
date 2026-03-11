import 'package:flutter_test/flutter_test.dart';
import 'package:agricultural_platform/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('should handle string id in fromJson', () {
      final json = {
        'id': '123', // String ID from API
        'name': 'John Doe',
        'email': 'john@example.com',
        'phone': '+1234567890',
        'location': 'Kenya',
        'farm_size': '5 hectares',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 123);
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.phone, '+1234567890');
      expect(user.location, 'Kenya');
      expect(user.farmSize, '5 hectares');
    });

    test('should handle integer id in fromJson', () {
      final json = {
        'id': 456, // Integer ID
        'name': 'Jane Doe',
        'email': 'jane@example.com',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 456);
      expect(user.name, 'Jane Doe');
      expect(user.email, 'jane@example.com');
    });

    test('should handle null id in fromJson', () {
      final json = {
        'id': null,
        'name': 'Test User',
        'email': 'test@example.com',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 0);
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
    });

    test('should handle invalid string id in fromJson', () {
      final json = {
        'id': 'invalid_id',
        'name': 'Test User',
        'email': 'test@example.com',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 0); // Should fallback to 0
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
    });

    test('should handle missing id in fromJson', () {
      final json = {
        'name': 'Test User',
        'email': 'test@example.com',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 0); // Should default to 0
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
    });

    test('should handle numeric values for string fields', () {
      final json = {
        'id': '123',
        'name': 'Test User',
        'email': 'test@example.com',
        'phone': 1234567890, // Integer phone number
        'location': 12.345, // Double location (maybe coordinates)
        'farm_size': 5.5, // Double farm size
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 123);
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.phone, '1234567890');
      expect(user.location, '12.345');
      expect(user.farmSize, '5.5');
    });

    test('should handle null values for optional string fields', () {
      final json = {
        'id': '123',
        'name': 'Test User',
        'email': 'test@example.com',
        'phone': null,
        'location': null,
        'farm_size': null,
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 123);
      expect(user.name, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.phone, null);
      expect(user.location, null);
      expect(user.farmSize, null);
    });
  });
}