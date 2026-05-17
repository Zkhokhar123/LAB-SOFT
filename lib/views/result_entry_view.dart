import 'package:flutter/material.dart';
import '../controllers/lab_controller.dart';
import '../models/patient.dart';
import '../models/lab_result.dart';
import '../models/lab_test.dart';

class ResultEntryView extends StatefulWidget {
  const ResultEntryView({super.key});

  @override
  State<ResultEntryView> createState() => _ResultEntryViewState();
}

class _ResultEntryViewState extends State<ResultEntryView> {
  Patient? _selectedPatient;
  final Map<String, TextEditingController> _resultControllers = {};

  void _selectPatient(Patient patient) {
    setState(() {
      _selectedPatient = patient;
      _resultControllers.clear();
      
      final testCodes = patient.testName.split(', ');
      for (var code in testCodes) {
        final test = labController.availableTests.firstWhere((t) => t.code == code.trim(), orElse: () => LabTest(code: code, name: code, price: 0, category: ''));
        
        if (test.parameters.isNotEmpty) {
          for (var param in test.parameters) {
            _resultControllers['${test.code}_${param.name}'] = TextEditingController();
          }
        } else {
          _resultControllers[test.code] = TextEditingController();
        }
      }
    });
  }

  void _saveResults() {
    if (_selectedPatient == null) return;

    final List<LabResult> results = [];
    
    final testCodes = _selectedPatient!.testName.split(', ');
    for (var code in testCodes) {
      final test = labController.availableTests.firstWhere((t) => t.code == code.trim(), orElse: () => LabTest(code: code, name: code, price: 0, category: ''));
      
      if (test.parameters.isNotEmpty) {
        for (var param in test.parameters) {
          results.add(LabResult(
            testName: '${test.code} - ${param.name}',
            resultValue: _resultControllers['${test.code}_${param.name}']?.text ?? '',
            unit: param.unit,
            referenceRange: '${param.minValue} - ${param.maxValue}',
          ));
        }
      } else {
        results.add(LabResult(
          testName: test.name,
          resultValue: _resultControllers[test.code]?.text ?? '',
          unit: test.unit,
          referenceRange: '${test.minValue} - ${test.maxValue}',
        ));
      }
    }

    labController.savePatientResults(_selectedPatient!.id, results);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Results Saved & Awaiting Final Approval!'), backgroundColor: Colors.orange));
    setState(() => _selectedPatient = null);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: labController,
      builder: (context, _) {
        final pendingPatients = labController.patients
            .where((p) => p.status == PatientStatus.pendingReport || p.status == PatientStatus.pendingSample)
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Result Entry & Verification', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left List
                  Expanded(
                    flex: 1,
                    child: Card(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(padding: EdgeInsets.all(16.0), child: Text('Pending Patients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue))),
                          const Divider(height: 1),
                          ListView.separated(
                            shrinkWrap: true,
                            itemCount: pendingPatients.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final p = pendingPatients[index];
                              return ListTile(
                                selected: _selectedPatient?.id == p.id,
                                selectedTileColor: Colors.blue[50],
                                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('ID: ${p.id.substring(p.id.length - 5)} | ${p.testName}'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _selectPatient(p),
                              );
                            },
                          ),
                          if (pendingPatients.isEmpty) const Padding(padding: EdgeInsets.all(32.0), child: Center(child: Text('No pending reports'))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),

                  // Right Entry Form
                  Expanded(
                    flex: 2,
                    child: _selectedPatient == null
                        ? const Card(color: Colors.white, child: SizedBox(height: 300, child: Center(child: Text('Select a patient from the list to enter results'))))
                        : Card(
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(_selectedPatient!.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                          Text('Ref by: ${_selectedPatient!.doctorName}', style: TextStyle(color: Colors.grey[600])),
                                        ],
                                      ),
                                      const Chip(label: Text('Reporting Stage'), backgroundColor: Colors.orangeAccent),
                                    ],
                                  ),
                                  const Divider(height: 32),
                                  const Row(
                                    children: [
                                      Expanded(flex: 3, child: Text('Test Detail / Parameter', style: TextStyle(fontWeight: FontWeight.bold))),
                                      Expanded(flex: 2, child: Text('Result', style: TextStyle(fontWeight: FontWeight.bold))),
                                      Expanded(flex: 1, child: Text('Unit', style: TextStyle(fontWeight: FontWeight.bold))),
                                      Expanded(flex: 2, child: Text('Normal Range', style: TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  ..._selectedPatient!.testName.split(', ').expand((code) {
                                    final test = labController.availableTests.firstWhere((t) => t.code == code.trim(), orElse: () => LabTest(code: code, name: code, price: 0, category: ''));
                                    
                                    if (test.parameters.isNotEmpty) {
                                      return test.parameters.map((p) => _buildResultRow('${test.code}_${p.name}', p.name, p.unit, '${p.minValue} - ${p.maxValue}'));
                                    } else {
                                      return [_buildResultRow(test.code, test.name, test.unit, '${test.minValue} - ${test.maxValue}')];
                                    }
                                  }),

                                  const SizedBox(height: 32),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(onPressed: () => setState(() => _selectedPatient = null), child: const Text('Cancel')),
                                      const SizedBox(width: 16),
                                      ElevatedButton.icon(
                                        onPressed: _saveResults,
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                                        icon: const Icon(Icons.check_circle),
                                        label: const Text('Save & Authorize', style: TextStyle(fontSize: 16)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultRow(String key, String label, String unit, String range) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(label)),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _resultControllers[key],
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
            ),
          ),
          Expanded(flex: 1, child: Padding(padding: const EdgeInsets.only(left: 8), child: Text(unit))),
          Expanded(flex: 2, child: Text(range, style: TextStyle(color: Colors.grey[600]))),
        ],
      ),
    );
  }
}
