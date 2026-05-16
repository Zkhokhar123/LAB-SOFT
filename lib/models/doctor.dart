class Doctor {
  final String name;
  final double commissionPercentage;

  const Doctor({
    required this.name,
    this.commissionPercentage = 20.0,
  });

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      name: map['name'],
      commissionPercentage: map['commissionPercentage'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'commissionPercentage': commissionPercentage,
    };
  }
}
