import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:tflite_flutter/tflite_flutter.dart'; // Temporarily disabled
import 'package:image/image.dart' as img;
import '../app_config.dart';

class MLService {
  // static Interpreter? _interpreter; // Temporarily disabled
  static List<String> _labels = [];
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    try {
      // Load labels (TensorFlow model loading temporarily disabled)
      await _loadLabels();
      
      _isInitialized = true;
      debugPrint('ML Service initialized successfully (mock mode)');
    } catch (e) {
      debugPrint('Failed to initialize ML Service: $e');
      _isInitialized = false;
    }
  }

  static Future<void> _loadLabels() async {
    try {
      final String labelsData = await rootBundle.loadString(AppConfig.diseaseLabelsPath);
      _labels = labelsData.split('\n').where((label) => label.isNotEmpty).toList();
    } catch (e) {
      // Fallback labels if file doesn't exist
      _labels = [
        'healthy',
        'bacterial_blight',
        'brown_spot',
        'leaf_blast',
        'tungro',
        'bacterial_leaf_streak',
        'sheath_blight',
        'leaf_scald',
        'narrow_brown_spot',
      ];
    }
  }

  static Future<List<DiseaseDetectionResult>> detectDisease(File imageFile) async {
    if (!_isInitialized) {
      throw Exception('ML Service not initialized');
    }

    try {
      // Mock disease detection for now (TensorFlow temporarily disabled)
      await Future.delayed(const Duration(milliseconds: 1500)); // Simulate processing time
      
      // Generate mock predictions based on image analysis
      final List<double> mockPredictions = _generateMockPredictions();
      return _processResults(mockPredictions);
      
    } catch (e) {
      debugPrint('Disease detection failed: $e');
      throw Exception('Disease detection failed: $e');
    }
  }

  static List<double> _generateMockPredictions() {
    final Random random = Random();
    final List<double> predictions = List.filled(_labels.length, 0.0);
    
    // Generate realistic mock predictions
    final int primaryIndex = random.nextInt(_labels.length);
    predictions[primaryIndex] = 0.6 + random.nextDouble() * 0.3; // 0.6-0.9
    
    // Add some secondary predictions
    for (int i = 0; i < _labels.length; i++) {
      if (i != primaryIndex) {
        predictions[i] = random.nextDouble() * 0.4; // 0.0-0.4
      }
    }
    
    return predictions;
  }

  static Future<Float32List> _preprocessImage(File imageFile) async {
    // Read and decode image
    final Uint8List imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);
    
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize to model input size (224x224)
    image = img.copyResize(image, width: 224, height: 224);

    // Convert to RGB if necessary
    if (image.numChannels != 3) {
      image = img.copyResize(image, width: 224, height: 224);
    }

    // Normalize pixel values to [0, 1]
    final Float32List input = Float32List(1 * 224 * 224 * 3);
    int pixelIndex = 0;

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = image.getPixel(x, y);
        
        // Extract RGB values and normalize
        input[pixelIndex++] = pixel.r / 255.0;
        input[pixelIndex++] = pixel.g / 255.0;
        input[pixelIndex++] = pixel.b / 255.0;
      }
    }

    return input;
  }

  static List<DiseaseDetectionResult> _processResults(List<double> predictions) {
    final List<DiseaseDetectionResult> results = [];

    // Create list of predictions with their indices
    final List<MapEntry<int, double>> indexedPredictions = [];
    for (int i = 0; i < predictions.length; i++) {
      indexedPredictions.add(MapEntry(i, predictions[i]));
    }

    // Sort by confidence (descending)
    indexedPredictions.sort((a, b) => b.value.compareTo(a.value));

    // Take top 3 predictions with confidence > 0.1
    for (int i = 0; i < indexedPredictions.length && i < 3; i++) {
      final entry = indexedPredictions[i];
      final confidence = entry.value;
      
      if (confidence > 0.1) {
        final labelIndex = entry.key;
        final diseaseName = labelIndex < _labels.length 
            ? _labels[labelIndex] 
            : 'unknown_$labelIndex';

        results.add(DiseaseDetectionResult(
          diseaseName: diseaseName,
          confidence: confidence,
          severity: _estimateSeverity(confidence),
          treatmentUrgency: _estimateUrgency(diseaseName, confidence),
          recommendations: _getRecommendations(diseaseName, confidence),
        ));
      }
    }

    return results;
  }

  static String _estimateSeverity(double confidence) {
    if (confidence > 0.8) return 'severe';
    if (confidence > 0.6) return 'moderate';
    if (confidence > 0.4) return 'mild';
    return 'uncertain';
  }

  static String _estimateUrgency(String diseaseName, double confidence) {
    if (diseaseName == 'healthy') return 'none';
    
    final highUrgencyDiseases = [
      'leaf_blast',
      'bacterial_blight',
      'tungro',
      'bacterial_leaf_streak'
    ];

    if (highUrgencyDiseases.contains(diseaseName) && confidence > 0.7) {
      return 'high';
    } else if (confidence > 0.6) {
      return 'medium';
    } else {
      return 'low';
    }
  }

  static List<String> _getRecommendations(String diseaseName, double confidence) {
    final Map<String, List<String>> diseaseRecommendations = {
      'healthy': [
        'Continue current care practices',
        'Monitor regularly for any changes',
        'Maintain proper nutrition and watering'
      ],
      'bacterial_blight': [
        'Remove affected leaves immediately',
        'Apply copper-based fungicide',
        'Improve air circulation',
        'Avoid overhead watering'
      ],
      'brown_spot': [
        'Apply appropriate fungicide',
        'Ensure proper field drainage',
        'Remove infected plant debris',
        'Practice crop rotation'
      ],
      'leaf_blast': [
        'Apply systemic fungicide immediately',
        'Remove severely affected plants',
        'Improve field sanitation',
        'Consider resistant varieties for next season'
      ],
      'tungro': [
        'Control green leafhopper vectors',
        'Remove infected plants',
        'Use virus-free seeds',
        'Apply insecticide for vector control'
      ],
      'bacterial_leaf_streak': [
        'Apply bactericide treatment',
        'Improve field drainage',
        'Remove infected leaves',
        'Avoid working in wet fields'
      ],
      'sheath_blight': [
        'Apply fungicide to affected areas',
        'Improve air circulation',
        'Reduce plant density if needed',
        'Practice proper field sanitation'
      ],
    };

    return diseaseRecommendations[diseaseName] ?? [
      'Consult with agricultural extension officer',
      'Monitor plant closely',
      'Consider laboratory diagnosis',
      'Apply general plant health practices'
    ];
  }

  static bool get isInitialized => _isInitialized;

  static void dispose() {
    // _interpreter?.close(); // Temporarily disabled
    // _interpreter = null; // Temporarily disabled
    _isInitialized = false;
  }
}

class DiseaseDetectionResult {
  final String diseaseName;
  final double confidence;
  final String severity;
  final String treatmentUrgency;
  final List<String> recommendations;

  DiseaseDetectionResult({
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    required this.treatmentUrgency,
    required this.recommendations,
  });

  Map<String, dynamic> toJson() {
    return {
      'disease_name': diseaseName,
      'confidence': confidence,
      'severity': severity,
      'treatment_urgency': treatmentUrgency,
      'recommendations': recommendations,
    };
  }

  factory DiseaseDetectionResult.fromJson(Map<String, dynamic> json) {
    return DiseaseDetectionResult(
      diseaseName: json['disease_name'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      severity: json['severity'] ?? 'unknown',
      treatmentUrgency: json['treatment_urgency'] ?? 'low',
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}