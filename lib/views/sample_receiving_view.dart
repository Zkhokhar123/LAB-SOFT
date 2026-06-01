import 'package:flutter/material.dart';
import '../controllers/lab_controller.dart';
import '../models/patient.dart';
import '../models/lab_test.dart';

class SampleReceivingView extends StatefulWidget {
  const SampleReceivingView({super.key});

  @override
  State<SampleReceivingView> createState() => _SampleReceivingViewState();
}

class _SampleReceivingViewState extends State<SampleReceivingView> {
  bool _showFilters = true;

  // Filter State
  String _caseNoFilter = '';
  String _nameFilter = '';
  String _mobileFilter = '';
  String _doctorFilter = 'All';

  // Selection state for bulk actions
  final Set<String> _selectedPatientIds = {};

  void _confirmReceipt(String patientId, String name) {
    labController.updatePatientStatus(patientId, PatientStatus.pendingReport);
    setState(() {
      _selectedPatientIds.remove(patientId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sample received successfully for $name!'),
        backgroundColor: Colors.green[800],
      ),
    );
  }

  void _confirmBulkReceipt() {
    if (_selectedPatientIds.isEmpty) return;

    for (var id in _selectedPatientIds) {
      labController.updatePatientStatus(id, PatientStatus.pendingReport);
    }

    final count = _selectedPatientIds.length;
    setState(() {
      _selectedPatientIds.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bulk receipt confirmed for $count patient samples!'),
        backgroundColor: Colors.green[800],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: labController,
      builder: (context, _) {
        // Filter patients who are pending sample collection
        final pendingPatients = labController.patients.where((p) {
          if (p.status != PatientStatus.pendingSample) return false;

          // Case No filter
          if (_caseNoFilter.isNotEmpty && 
              !p.id.toLowerCase().contains(_caseNoFilter.toLowerCase())) {
            return false;
          }

          // Patient Name filter
          if (_nameFilter.isNotEmpty && 
              !p.name.toLowerCase().contains(_nameFilter.toLowerCase())) {
            return false;
          }

          // Mobile filter
          if (_mobileFilter.isNotEmpty && 
              !p.mobile.contains(_mobileFilter)) {
            return false;
          }

          // Doctor filter
          if (_doctorFilter != 'All' && 
              p.doctorName != _doctorFilter) {
            return false;
          }

          return true;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sample Receiving', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      if (_selectedPatientIds.isNotEmpty) ...[
                        ElevatedButton.icon(
                          onPressed: _confirmBulkReceipt,
                          icon: const Icon(Icons.done_all),
                          label: Text('Receive Checked (${_selectedPatientIds.length})'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      IconButton(
                        icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
                        onPressed: () => setState(() => _showFilters = !_showFilters),
                        tooltip: 'Toggle Filters',
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),
              
              if (_showFilters) ...[
                // Filter Panel Card
                Card(
                  color: Colors.white,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField('Case No', (val) {
                                setState(() => _caseNoFilter = val);
                              }),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTextField('Patient Name', (val) {
                                setState(() => _nameFilter = val);
                              }),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTextField('Mobile No.', (val) {
                                setState(() => _mobileFilter = val);
                              }),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildDoctorDropdown((val) {
                                setState(() => _doctorFilter = val ?? 'All');
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${pendingPatients.length} pending samples matching filters',
                              style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _caseNoFilter = '';
                                  _nameFilter = '';
                                  _mobileFilter = '';
                                  _doctorFilter = 'All';
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset Filters'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Patient List Table
              Card(
                color: Colors.white,
                elevation: 2,
                child: SizedBox(
                  width: double.infinity,
                  child: pendingPatients.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(48.0),
                          child: Center(
                            child: Text(
                              'No pending samples at the moment.',
                              style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      : DataTable(
                          headingRowColor: WidgetStateProperty.all(Colors.blue[900]),
                          headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          columns: const [
                            DataColumn(label: Text('Select')),
                            DataColumn(label: Text('Case No')),
                            DataColumn(label: Text('Patient Name')),
                            DataColumn(label: Text('Age/Sex')),
                            DataColumn(label: Text('Reg. Date/Time')),
                            DataColumn(label: Text('Doctor')),
                            DataColumn(label: Text('Tests')),
                          ],
                          rows: pendingPatients.map((p) => _buildPatientRow(p)).toList(),
                        ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  DataRow _buildPatientRow(Patient p) {
    final ageSex = '${p.age} Y / ${p.gender.isNotEmpty ? p.gender[0] : 'M'}';
    final dateStr = '${p.date.day}/${p.date.month}/${p.date.year} ${p.date.hour.toString().padLeft(2, '0')}:${p.date.minute.toString().padLeft(2, '0')}';
    final testCodes = p.testName.split(', ');
    final isSelected = _selectedPatientIds.contains(p.id);

    return DataRow(
      selected: isSelected,
      cells: [
        DataCell(
          Checkbox(
            value: isSelected, 
            onChanged: (v) {
              setState(() {
                if (v == true) {
                  _selectedPatientIds.add(p.id);
                } else {
                  _selectedPatientIds.remove(p.id);
                }
              });
            },
          ),
        ),
        DataCell(Text(p.id.substring(p.id.length - 5).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(ageSex)),
        DataCell(Text(dateStr)),
        DataCell(Text(p.doctorName)),
        DataCell(
          ActionChip(
            label: Text('${testCodes.length} Tests 🧪', style: TextStyle(color: Colors.blue[900])),
            backgroundColor: Colors.blue[50],
            onPressed: () {
              _showTestDetailsDialog(p);
            },
          ),
        ),
      ],
    );
  }

  void _showTestDetailsDialog(Patient p) {
    final testCodes = p.testName.split(', ');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tests for ${p.name} (Ref: ${p.id.substring(p.id.length - 5).toUpperCase()})'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Age/Gender: ${p.age} Y / ${p.gender}', style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('Referred By: ${p.doctorName}', style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),
              const Text('Assigned tests for which samples are being collected:', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const Divider(),
              Flexible(
                child: SingleChildScrollView(
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Code')),
                      DataColumn(label: Text('Test Name')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: testCodes.map((code) {
                      final matchingTest = labController.availableTests.firstWhere(
                        (t) => t.code == code,
                        orElse: () => LabTest(code: code, name: 'General Panel', price: 0, category: ''),
                      );
                      return DataRow(cells: [
                        DataCell(Text(matchingTest.code, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(matchingTest.name)),
                        DataCell(
                          Row(
                            children: const [
                              Icon(Icons.hourglass_bottom, size: 16, color: Colors.orange),
                              SizedBox(width: 4),
                              Text('Pending', style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _confirmReceipt(p.id, p.name);
            },
            icon: const Icon(Icons.check),
            label: const Text('Confirm Receipt & Collect'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[800], foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDoctorDropdown(Function(String?) onChanged) {
    final doctorsList = ['All', ...labController.doctors.map((e) => e.name)];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: _doctorFilter,
        decoration: const InputDecoration(
          labelText: 'Doctor',
          isDense: true,
          border: OutlineInputBorder(),
        ),
        items: doctorsList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
