class LabResult {
  final String testName;
  final String resultValue;
  final String unit;
  final String referenceRange;

  const LabResult({
    required this.testName,
    required this.resultValue,
    required this.unit,
    required this.referenceRange,
  });

  factory LabResult.fromMap(Map<String, dynamic> map) {
    return LabResult(
      testName: map['testName'],
      resultValue: map['resultValue'],
      unit: map['unit'],
      referenceRange: map['referenceRange'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'testName': testName,
      'resultValue': resultValue,
      'unit': unit,
      'referenceRange': referenceRange,
    };
  }
}
