import 'package:flutter/material.dart';
import '../controllers/lab_controller.dart';
import '../models/patient.dart';

class TestApproveView extends StatefulWidget {
  const TestApproveView({super.key});

  @override
  State<TestApproveView> createState() => _TestApproveViewState();
}

class _TestApproveViewState extends State<TestApproveView> {
  String _searchQuery = '';
  String _statusFilter = 'Pending Approval';



  // Automatic Range Clinical Flagger
  String _determineFlag(String valueStr, String rangeStr) {
    final cleanVal = valueStr.trim();
    final val = double.tryParse(cleanVal);
    if (val == null) return '';

    final parts = rangeStr.split('-');
    if (parts.length != 2) return '';

    final minVal = double.tryParse(parts[0].trim());
    final maxVal = double.tryParse(parts[1].trim());

    if (minVal == null || maxVal == null) return '';

    if (val < minVal) return 'LOW';
    if (val > maxVal) return 'HIGH';

    return 'NORMAL';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: labController,
      builder: (context, _) {
        // Filter patients list
        final filteredPatients = labController.patients.where((p) {
          // Search filter
          final matchQuery = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.doctorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.testName.toLowerCase().contains(_searchQuery.toLowerCase());

          if (!matchQuery) return false;

          // Status filter
          if (_statusFilter == 'Pending Approval') {
            return p.status == PatientStatus.pendingApproval;
          } else if (_statusFilter == 'Approved') {
            return p.status == PatientStatus.approved;
          } else if (_statusFilter == 'Pending Report') {
            return p.status == PatientStatus.pendingReport;
          } else if (_statusFilter == 'Pending Sample') {
            return p.status == PatientStatus.pendingSample;
          }
          return true; // "Show All"
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Test Verification & Approval', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Review, approve, and print patient test result slips.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),

              // Filter Controls Card
              Card(
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      // Search box
                      Expanded(
                        flex: 2,
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Search Patient Case No/Name/Test...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Status Dropdown
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          initialValue: _statusFilter,
                          decoration: const InputDecoration(
                            labelText: 'Approval Status Filter',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Pending Approval', child: Text('Pending Approval ⏳')),
                            DropdownMenuItem(value: 'Approved', child: Text('Approved Reports ✅')),
                            DropdownMenuItem(value: 'Pending Report', child: Text('Pending Results 📝')),
                            DropdownMenuItem(value: 'Pending Sample', child: Text('Pending Sample 🧪')),
                            DropdownMenuItem(value: 'Show All', child: Text('Show All Patients 👥')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _statusFilter = val;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Data Table Card
              Card(
                color: Colors.white,
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_statusFilter - List (${filteredPatients.length} Found)',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                          ),
                          if (_statusFilter == 'Pending Approval' && filteredPatients.isNotEmpty)
                            ElevatedButton.icon(
                              onPressed: () {
                                for (var p in filteredPatients) {
                                  labController.updatePatientStatus(p.id, PatientStatus.approved);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('All pending reports approved successfully!'), backgroundColor: Colors.green),
                                );
                              },
                              icon: const Icon(Icons.done_all),
                              label: const Text('Approve All'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], foregroundColor: Colors.white),
                            ),
                        ],
                      ),
                      const Divider(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: filteredPatients.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 48.0),
                                  child: Text(
                                    'No patients match the filter criteria.',
                                    style: TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                ),
                              )
                            : DataTable(
                                headingRowColor: WidgetStateProperty.all(Colors.blue[900]!.withAlpha(8)),
                                columns: const [
                                  DataColumn(label: Text('Case ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Patient Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Referred Doctor', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Test Requested', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: filteredPatients.map((p) => _buildPatientRow(p)).toList(),
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

  DataRow _buildPatientRow(Patient p) {
    Color chipColor = Colors.grey[200]!;
    Color textColor = Colors.black87;
    String label = p.status.name;

    if (p.status == PatientStatus.pendingApproval) {
      chipColor = Colors.amber[100]!;
      textColor = Colors.orange[900]!;
      label = 'Awaiting Verification';
    } else if (p.status == PatientStatus.approved) {
      chipColor = Colors.green[100]!;
      textColor = Colors.green[900]!;
      label = 'Approved ✅';
    } else if (p.status == PatientStatus.pendingReport) {
      chipColor = Colors.blue[100]!;
      textColor = Colors.blue[900]!;
      label = 'Pending Results';
    } else if (p.status == PatientStatus.pendingSample) {
      chipColor = Colors.purple[100]!;
      textColor = Colors.purple[900]!;
      label = 'Pending Sample';
    }

    final hasResults = p.results.isNotEmpty;

    return DataRow(cells: [
      DataCell(Text(p.id.substring(p.id.length - 5).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600))),
      DataCell(Text(p.doctorName)),
      DataCell(Text(p.testName, style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.w500))),
      DataCell(Chip(
        label: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12)),
        backgroundColor: chipColor,
      )),
      DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Review/Verify Button
            IconButton(
              icon: const Icon(Icons.fact_check, color: Colors.indigo),
              tooltip: 'Review Test Results',
              onPressed: hasResults ? () => _showReviewDialog(p) : null,
            ),
            // Approve Button
            if (p.status == PatientStatus.pendingApproval)
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                tooltip: 'Approve & Release Report',
                onPressed: () {
                  labController.updatePatientStatus(p.id, PatientStatus.approved);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Report of ${p.name} Approved successfully!'), backgroundColor: Colors.green),
                  );
                },
              ),
            // Print Button
            IconButton(
              icon: const Icon(Icons.print, color: Colors.teal),
              tooltip: 'Print Result Slip',
              onPressed: hasResults ? () => _printResultSlip(p) : null,
            ),
          ],
        ),
      ),
    ]);
  }

  // --- Verification Review Dialog ---
  void _showReviewDialog(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Verify Results: ${patient.name}'),
            Chip(label: Text('Ref: ${patient.doctorName}', style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        content: SizedBox(
          width: 700,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Mini Grid Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Case ID: ${patient.id.substring(patient.id.length - 5).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Tests: ${patient.testName}', style: TextStyle(color: Colors.indigo[900], fontWeight: FontWeight.bold)),
                    Text('Date: ${patient.date.day}/${patient.date.month}/${patient.date.year}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Parameter Table
              Expanded(
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                    columns: const [
                      DataColumn(label: Text('Parameter', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Observed Value', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Unit', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Reference Range', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Flag', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: patient.results.map((r) {
                      final flag = _determineFlag(r.resultValue, r.referenceRange);
                      Color flagColor = Colors.black;
                      String flagLabel = '';

                      if (flag == 'HIGH') {
                        flagColor = Colors.red[800]!;
                        flagLabel = '▲ High';
                      } else if (flag == 'LOW') {
                        flagColor = Colors.blue[800]!;
                        flagLabel = '▼ Low';
                      }

                      return DataRow(cells: [
                        DataCell(Text(r.testName)),
                        DataCell(Text(r.resultValue, style: TextStyle(fontWeight: FontWeight.bold, color: flagColor))),
                        DataCell(Text(r.unit)),
                        DataCell(Text(r.referenceRange)),
                        DataCell(Text(flagLabel, style: TextStyle(color: flagColor, fontWeight: FontWeight.bold))),
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
          if (patient.status == PatientStatus.pendingApproval)
            ElevatedButton.icon(
              onPressed: () {
                labController.updatePatientStatus(patient.id, PatientStatus.approved);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Report of ${patient.name} Verified & Approved!'), backgroundColor: Colors.green),
                );
              },
              icon: const Icon(Icons.verified),
              label: const Text('Verify & Approve'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], foregroundColor: Colors.white),
            ),
        ],
      ),
    );
  }

  // --- Professional A4 Laser Print Slip Preview Modal ---
  void _printResultSlip(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 850,
          height: double.infinity,
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              // Preview header control bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.print, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Patient Result Slip Print Preview - Status: ${patient.status == PatientStatus.approved ? "Approved ✅" : "Awaiting Approval ⏳"}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Approve first if it was pending
                          if (patient.status == PatientStatus.pendingApproval) {
                            labController.updatePatientStatus(patient.id, PatientStatus.approved);
                          }
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Report Slip sent to Laser Printer successfully!'), backgroundColor: Colors.teal),
                          );
                        },
                        icon: const Icon(Icons.print),
                        label: const Text('Confirm Print'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[800], foregroundColor: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),

              // A4 Clinical Document Preview Sheet
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Letterhead matching SHAH-RUKN-ALAM Clinical Laboratory
                        Center(
                          child: Column(
                            children: [
                              Text(
                                labController.labName.toUpperCase(),
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: 1.5),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'CLINICAL LABORATORY',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 1.2),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_on, size: 12, color: Colors.grey[800]),
                                  const SizedBox(width: 4),
                                  Text(
                                    labController.labAddress.toUpperCase(),
                                    style: TextStyle(fontSize: 10, color: Colors.grey[800], fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(thickness: 1.5, color: Colors.black),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Patient details box (Custom rectangular border matching the shared image)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Column: Patient Name & Age/Gender
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(color: Colors.black, fontSize: 13),
                                        children: [
                                          const TextSpan(text: "Patient's Name: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                          TextSpan(text: patient.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(color: Colors.black, fontSize: 13),
                                        children: [
                                          const TextSpan(text: "Age / Gender: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                          TextSpan(text: "${patient.age} Y / ${patient.gender.toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Right Column: Date & Referred Doctor
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(color: Colors.black, fontSize: 13),
                                        children: [
                                          const TextSpan(text: "Date : ", style: TextStyle(fontWeight: FontWeight.bold)),
                                          TextSpan(text: "${patient.date.day}/${patient.date.month}/${patient.date.year}", style: const TextStyle(fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(color: Colors.black, fontSize: 13),
                                        children: [
                                          const TextSpan(text: "REF BY: ", style: TextStyle(fontWeight: FontWeight.bold)),
                                          TextSpan(
                                            text: patient.doctorName.toUpperCase(),
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Shaded Parameters Header Bar (grey box CBE from photo)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            border: const Border(
                              top: BorderSide(color: Colors.grey, width: 1),
                              bottom: BorderSide(color: Colors.grey, width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 30,
                                child: Text(
                                  patient.testName.toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                                ),
                              ),
                              const Expanded(
                                flex: 15,
                                child: Text(
                                  'OBSERVED',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
                                ),
                              ),
                              const Expanded(
                                flex: 18,
                                child: Text(
                                  'UNIT',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
                                ),
                              ),
                              const Expanded(
                                flex: 25,
                                child: Text(
                                  'NORMAL VALUE',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // List of parameter results with clean table alignments (no borders inside)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: patient.results.length,
                          itemBuilder: (context, idx) {
                            final r = patient.results[idx];
                            final flag = _determineFlag(r.resultValue, r.referenceRange);
                            Color valColor = Colors.black;
                            FontWeight valWeight = FontWeight.normal;
                            String valueSuffix = '';

                            if (flag == 'HIGH') {
                              valColor = Colors.red[900]!;
                              valWeight = FontWeight.bold;
                              valueSuffix = ' (H)';
                            } else if (flag == 'LOW') {
                              valColor = Colors.blue[900]!;
                              valWeight = FontWeight.bold;
                              valueSuffix = ' (L)';
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              child: Row(
                                children: [
                                  // Parameter name
                                  Expanded(
                                    flex: 30,
                                    child: Text(
                                      r.testName,
                                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                                    ),
                                  ),
                                  // Observed value
                                  Expanded(
                                    flex: 15,
                                    child: Text(
                                      '${r.resultValue}$valueSuffix',
                                      style: TextStyle(fontSize: 13, color: valColor, fontWeight: valWeight),
                                    ),
                                  ),
                                  // Unit
                                  Expanded(
                                    flex: 18,
                                    child: Text(
                                      r.unit,
                                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                                    ),
                                  ),
                                  // Reference range / Normal range
                                  Expanded(
                                    flex: 25,
                                    child: Text(
                                      r.referenceRange,
                                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 60),

                        // Signatures & Authorization Area
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Technologist Signature', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                SizedBox(height: 30),
                                Text('____________________', style: TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red[800]!, width: 1.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'VERIFIED & AUTHORIZED',
                                    style: TextStyle(color: Colors.red[800], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text('Dr. Muhammad Zahid, MBBS, FCPS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                const Text('Chief Pathologist (Reg No: 3349-F)', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // Center Divider line & Disclaimer match (exactly like photo bottom)
                        Divider(thickness: 1, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        const Center(
                          child: Text(
                            'Provision: All tests are performed with utmost care, in case of any discordance with Clinical Correlation, please repeat the test.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Center(
                          child: Text(
                            'This report is not valid for any court of law',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

