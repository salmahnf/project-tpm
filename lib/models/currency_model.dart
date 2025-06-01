class CurrencyModel {
  final String code;
  final String name;
  final String symbol;
  final double rate;

  CurrencyModel({
    required this.code,
    required this.name,
    required this.symbol,
    required this.rate,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) {
    return CurrencyModel(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      rate: (json['rate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
      'rate': rate,
    };
  }

  String get displayName => '$code - $name';

  @override
  String toString() {
    return 'CurrencyModel(code: $code, name: $name, symbol: $symbol, rate: $rate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrencyModel && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}