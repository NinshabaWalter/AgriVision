import 'package:json_annotation/json_annotation.dart';

part 'sms_alert.g.dart';

@JsonSerializable()
class SmsAlert {
  final String id;
  final SmsAlertType type;
  final String title;
  final String message;
  final bool isEnabled;
  final List<String> triggers;
  final String phoneNumber;
  final String language;
  final DateTime createdAt;
  final DateTime? lastSent;
  final int priority; // 1-5, where 5 is highest priority

  const SmsAlert({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isEnabled,
    required this.triggers,
    required this.phoneNumber,
    required this.language,
    required this.createdAt,
    this.lastSent,
    required this.priority,
  });

  factory SmsAlert.fromJson(Map<String, dynamic> json) => _$SmsAlertFromJson(json);
  Map<String, dynamic> toJson() => _$SmsAlertToJson(this);

  SmsAlert copyWith({
    String? id,
    SmsAlertType? type,
    String? title,
    String? message,
    bool? isEnabled,
    List<String>? triggers,
    String? phoneNumber,
    String? language,
    DateTime? createdAt,
    DateTime? lastSent,
    int? priority,
  }) {
    return SmsAlert(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      isEnabled: isEnabled ?? this.isEnabled,
      triggers: triggers ?? this.triggers,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      lastSent: lastSent ?? this.lastSent,
      priority: priority ?? this.priority,
    );
  }

  String get formattedMessage {
    switch (language) {
      case 'sw':
        return _getSwahiliMessage();
      case 'am':
        return _getAmharicMessage();
      case 'fr':
        return _getFrenchMessage();
      default:
        return message;
    }
  }

  String _getSwahiliMessage() {
    switch (type) {
      case SmsAlertType.weather:
        return 'HALI YA HEWA: $message';
      case SmsAlertType.priceAlert:
        return 'BEI ZA MAZAO: $message';
      case SmsAlertType.diseaseOutbreak:
        return 'TAHADHARI YA UGONJWA: $message';
      case SmsAlertType.paymentReminder:
        return 'UKUMBUSHO WA MALIPO: $message';
      case SmsAlertType.plantingReminder:
        return 'WAKATI WA KUPANDA: $message';
      case SmsAlertType.marketAlert:
        return 'HABARI ZA SOKO: $message';
    }
  }

  String _getAmharicMessage() {
    switch (type) {
      case SmsAlertType.weather:
        return 'የአየር ሁኔታ: $message';
      case SmsAlertType.priceAlert:
        return 'የዋጋ ማንቂያ: $message';
      case SmsAlertType.diseaseOutbreak:
        return 'የበሽታ ማስጠንቀቂያ: $message';
      case SmsAlertType.paymentReminder:
        return 'የክፍያ ማሳሰቢያ: $message';
      case SmsAlertType.plantingReminder:
        return 'የመዝራት ጊዜ: $message';
      case SmsAlertType.marketAlert:
        return 'የገበያ መረጃ: $message';
    }
  }

  String _getFrenchMessage() {
    switch (type) {
      case SmsAlertType.weather:
        return 'MÉTÉO: $message';
      case SmsAlertType.priceAlert:
        return 'ALERTE PRIX: $message';
      case SmsAlertType.diseaseOutbreak:
        return 'ALERTE MALADIE: $message';
      case SmsAlertType.paymentReminder:
        return 'RAPPEL PAIEMENT: $message';
      case SmsAlertType.plantingReminder:
        return 'TEMPS DE PLANTATION: $message';
      case SmsAlertType.marketAlert:
        return 'INFO MARCHÉ: $message';
    }
  }
}

enum SmsAlertType {
  @JsonValue('weather')
  weather,
  @JsonValue('price_alert')
  priceAlert,
  @JsonValue('disease_outbreak')
  diseaseOutbreak,
  @JsonValue('payment_reminder')
  paymentReminder,
  @JsonValue('planting_reminder')
  plantingReminder,
  @JsonValue('market_alert')
  marketAlert,
}

@JsonSerializable()
class UssdCommand {
  final String code;
  final String description;
  final String response;
  final List<UssdCommand> subCommands;

  const UssdCommand({
    required this.code,
    required this.description,
    required this.response,
    this.subCommands = const [],
  });

  factory UssdCommand.fromJson(Map<String, dynamic> json) => _$UssdCommandFromJson(json);
  Map<String, dynamic> toJson() => _$UssdCommandToJson(this);
}