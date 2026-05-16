import 'package:flutter/material.dart';
import '../controllers/lab_controller.dart';
import '../models/patient.dart';
import '../models/doctor.dart';

class DoctorCommissionView extends StatefulWidget {
  const DoctorCommissionView({super.key});

  @override
  State<DoctorCommissionView> createState() => _DoctorCommissionViewState();
}

class _DoctorCommissionViewState extends State<DoctorCommissionView> {
  void _showAddDoctorDialog() {
    final nameController = TextEditingController();
    final commissionController = TextEditingController(text: '20');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Doctor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Doctor Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commissionController,
              decoration: const InputDecoration(labelText: 'Commission Percentage (%)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newDoctor = Doctor(
                  name: nameController.text,
                  commissionPercentage: double.tryParse(commissionController.text) ?? 20.0,
                );
                labController.addDoctor(newDoctor);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Doctor Added Successfully!')),
                );
              }
            },
            child: const Text('Save Doctor'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: labController,
      builder: (context, _) {
        // Group data by doctor
        final Map<String, List<Patient>> doctorGroups = {};
        for (var p in labController.patients) {
          doctorGroups.putIfAbsent(p.doctorName, () => []).add(p);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Doctor Wise Reports & Commission', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    onPressed: _showAddDoctorDialog,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add New Doctor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Summary Cards
              Row(
                children: [
                  _buildSummaryCard('Total Doctors', '${labController.doctors.length}', Colors.blue),
                  const SizedBox(width: 16),
                  _buildSummaryCard('Doctor Referred', '${labController.patients.where((p) => p.doctorName != "Self").length}', Colors.green),
                  const SizedBox(width: 16),
                  _buildSummaryCard('Self Referred', '${labController.patients.where((p) => p.doctorName == "Self").length}', Colors.orange),
                ],
              ),
              const SizedBox(height: 32),

              // Detailed Table
              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Commission Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                      const Divider(),
                      SizedBox(
                        width: double.infinity,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                          columns: const [
                            DataColumn(label: Text('Doctor Name')),
                            DataColumn(label: Text('Total Tests')),
                            DataColumn(label: Text('Total Amount')),
                            DataColumn(label: Text('Comm. %')),
                            DataColumn(label: Text('Commission (Rs)')),
                            DataColumn(label: Text('Action')),
                          ],
                          rows: labController.doctors.map((doctor) {
                            final patients = doctorGroups[doctor.name] ?? [];
                            final totalAmount = patients.fold(0.0, (sum, p) => sum + p.amount);
                            final commission = totalAmount * (doctor.commissionPercentage / 100);
                            
                            return DataRow(cells: [
                              DataCell(Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text('${patients.length}')),
                              DataCell(Text('Rs $totalAmount')),
                              DataCell(Text('${doctor.commissionPercentage}%')),
                              DataCell(Text('Rs ${commission.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                              DataCell(ElevatedButton(
                                onPressed: () {
                                  _showDoctorDetails(context, doctor.name, patients);
                                },
                                child: const Text('View Patients'),
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDoctorDetails(BuildContext context, String doctor, List<Patient> patients) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tests referred by $doctor'),
        content: SizedBox(
          width: 600,
          child: patients.isEmpty 
            ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No patients found for this doctor.')))
            : DataTable(
                columns: const [
                  DataColumn(label: Text('Patient Name')),
                  DataColumn(label: Text('Tests')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Amount')),
                ],
                rows: patients.map((p) => DataRow(cells: [
                  DataCell(Text(p.name)),
                  DataCell(Text(p.testName)),
                  DataCell(Text('${p.date.day}/${p.date.month}/${p.date.year}')),
                  DataCell(Text('Rs ${p.amount}')),
                ])).toList(),
              ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
