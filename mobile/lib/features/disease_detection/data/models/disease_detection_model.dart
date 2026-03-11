import 'package:json_annotation/json_annotation.dart';

part 'disease_detection_model.g.dart';

@JsonSerializable()
class DiseaseDetectionModel {
  final int id;
  final int userId;
  final int? cropId;
  final int? diseaseTypeId;
  final String imageUrl;
  final double? aiConfidenceScore;
  final List<AIPrediction>? aiPredictions;
  final bool expertVerified;
  final String? expertDiagnosis;
  final String? severityLevel;
  final double? affectedAreaPercentage;
  final String? diseaseStage;
  final bool treatmentApplied;
  final String? treatmentType;
  final String status;
  final DateTime detectedAt;

  DiseaseDetectionModel({
    required this.id,
    required this.userId,
    this.cropId,
    this.diseaseTypeId,
    required this.imageUrl,
    this.aiConfidenceScore,
    this.aiPredictions,
    required this.expertVerified,
    this.expertDiagnosis,
    this.severityLevel,
    this.affectedAreaPercentage,
    this.diseaseStage,
    required this.treatmentApplied,
    this.treatmentType,
    required this.status,
    required this.detectedAt,
  });

  factory DiseaseDetectionModel.fromJson(Map<String, dynamic> json) =>
      _$DiseaseDetectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiseaseDetectionModelToJson(this);
}

@JsonSerializable()
class AIPrediction {
  final String diseaseName;
  final double confidence;
  final String severity;
  final String treatmentUrgency;

  AIPrediction({
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    required this.treatmentUrgency,
  });

  factory AIPrediction.fromJson(Map<String, dynamic> json) =>
      _$AIPredictionFromJson(json);

  Map<String, dynamic> toJson() => _$AIPredictionToJson(this);
}

@JsonSerializable()
class DiseaseTypeModel {
  final int id;
  final String name;
  final String? scientificName;
  final List<String>? commonNames;
  final String? category;
  final List<String>? affectedCrops;
  final List<String>? symptoms;
  final List<String>? treatmentMethods;
  final List<String>? preventionMethods;
  final Map<String, String>? severityLevels;

  DiseaseTypeModel({
    required this.id,
    required this.name,
    this.scientificName,
    this.commonNames,
    this.category,
    this.affectedCrops,
    this.symptoms,
    this.treatmentMethods,
    this.preventionMethods,
    this.severityLevels,
  });

  factory DiseaseTypeModel.fromJson(Map<String, dynamic> json) =>
      _$DiseaseTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$DiseaseTypeModelToJson(this);
}

@JsonSerializable()
class DiseaseDetectionRequest {
  final int? cropId;
  final String imageData; // Base64 encoded
  final double? locationLat;
  final double? locationLng;

  DiseaseDetectionRequest({
    this.cropId,
    required this.imageData,
    this.locationLat,
    this.locationLng,
  });

  factory DiseaseDetectionRequest.fromJson(Map<String, dynamic> json) =>
      _$DiseaseDetectionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DiseaseDetectionRequestToJson(this);
}

@JsonSerializable()
class DiseaseDetectionUpdate {
  final String? expertDiagnosis;
  final String? expertNotes;
  final String? severityLevel;
  final bool? treatmentApplied;
  final String? treatmentType;
  final String? treatmentEffectiveness;

  DiseaseDetectionUpdate({
    this.expertDiagnosis,
    this.expertNotes,
    this.severityLevel,
    this.treatmentApplied,
    this.treatmentType,
    this.treatmentEffectiveness,
  });

  factory DiseaseDetectionUpdate.fromJson(Map<String, dynamic> json) =>
      _$DiseaseDetectionUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$DiseaseDetectionUpdateToJson(this);
}