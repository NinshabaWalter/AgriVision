class MarketplaceItem {
  final String id;
  final String cropType;
  final String quantity; // e.g., "100 kg"
  final double pricePerKg;
  final String location;
  final String farmerName;
  final double farmerRating;
  final String imageUrl;
  final String description;
  final DateTime harvestDate;
  final String qualityGrade;
  final bool isOrganic;
  final bool isCertified;
  final List<String> certifications;

  const MarketplaceItem({
    required this.id,
    required this.cropType,
    required this.quantity,
    required this.pricePerKg,
    required this.location,
    required this.farmerName,
    required this.farmerRating,
    required this.imageUrl,
    required this.description,
    required this.harvestDate,
    required this.qualityGrade,
    this.isOrganic = false,
    this.isCertified = false,
    this.certifications = const [],
  });

  factory MarketplaceItem.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return MarketplaceItem({
      id: json['id']?.toString() ?? '',
      cropType: json['cropType']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '0 kg',
      pricePerKg: _toDouble(json['pricePerKg']),
      location: json['location']?.toString() ?? '',
      farmerName: json['farmerName']?.toString() ?? '',
      farmerRating: _toDouble(json['farmerRating']),
      imageUrl: json['imageUrl']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      harvestDate: DateTime.tryParse(json['harvestDate']?.toString() ?? '') ?? DateTime.now(),
      qualityGrade: json['qualityGrade']?.toString() ?? 'Unknown',
      isOrganic: json['isOrganic'] == true,
      isCertified: json['isCertified'] == true,
      certifications: (json['certifications'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    });
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cropType': cropType,
        'quantity': quantity,
        'pricePerKg': pricePerKg,
        'location': location,
        'farmerName': farmerName,
        'farmerRating': farmerRating,
        'imageUrl': imageUrl,
        'description': description,
        'harvestDate': harvestDate.toIso8601String(),
        'qualityGrade': qualityGrade,
        'isOrganic': isOrganic,
        'isCertified': isCertified,
        'certifications': certifications,
      };

  double get totalPrice => pricePerKg * _getQuantityInKg();

  int _getQuantityInKg() {
    // Parse quantity string to get numeric value
    final regex = RegExp(r'\d+');
    final match = regex.firstMatch(quantity);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  String get freshness {
    final daysSinceHarvest = DateTime.now().difference(harvestDate).inDays;
    if (daysSinceHarvest <= 1) return 'Very Fresh';
    if (daysSinceHarvest <= 3) return 'Fresh';
    if (daysSinceHarvest <= 7) return 'Good';
    return 'Consider pricing adjustment';
  }

  MarketplaceItem copyWith({
    String? id,
    String? cropType,
    String? quantity,
    double? pricePerKg,
    String? location,
    String? farmerName,
    double? farmerRating,
    String? imageUrl,
    String? description,
    DateTime? harvestDate,
    String? qualityGrade,
    bool? isOrganic,
    bool? isCertified,
    List<String>? certifications,
  }) {
    return MarketplaceItem(
      id: id ?? this.id,
      cropType: cropType ?? this.cropType,
      quantity: quantity ?? this.quantity,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      location: location ?? this.location,
      farmerName: farmerName ?? this.farmerName,
      farmerRating: farmerRating ?? this.farmerRating,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      harvestDate: harvestDate ?? this.harvestDate,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      isOrganic: isOrganic ?? this.isOrganic,
      isCertified: isCertified ?? this.isCertified,
      certifications: certifications ?? this.certifications,
    );
  }
}

class MarketPriceData {
  final String cropType;
  final String location;
  final double currentPrice;
  final double previousPrice;
  final double changePercentage;
  final DateTime lastUpdated;
  final String unit;
  final String market;

  const MarketPriceData({
    required this.cropType,
    required this.location,
    required this.currentPrice,
    required this.previousPrice,
    required this.changePercentage,
    required this.lastUpdated,
    required this.unit,
    required this.market,
  });

  factory MarketPriceData.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return MarketPriceData(
      cropType: json['cropType']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      currentPrice: _toDouble(json['currentPrice']),
      previousPrice: _toDouble(json['previousPrice']),
      changePercentage: _toDouble(json['changePercentage']),
      lastUpdated: DateTime.tryParse(json['lastUpdated']?.toString() ?? '') ?? DateTime.now(),
      unit: json['unit']?.toString() ?? 'KES/kg',
      market: json['market']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'cropType': cropType,
        'location': location,
        'currentPrice': currentPrice,
        'previousPrice': previousPrice,
        'changePercentage': changePercentage,
        'lastUpdated': lastUpdated.toIso8601String(),
        'unit': unit,
        'market': market,
      };

  bool get isPriceRising => changePercentage > 0;
  String get changeText => '${isPriceRising ? '+' : ''}${changePercentage.toStringAsFixed(1)}%';
}