class ConversionResultModel {
  final String originalValue;
  final String convertedValue;
  final String fromUnit;
  final String toUnit;
  final DateTime timestamp;
  final String type; // 'currency' or 'timezone'

  ConversionResultModel({
    required this.originalValue,
    required this.convertedValue,
    required this.fromUnit,
    required this.toUnit,
    required this.timestamp,
    required this.type,
  });

  factory ConversionResultModel.fromJson(Map<String, dynamic> json) {
    return ConversionResultModel(
      originalValue: json['originalValue'] ?? '',
      convertedValue: json['convertedValue'] ?? '',
      fromUnit: json['fromUnit'] ?? '',
      toUnit: json['toUnit'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalValue': originalValue,
      'convertedValue': convertedValue,
      'fromUnit': fromUnit,
      'toUnit': toUnit,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }

  String get formattedResult {
    return '$originalValue $fromUnit = $convertedValue $toUnit';
  }

  String get formattedTimestamp {
    return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'ConversionResultModel(originalValue: $originalValue, convertedValue: $convertedValue, fromUnit: $fromUnit, toUnit: $toUnit, type: $type, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversionResultModel &&
        other.originalValue == originalValue &&
        other.convertedValue == convertedValue &&
        other.fromUnit == fromUnit &&
        other.toUnit == toUnit &&
        other.type == type;
  }

  @override
  int get hashCode {
    return originalValue.hashCode ^
        convertedValue.hashCode ^
        fromUnit.hashCode ^
        toUnit.hashCode ^
        type.hashCode;
  }
}