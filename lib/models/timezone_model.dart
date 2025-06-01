class TimezoneModel {
  final String id;
  final String name;
  final String abbreviation;
  final int offsetHours;
  final int offsetMinutes;

  TimezoneModel({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.offsetHours,
    this.offsetMinutes = 0,
  });

  factory TimezoneModel.fromJson(Map<String, dynamic> json) {
    return TimezoneModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      abbreviation: json['abbreviation'] ?? '',
      offsetHours: json['offsetHours'] ?? 0,
      offsetMinutes: json['offsetMinutes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'abbreviation': abbreviation,
      'offsetHours': offsetHours,
      'offsetMinutes': offsetMinutes,
    };
  }

  String get displayName => '$name ($abbreviation)';

  String get offsetString {
    String sign = offsetHours >= 0 ? '+' : '-';
    int absHours = offsetHours.abs();
    if (offsetMinutes == 0) {
      return 'UTC$sign${absHours.toString().padLeft(2, '0')}:00';
    } else {
      return 'UTC$sign${absHours.toString().padLeft(2, '0')}:${offsetMinutes.toString().padLeft(2, '0')}';
    }
  }

  DateTime convertFromUTC(DateTime utcDateTime) {
    return utcDateTime.add(Duration(hours: offsetHours, minutes: offsetMinutes));
  }

  DateTime convertToUTC(DateTime localDateTime) {
    return localDateTime.subtract(Duration(hours: offsetHours, minutes: offsetMinutes));
  }

  @override
  String toString() {
    return 'TimezoneModel(id: $id, name: $name, abbreviation: $abbreviation, offset: $offsetString)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimezoneModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}