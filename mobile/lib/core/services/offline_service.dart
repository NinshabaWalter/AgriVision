import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../app_config.dart';
import 'storage_service.dart';
import 'api_service.dart';

class OfflineService {
  static final List<OfflineAction> _pendingActions = [];
  static bool _isSyncing = false;

  static Future<void> initialize() async {
    // Load pending actions from storage
    await _loadPendingActions();
    
    // Listen for connectivity changes
    Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
    
    // Check if we're online and sync if needed
    if (await ApiService.isConnected()) {
      await syncPendingActions();
    }
  }

  static Future<void> _loadPendingActions() async {
    try {
      final actionsData = StorageService.getOfflineData('pending_actions');
      if (actionsData != null) {
        final List<dynamic> actionsList = actionsData['actions'] ?? [];
        _pendingActions.clear();
        _pendingActions.addAll(
          actionsList.map((action) => OfflineAction.fromJson(action)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Failed to load pending actions: $e');
    }
  }

  static Future<void> _savePendingActions() async {
    try {
      await StorageService.setOfflineData('pending_actions', {
        'actions': _pendingActions.map((action) => action.toJson()).toList(),
      });
    } catch (e) {
      debugPrint('Failed to save pending actions: $e');
    }
  }

  static void _onConnectivityChanged(ConnectivityResult result) {
    if (result != ConnectivityResult.none) {
      // We're back online, sync pending actions
      syncPendingActions();
    }
  }

  // Disease Detection Offline Methods
  static Future<String> saveDiseaseDetectionOffline({
    required File imageFile,
    required List<Map<String, dynamic>> predictions,
    int? cropId,
    double? locationLat,
    double? locationLng,
  }) async {
    final String offlineId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Save image locally
    final String imagePath = await _saveImageLocally(imageFile, 'disease_$offlineId');
    
    // Create offline detection record
    final detectionData = {
      'id': offlineId,
      'image_path': imagePath,
      'predictions': predictions,
      'crop_id': cropId,
      'location_lat': locationLat,
      'location_lng': locationLng,
      'detected_at': DateTime.now().toIso8601String(),
      'synced': false,
    };
    
    // Save to offline storage
    await StorageService.setOfflineData('disease_detection_$offlineId', detectionData);
    
    // Add sync action
    _pendingActions.add(OfflineAction(
      id: offlineId,
      type: OfflineActionType.diseaseDetection,
      data: detectionData,
      timestamp: DateTime.now(),
    ));
    
    await _savePendingActions();
    return offlineId;
  }

  static Future<List<Map<String, dynamic>>> getOfflineDiseaseDetections() async {
    final List<Map<String, dynamic>> detections = [];
    
    final keys = StorageService.getOfflineDataKeys();
    for (final key in keys) {
      if (key.startsWith('disease_detection_')) {
        final data = StorageService.getOfflineData(key);
        if (data != null) {
          detections.add(data);
        }
      }
    }
    
    // Sort by detection time (newest first)
    detections.sort((a, b) {
      final aTime = DateTime.parse(a['detected_at']);
      final bTime = DateTime.parse(b['detected_at']);
      return bTime.compareTo(aTime);
    });
    
    return detections;
  }

  // Weather Data Offline Methods
  static Future<void> cacheWeatherData({
    required double lat,
    required double lng,
    required Map<String, dynamic> currentWeather,
    required List<Map<String, dynamic>> forecast,
  }) async {
    final cacheKey = 'weather_${lat.toStringAsFixed(2)}_${lng.toStringAsFixed(2)}';
    
    await StorageService.setOfflineData(cacheKey, {
      'current': currentWeather,
      'forecast': forecast,
      'location': {'lat': lat, 'lng': lng},
    });
  }

  static Map<String, dynamic>? getCachedWeatherData(double lat, double lng) {
    final cacheKey = 'weather_${lat.toStringAsFixed(2)}_${lng.toStringAsFixed(2)}';
    return StorageService.getOfflineData(cacheKey);
  }

  // Market Data Offline Methods
  static Future<void> cacheMarketPrices({
    required String cropType,
    required String location,
    required List<Map<String, dynamic>> prices,
  }) async {
    final cacheKey = 'market_${cropType}_$location';
    
    await StorageService.setOfflineData(cacheKey, {
      'prices': prices,
      'crop_type': cropType,
      'location': location,
    });
  }

  static Map<String, dynamic>? getCachedMarketPrices(String cropType, String location) {
    final cacheKey = 'market_${cropType}_$location';
    return StorageService.getOfflineData(cacheKey);
  }

  // Farm Data Offline Methods
  static Future<String> saveFarmOffline({
    required String name,
    required double lat,
    required double lng,
    double? sizeHectares,
    String? description,
  }) async {
    final String offlineId = 'farm_${DateTime.now().millisecondsSinceEpoch}';
    
    final farmData = {
      'id': offlineId,
      'name': name,
      'location_lat': lat,
      'location_lng': lng,
      'size_hectares': sizeHectares,
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
      'synced': false,
    };
    
    await StorageService.setOfflineData(offlineId, farmData);
    
    _pendingActions.add(OfflineAction(
      id: offlineId,
      type: OfflineActionType.createFarm,
      data: farmData,
      timestamp: DateTime.now(),
    ));
    
    await _savePendingActions();
    return offlineId;
  }

  // Sync Methods
  static Future<void> syncPendingActions() async {
    if (_isSyncing || !await ApiService.isConnected()) {
      return;
    }
    
    _isSyncing = true;
    
    try {
      final actionsToSync = List<OfflineAction>.from(_pendingActions);
      
      for (final action in actionsToSync) {
        try {
          await _syncAction(action);
          _pendingActions.remove(action);
        } catch (e) {
          debugPrint('Failed to sync action ${action.id}: $e');
          // Keep action in queue for retry
        }
      }
      
      await _savePendingActions();
    } finally {
      _isSyncing = false;
    }
  }

  static Future<void> _syncAction(OfflineAction action) async {
    switch (action.type) {
      case OfflineActionType.diseaseDetection:
        await _syncDiseaseDetection(action);
        break;
      case OfflineActionType.createFarm:
        await _syncCreateFarm(action);
        break;
      case OfflineActionType.soilTest:
        await _syncSoilTest(action);
        break;
      case OfflineActionType.loanApplication:
        await _syncLoanApplication(action);
        break;
    }
  }

  static Future<void> _syncDiseaseDetection(OfflineAction action) async {
    final data = action.data;
    final imagePath = data['image_path'] as String;
    final imageFile = File(imagePath);
    
    if (!imageFile.existsSync()) {
      throw Exception('Image file not found: $imagePath');
    }
    
    final response = await ApiService.detectDisease(
      imageFile: imageFile,
      cropId: data['crop_id'],
      locationLat: data['location_lat'],
      locationLng: data['location_lng'],
    );
    
    if (response.isSuccess) {
      // Update offline record with server response
      data['server_id'] = response.data!['id'];
      data['synced'] = true;
      await StorageService.setOfflineData('disease_detection_${action.id}', data);
      
      // Clean up local image
      try {
        await imageFile.delete();
      } catch (e) {
        debugPrint('Failed to delete local image: $e');
      }
    } else {
      throw Exception(response.error);
    }
  }

  static Future<void> _syncCreateFarm(OfflineAction action) async {
    final data = action.data;
    
    final response = await ApiService.createFarm(
      name: data['name'],
      lat: data['location_lat'],
      lng: data['location_lng'],
      sizeHectares: data['size_hectares'],
      description: data['description'],
    );
    
    if (response.isSuccess) {
      // Update offline record
      data['server_id'] = response.data!['id'];
      data['synced'] = true;
      await StorageService.setOfflineData(action.id, data);
    } else {
      throw Exception(response.error);
    }
  }

  static Future<void> _syncSoilTest(OfflineAction action) async {
    final data = action.data;
    
    final response = await ApiService.submitSoilTest(
      farmId: data['farm_id'],
      testResults: data['test_results'],
    );
    
    if (response.isSuccess) {
      data['server_id'] = response.data!['id'];
      data['synced'] = true;
      await StorageService.setOfflineData('soil_test_${action.id}', data);
    } else {
      throw Exception(response.error);
    }
  }

  static Future<void> _syncLoanApplication(OfflineAction action) async {
    final data = action.data;
    
    final response = await ApiService.applyForLoan(
      amount: data['amount'],
      purpose: data['purpose'],
      termMonths: data['term_months'],
    );
    
    if (response.isSuccess) {
      data['server_id'] = response.data!['id'];
      data['synced'] = true;
      await StorageService.setOfflineData('loan_application_${action.id}', data);
    } else {
      throw Exception(response.error);
    }
  }

  static Future<String> _saveImageLocally(File imageFile, String filename) async {
    // Implementation would save image to app's documents directory
    // For now, return the original path
    return imageFile.path;
  }

  // Status Methods
  static bool get isSyncing => _isSyncing;
  
  static int get pendingActionsCount => _pendingActions.length;
  
  static List<OfflineAction> get pendingActions => List.unmodifiable(_pendingActions);
  
  static Future<void> clearSyncedData() async {
    final keys = StorageService.getOfflineDataKeys();
    for (final key in keys) {
      final data = StorageService.getOfflineData(key);
      if (data != null && data['synced'] == true) {
        await StorageService.removeOfflineData(key);
      }
    }
  }
}

enum OfflineActionType {
  diseaseDetection,
  createFarm,
  soilTest,
  loanApplication,
}

class OfflineAction {
  final String id;
  final OfflineActionType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  int retryCount;

  OfflineAction({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'retry_count': retryCount,
    };
  }

  factory OfflineAction.fromJson(Map<String, dynamic> json) {
    return OfflineAction(
      id: json['id'],
      type: OfflineActionType.values[json['type']],
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      retryCount: json['retry_count'] ?? 0,
    );
  }
}