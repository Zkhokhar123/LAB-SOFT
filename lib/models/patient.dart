import 'dart:convert';
import 'lab_result.dart';

enum PatientStatus { pendingSample, pendingReport, approved, pendingApproval }

class Patient {
  final String id;
  final String name;
  final String testName;
  final double amount;
  final double discount;
  final PatientStatus status;
  final DateTime date;
  final String doctorName;
  final List<LabResult> results;

  Patient({
    required this.id,
    required this.name,
    required this.testName,
    required this.amount,
    required this.discount,
    required this.status,
    required this.date,
    this.doctorName = 'Self',
    this.results = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'testName': testName,
      'amount': amount,
      'discount': discount,
      'status': status.index,
      'date': date.toIso8601String(),
      'doctorName': doctorName,
      'results': results.map((x) => x.toMap()).toList(),
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      testName: map['testName'],
      amount: map['amount'],
      discount: map['discount'] ?? 0.0,
      status: PatientStatus.values[map['status']],
      date: DateTime.parse(map['date']),
      doctorName: map['doctorName'] ?? 'Self',
      results: map['results'] != null 
          ? List<LabResult>.from(map['results']?.map((x) => LabResult.fromMap(x)))
          : const [],
    );
  }

  String toJson() => json.encode(toMap());

  factory Patient.fromJson(String source) => Patient.fromMap(json.decode(source));

  Patient copyWith({
    String? id,
    String? name,
    String? testName,
    double? amount,
    double? discount,
    PatientStatus? status,
    DateTime? date,
    String? doctorName,
    List<LabResult>? results,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      testName: testName ?? this.testName,
      amount: amount ?? this.amount,
      discount: discount ?? this.discount,
      status: status ?? this.status,
      date: date ?? this.date,
      doctorName: doctorName ?? this.doctorName,
      results: results ?? this.results,
    );
  }
}
