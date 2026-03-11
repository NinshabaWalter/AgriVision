class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? location;
  final String? farmSize;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.location,
    this.farmSize,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _parseId(json['id']),
      name: _parseRequiredString(json['name']),
      email: _parseRequiredString(json['email']),
      phone: _parseString(json['phone']),
      location: _parseString(json['location']),
      farmSize: _parseString(json['farm_size']),
    );
  }

  static int _parseId(dynamic id) {
    if (id == null) return 0;
    if (id is int) return id;
    if (id is String) {
      return int.tryParse(id) ?? 0;
    }
    return 0;
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is num) return value.toString();
    return value.toString();
  }

  static String _parseRequiredString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is num) return value.toString();
    return value.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'farm_size': farmSize,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? location,
    String? farmSize,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      farmSize: farmSize ?? this.farmSize,
    );
  }
}