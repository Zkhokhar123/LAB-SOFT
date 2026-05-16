import 'test_parameter.dart';

class LabTest {
  final String code;
  final String name;
  final double price;
  final String category;
  final String reportingTime; 
  final String unit;
  final double minValue;
  final double maxValue;
  final List<TestParameter> parameters;

  const LabTest({
    required this.code,
    required this.name,
    required this.price,
    required this.category,
    this.reportingTime = 'Same Day',
    this.unit = '-',
    this.minValue = 0,
    this.maxValue = 0,
    this.parameters = const [],
  });

  factory LabTest.fromJson(Map<String, dynamic> json) {
    return LabTest(
      code: json['code'],
      name: json['name'],
      price: json['price'].toDouble(),
      category: json['category'],
      reportingTime: json['reportingTime'] ?? 'Same Day',
      unit: json['unit'] ?? '-',
      minValue: json['minValue']?.toDouble() ?? 0,
      maxValue: json['maxValue']?.toDouble() ?? 0,
      parameters: json['parameters'] != null 
          ? List<TestParameter>.from(json['parameters']?.map((x) => TestParameter.fromJson(x)))
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'price': price,
      'category': category,
      'reportingTime': reportingTime,
      'unit': unit,
      'minValue': minValue,
      'maxValue': maxValue,
      'parameters': parameters.map((x) => x.toJson()).toList(),
    };
  }
}
