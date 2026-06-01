import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/patient.dart';
import '../models/lab_test.dart';
import '../models/doctor.dart';
import '../models/lab_result.dart';
import '../models/test_parameter.dart';

class LabController extends ChangeNotifier {
  // Core Data
  List<Patient> _patients = [];
  List<Doctor> _doctors = [
    const Doctor(name: 'Self', commissionPercentage: 0),
    const Doctor(name: 'Dr. Sarah Khan', commissionPercentage: 20),
    const Doctor(name: 'Dr. Ahmed', commissionPercentage: 15),
  ];
  
  List<LabTest> _availableTests = [
    const LabTest(
      code: 'CBC', 
      name: 'Complete Blood Count', 
      price: 800, 
      category: 'Hematology',
      parameters: [
        TestParameter(name: 'Hemoglobin', unit: 'g/dL', minValue: 13.0, maxValue: 17.0),
        TestParameter(name: 'Packed Cell Volume (PCV)', unit: '%', minValue: 40.0, maxValue: 50.0),
        TestParameter(name: 'RBC Count', unit: 'mill/mm3', minValue: 4.5, maxValue: 5.5),
        TestParameter(name: 'MCV', unit: 'fL', minValue: 80.0, maxValue: 100.0),
        TestParameter(name: 'MCH', unit: 'pg', minValue: 27.0, maxValue: 32.0),
        TestParameter(name: 'MCHC', unit: 'g/dL', minValue: 32.0, maxValue: 35.0),
        TestParameter(name: 'Red Cell Distribution Width (RDW)', unit: '%', minValue: 11.5, maxValue: 14.5),
        TestParameter(name: 'Total Leukocyte Count (TLC)', unit: 'thou/mm3', minValue: 4.0, maxValue: 10.0),
        TestParameter(name: 'Segmented Neutrophils', unit: '%', minValue: 40.0, maxValue: 80.0),
        TestParameter(name: 'Lymphocytes', unit: '%', minValue: 20.0, maxValue: 40.0),
        TestParameter(name: 'Monocytes', unit: '%', minValue: 2.0, maxValue: 10.0),
        TestParameter(name: 'Eosinophils', unit: '%', minValue: 1.0, maxValue: 6.0),
        TestParameter(name: 'Basophils', unit: '%', minValue: 0, maxValue: 2.0),
        TestParameter(name: 'Abs. Neutrophils', unit: 'thou/mm3', minValue: 2.0, maxValue: 7.0),
        TestParameter(name: 'Abs. Lymphocytes', unit: 'thou/mm3', minValue: 1.0, maxValue: 3.0),
        TestParameter(name: 'Abs. Monocytes', unit: 'thou/mm3', minValue: 0.2, maxValue: 1.0),
        TestParameter(name: 'Abs. Eosinophils', unit: 'thou/mm3', minValue: 0.02, maxValue: 0.5),
        TestParameter(name: 'Abs. Basophils', unit: 'thou/mm3', minValue: 0.01, maxValue: 0.1),
        TestParameter(name: 'Platelet Count', unit: 'thou/mm3', minValue: 150.0, maxValue: 450.0),
      ]
    ),
    const LabTest(
      code: 'LFT', 
      name: 'Liver Function Test', 
      price: 1500, 
      category: 'Biochemistry',
      parameters: [
        TestParameter(name: 'Bilirubin Total', unit: 'mg/dL', minValue: 0.1, maxValue: 1.2),
        TestParameter(name: 'Bilirubin Direct', unit: 'mg/dL', minValue: 0.0, maxValue: 0.3),
        TestParameter(name: 'Bilirubin Indirect', unit: 'mg/dL', minValue: 0.1, maxValue: 1.0),
        TestParameter(name: 'SGPT (ALT)', unit: 'U/L', minValue: 5.0, maxValue: 40.0),
        TestParameter(name: 'SGOT (AST)', unit: 'U/L', minValue: 5.0, maxValue: 40.0),
        TestParameter(name: 'Alkaline Phosphatase (ALP)', unit: 'U/L', minValue: 40.0, maxValue: 129.0),
        TestParameter(name: 'Total Protein', unit: 'g/dL', minValue: 6.0, maxValue: 8.0),
        TestParameter(name: 'Albumin', unit: 'g/dL', minValue: 3.5, maxValue: 5.0),
        TestParameter(name: 'Globulin', unit: 'g/dL', minValue: 2.0, maxValue: 3.5),
        TestParameter(name: 'A/G Ratio', unit: 'Ratio', minValue: 1.0, maxValue: 2.0),
      ]
    ),
    const LabTest(
      code: 'RFT', 
      name: 'Renal Function Test', 
      price: 1200, 
      category: 'Biochemistry',
      parameters: [
        TestParameter(name: 'Blood Urea', unit: 'mg/dL', minValue: 15.0, maxValue: 45.0),
        TestParameter(name: 'Serum Creatinine', unit: 'mg/dL', minValue: 0.6, maxValue: 1.2),
        TestParameter(name: 'Serum Uric Acid', unit: 'mg/dL', minValue: 3.0, maxValue: 7.0),
        TestParameter(name: 'Serum Sodium', unit: 'mEq/L', minValue: 135.0, maxValue: 145.0),
        TestParameter(name: 'Serum Potassium', unit: 'mEq/L', minValue: 3.5, maxValue: 5.0),
        TestParameter(name: 'Serum Chloride', unit: 'mEq/L', minValue: 95.0, maxValue: 105.0),
      ]
    ),
    const LabTest(
      code: 'BSL', 
      name: 'Blood Sugar Level', 
      price: 200, 
      category: 'Biochemistry',
      parameters: [
        TestParameter(name: 'Blood Sugar Fasting', unit: 'mg/dL', minValue: 70.0, maxValue: 100.0),
        TestParameter(name: 'Blood Sugar Random', unit: 'mg/dL', minValue: 70.0, maxValue: 140.0),
        TestParameter(name: 'Blood Sugar 2 Hours PP', unit: 'mg/dL', minValue: 70.0, maxValue: 140.0),
      ]
    ),
  ];

  List<String> _categories = ['Biochemistry', 'Hematology', 'Serology', 'Hormones', 'Clinical Pathology', 'Microbiology'];

  // Lab Settings
  String _labName = 'ApniLab.pk';
  String _labAddress = '123 Medical Complex, City';
  String _labPhone = '0300-1234567';
  List<String> _branches = ['Main Branch', 'City Branch'];
  String _printerType = 'A4 / Laser';

  bool _isLoading = true;

  // Getters
  List<Patient> get patients => _patients;
  List<Doctor> get doctors => _doctors;
  List<LabTest> get availableTests => _availableTests;
  List<String> get categories => _categories;
  String get labName => _labName;
  String get labAddress => _labAddress;
  String get labPhone => _labPhone;
  List<String> get branches => _branches;
  String get printerType => _printerType;
  bool get isLoading => _isLoading;

  LabController() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Core Data
    final List<String> patientsJson = prefs.getStringList('patients') ?? [];
    _patients = patientsJson.map((json) => Patient.fromJson(json)).toList();
    
    final String? doctorsJson = prefs.getString('doctors');
    if (doctorsJson != null) {
      final List<dynamic> decoded = json.decode(doctorsJson);
      _doctors = decoded.map((d) => Doctor.fromMap(d)).toList();
    }

    final String? testsJson = prefs.getString('lab_tests');
    if (testsJson != null) {
      final List<dynamic> decoded = json.decode(testsJson);
      _availableTests = decoded.map((t) => LabTest.fromJson(t)).toList();

      // Database Migration: Upgrade existing LFT, RFT, BSL tests to detailed versions if they are currently single-valued/empty
      bool didMigrate = false;
      for (int i = 0; i < _availableTests.length; i++) {
        final test = _availableTests[i];
        if (test.code == 'LFT' && test.parameters.isEmpty) {
          _availableTests[i] = const LabTest(
            code: 'LFT',
            name: 'Liver Function Test',
            price: 1500,
            category: 'Biochemistry',
            parameters: [
              TestParameter(name: 'Bilirubin Total', unit: 'mg/dL', minValue: 0.1, maxValue: 1.2),
              TestParameter(name: 'Bilirubin Direct', unit: 'mg/dL', minValue: 0.0, maxValue: 0.3),
              TestParameter(name: 'Bilirubin Indirect', unit: 'mg/dL', minValue: 0.1, maxValue: 1.0),
              TestParameter(name: 'SGPT (ALT)', unit: 'U/L', minValue: 5.0, maxValue: 40.0),
              TestParameter(name: 'SGOT (AST)', unit: 'U/L', minValue: 5.0, maxValue: 40.0),
              TestParameter(name: 'Alkaline Phosphatase (ALP)', unit: 'U/L', minValue: 40.0, maxValue: 129.0),
              TestParameter(name: 'Total Protein', unit: 'g/dL', minValue: 6.0, maxValue: 8.0),
              TestParameter(name: 'Albumin', unit: 'g/dL', minValue: 3.5, maxValue: 5.0),
              TestParameter(name: 'Globulin', unit: 'g/dL', minValue: 2.0, maxValue: 3.5),
              TestParameter(name: 'A/G Ratio', unit: 'Ratio', minValue: 1.0, maxValue: 2.0),
            ],
          );
          didMigrate = true;
        } else if (test.code == 'RFT' && test.parameters.isEmpty) {
          _availableTests[i] = const LabTest(
            code: 'RFT',
            name: 'Renal Function Test',
            price: 1200,
            category: 'Biochemistry',
            parameters: [
              TestParameter(name: 'Blood Urea', unit: 'mg/dL', minValue: 15.0, maxValue: 45.0),
              TestParameter(name: 'Serum Creatinine', unit: 'mg/dL', minValue: 0.6, maxValue: 1.2),
              TestParameter(name: 'Serum Uric Acid', unit: 'mg/dL', minValue: 3.0, maxValue: 7.0),
              TestParameter(name: 'Serum Sodium', unit: 'mEq/L', minValue: 135.0, maxValue: 145.0),
              TestParameter(name: 'Serum Potassium', unit: 'mEq/L', minValue: 3.5, maxValue: 5.0),
              TestParameter(name: 'Serum Chloride', unit: 'mEq/L', minValue: 95.0, maxValue: 105.0),
            ],
          );
          didMigrate = true;
        } else if (test.code == 'BSL' && test.parameters.isEmpty) {
          _availableTests[i] = const LabTest(
            code: 'BSL',
            name: 'Blood Sugar Level',
            price: 200,
            category: 'Biochemistry',
            parameters: [
              TestParameter(name: 'Blood Sugar Fasting', unit: 'mg/dL', minValue: 70.0, maxValue: 100.0),
              TestParameter(name: 'Blood Sugar Random', unit: 'mg/dL', minValue: 70.0, maxValue: 140.0),
              TestParameter(name: 'Blood Sugar 2 Hours PP', unit: 'mg/dL', minValue: 70.0, maxValue: 140.0),
            ],
          );
          didMigrate = true;
        }
      }
      if (didMigrate) {
        _saveData();
      }
    }

    // Load Categories
    _categories = prefs.getStringList('categories') ?? ['Biochemistry', 'Hematology', 'Serology', 'Hormones', 'Clinical Pathology', 'Microbiology'];

    // Load Settings
    _labName = prefs.getString('lab_name') ?? 'SHAH-RUKN-ALAM CLINICAL LABORATORY';
    _labAddress = prefs.getString('lab_address') ?? 'RABBANI CHOWK MASOOM SHAH ROAD MULTAN';
    _labPhone = prefs.getString('lab_phone') ?? '0306-6898337';
    _branches = prefs.getStringList('branches') ?? ['Main Branch', 'City Branch'];
    _printerType = prefs.getString('printer_type') ?? 'A4 / Laser';

    _isLoading = false;
    notifyListeners();
  }

  Future<void> reloadFromStorage() async {
    _isLoading = true;
    notifyListeners();
    await _loadData();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save Core Data
    await prefs.setStringList('patients', _patients.map((p) => p.toJson()).toList());
    await prefs.setString('doctors', json.encode(_doctors.map((d) => d.toMap()).toList()));
    await prefs.setString('lab_tests', json.encode(_availableTests.map((t) => t.toJson()).toList()));
    await prefs.setStringList('categories', _categories);

    // Save Settings
    await prefs.setString('lab_name', _labName);
    await prefs.setString('lab_address', _labAddress);
    await prefs.setString('lab_phone', _labPhone);
    await prefs.setStringList('branches', _branches);
    await prefs.setString('printer_type', _printerType);

    notifyListeners();
  }

  // Categories
  void addCategory(String category) {
    if (!_categories.contains(category)) {
      _categories.add(category);
      _saveData();
    }
  }

  void removeCategory(String category) {
    _categories.remove(category);
    _saveData();
  }

  // Update Methods
  void updateLabInfo({String? name, String? address, String? phone}) {
    if (name != null) _labName = name;
    if (address != null) _labAddress = address;
    if (phone != null) _labPhone = phone;
    _saveData();
  }

  void addBranch(String branch) {
    if (!_branches.contains(branch)) {
      _branches.add(branch);
      _saveData();
    }
  }

  void removeBranch(String branch) {
    _branches.remove(branch);
    _saveData();
  }

  void updatePrinter(String type) {
    _printerType = type;
    _saveData();
  }

  // Lab Tests
  void addDoctor(Doctor doctor) {
    _doctors.add(doctor);
    _saveData();
  }

  void addLabTest(LabTest test) {
    _availableTests.add(test);
    _saveData();
  }

  void updateLabTest(LabTest updatedTest) {
    final index = _availableTests.indexWhere((t) => t.code == updatedTest.code);
    if (index != -1) {
      _availableTests[index] = updatedTest;
      _saveData();
    }
  }

  void removeLabTest(String code) {
    _availableTests.removeWhere((t) => t.code == code);
    _saveData();
  }

  void addPatient(Patient patient) {
    _patients.add(patient);
    _saveData();
  }

  void updatePatientStatus(String id, PatientStatus newStatus) {
    final index = _patients.indexWhere((p) => p.id == id);
    if (index != -1) {
      _patients[index] = _patients[index].copyWith(status: newStatus);
      _saveData();
    }
  }

  void savePatientResults(String id, List<LabResult> results) {
    final index = _patients.indexWhere((p) => p.id == id);
    if (index != -1) {
      _patients[index] = _patients[index].copyWith(
        results: results,
        status: PatientStatus.pendingApproval,
      );
      _saveData();
    }
  }

  void clearAll() {
    _patients.clear();
    _saveData();
  }

  // Stats
  int get patientsToday {
    final now = DateTime.now();
    return _patients.where((p) => p.date.year == now.year && p.date.month == now.month && p.date.day == now.day).length;
  }
  double get amountToday {
    final now = DateTime.now();
    return _patients.where((p) => p.date.year == now.year && p.date.month == now.month && p.date.day == now.day).fold(0, (sum, p) => sum + p.amount);
  }
  double get discountToday {
    final now = DateTime.now();
    return _patients.where((p) => p.date.year == now.year && p.date.month == now.month && p.date.day == now.day).fold(0, (sum, p) => sum + p.discount);
  }
  double get revenueToday => amountToday - discountToday;
  int get totalTestsToday => patientsToday;
  int get pendingSamples => _patients.where((p) => p.status == PatientStatus.pendingSample).length;
  int get pendingReports => _patients.where((p) => p.status == PatientStatus.pendingReport).length;
  int get approvedReports => _patients.where((p) => p.status == PatientStatus.approved).length;
}

final labController = LabController();
