import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../auth/data/models/user_model.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  AuthNotifier() : super(const AsyncValue.loading());

  Future<void> checkAuthStatus() async {
    try {
      final token = await StorageService.getAuthToken();
      if (token != null) {
        final userData = StorageService.getUserData();
        if (userData != null) {
          final user = UserModel.fromJson(userData);
          state = AsyncValue.data(user);
        } else {
          await logout();
        }
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      print('AuthNotifier: Starting login for $email');
      state = const AsyncValue.loading();
      
      final response = await ApiService.login(
        email: email,
        password: password,
      );

      print('AuthNotifier: Login response - Success: ${response.isSuccess}');
      if (response.error != null) {
        print('AuthNotifier: Login error: ${response.error}');
      }

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        print('AuthNotifier: Login successful, processing response data');
        
        // Save auth token
        final token = data['token'] ?? data['access_token'];
        if (token != null) {
          await StorageService.setAuthToken(token);
          print('AuthNotifier: Token saved successfully');
        } else {
          print('AuthNotifier: Warning - No token found in response');
        }
        
        // Save user data
        final userData = data['user'] ?? {};
        print('AuthNotifier: User data structure: $userData');
        await StorageService.setUserData(userData);
        print('AuthNotifier: User data saved successfully');
        
        // Update state
        print('AuthNotifier: Creating UserModel from JSON...');
        final user = UserModel.fromJson(userData);
        print('AuthNotifier: UserModel created successfully: ${user.toJson()}');
        state = AsyncValue.data(user);
        
        return true;
      } else {
        final errorMsg = response.error ?? 'Login failed';
        print('AuthNotifier: Login failed - $errorMsg');
        state = AsyncValue.error(errorMsg, StackTrace.current);
        return false;
      }
    } catch (e) {
      print('AuthNotifier: Login exception - $e');
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      final response = await ApiService.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        
        // Save auth token
        await StorageService.setAuthToken(data['access_token']);
        
        // Save user data
        final userData = data['user'] ?? {};
        await StorageService.setUserData(userData);
        
        // Update state
        final user = UserModel.fromJson(userData);
        state = AsyncValue.data(user);
        
        return true;
      } else {
        state = AsyncValue.error(response.error ?? 'Registration failed', StackTrace.current);
        return false;
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      // Clear stored data
      await StorageService.clearAuthToken();
      await StorageService.clearUserData();
      
      // Update state
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await StorageService.setUserData(user.toJson());
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}