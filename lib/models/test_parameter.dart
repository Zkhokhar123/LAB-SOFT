class TestParameter {
  final String name;
  final String unit;
  final double minValue;
  final double maxValue;

  const TestParameter({
    required this.name,
    this.unit = '-',
    this.minValue = 0,
    this.maxValue = 0,
  });

  factory TestParameter.fromJson(Map<String, dynamic> json) {
    return TestParameter(
      name: json['name'],
      unit: json['unit'] ?? '-',
      minValue: json['minValue']?.toDouble() ?? 0,
      maxValue: json['maxValue']?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit,
      'minValue': minValue,
      'maxValue': maxValue,
    };
  }
}
