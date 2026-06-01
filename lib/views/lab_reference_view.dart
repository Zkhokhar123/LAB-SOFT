import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/lab_controller.dart';
import '../models/patient.dart';

class LabReferenceView extends StatefulWidget {
  const LabReferenceView({super.key});

  @override
  State<LabReferenceView> createState() => _LabReferenceViewState();
}

class _LabReferenceViewState extends State<LabReferenceView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Local state datasets
  List<Map<String, dynamic>> _outsourcedTests = [];
  List<Map<String, dynamic>> _partnerCenters = [];

  // Form selections & Controllers
  String _selectedOutsourceStatus = 'Dispatched';
  Patient? _selectedOutsourcePatient;
  final _refLabController = TextEditingController();
  final _costController = TextEditingController();

  // Partner controllers
  final _partnerNameController = TextEditingController();
  final _partnerCommController = TextEditingController(text: '15');
  final _partnerPhoneController = TextEditingController();
  final _partnerAddressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReferenceData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refLabController.dispose();
    _costController.dispose();
    _partnerNameController.dispose();
    _partnerCommController.dispose();
    _partnerPhoneController.dispose();
    _partnerAddressController.dispose();
    super.dispose();
  }

  // --- LOCAL PERSISTENCE LOADER ---
  Future<void> _loadReferenceData() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    // Load Outsourced Records
    final outsourcedJson = prefs.getString('outsourced_tests');
    if (outsourcedJson != null) {
      try {
        final List<dynamic> decoded = json.decode(outsourcedJson);
        _outsourcedTests = List<Map<String, dynamic>>.from(decoded);
      } catch (e) {
        _outsourcedTests = [];
      }
    }

    // Load Partner Reference Centers
    final partnerJson = prefs.getString('partner_centers');
    if (partnerJson != null) {
      try {
        final List<dynamic> decoded = json.decode(partnerJson);
        _partnerCenters = List<Map<String, dynamic>>.from(decoded);
      } catch (e) {
        _partnerCenters = [];
      }
    } else {
      // Default offline Partner centers
      _partnerCenters = [
        {
          'name': 'City Care Collection Point',
          'commission_percentage': 15.0,
          'phone': '0300-9876543',
          'address': 'Main Bazaar Road, Lahore'
        },
        {
          'name': 'Al-Shifa Clinic Referral',
          'commission_percentage': 20.0,
          'phone': '0312-8765432',
          'address': 'Chowk Rangeila, Gujranwala'
        }
      ];
      await _savePartnerCenters();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveOutsourcedTests() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('outsourced_tests', json.encode(_outsourcedTests));
  }

  Future<void> _savePartnerCenters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('partner_centers', json.encode(_partnerCenters));
  }

  // --- ACTIONS: OUTSOURCED LABS ---
  void _showAddOutsourceDialog() {
    _selectedOutsourcePatient = null;
    _refLabController.clear();
    _costController.clear();
    _selectedOutsourceStatus = 'Dispatched';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.biotech, color: Colors.blue[900]),
                  const SizedBox(width: 8),
                  const Text('Outsource New Lab Test'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Patient selection Dropdown
                    DropdownButtonFormField<Patient>(
                      initialValue: _selectedOutsourcePatient,
                      hint: const Text('Select Patient (Dynamic list)'),
                      decoration: const InputDecoration(labelText: 'Patient Name', border: OutlineInputBorder()),
                      items: labController.patients.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text('${p.name} (${p.testName})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() {
                          _selectedOutsourcePatient = val;
                          // pre-populate test details
                          if (val != null) {
                            _refLabController.text = 'Chughtai Lab';
                            _costController.text = (val.amount * 0.4).toStringAsFixed(0); // Estimate 40% outsource cost
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Reference Lab Input
                    TextField(
                      controller: _refLabController,
                      decoration: const InputDecoration(labelText: 'Reference Lab Name (e.g. Aga Khan)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),

                    // Cost Input
                    TextField(
                      controller: _costController,
                      decoration: const InputDecoration(labelText: 'Outsource Cost (Rs)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Status selection
                    DropdownButtonFormField<String>(
                      initialValue: _selectedOutsourceStatus,
                      decoration: const InputDecoration(labelText: 'Referral Status', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'Under Process', child: Text('Under Process')),
                        DropdownMenuItem(value: 'Dispatched', child: Text('Dispatched')),
                        DropdownMenuItem(value: 'Received', child: Text('Received')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            _selectedOutsourceStatus = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedOutsourcePatient == null || _refLabController.text.isEmpty || _costController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields!'), backgroundColor: Colors.orange),
                      );
                      return;
                    }

                    setState(() {
                      _outsourcedTests.insert(0, {
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'patient_id': _selectedOutsourcePatient!.id,
                        'patient_name': _selectedOutsourcePatient!.name,
                        'test_name': _selectedOutsourcePatient!.testName,
                        'reference_lab': _refLabController.text,
                        'outsource_cost': double.tryParse(_costController.text) ?? 0.0,
                        'date': DateTime.now().toIso8601String(),
                        'status': _selectedOutsourceStatus,
                      });
                    });

                    _saveOutsourcedTests();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Outsource Referral Added Successfully!'), backgroundColor: Colors.teal),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], foregroundColor: Colors.white),
                  child: const Text('Save Record'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateOutsourceStatus(int index, String newStatus) {
    setState(() {
      _outsourcedTests[index]['status'] = newStatus;
    });
    _saveOutsourcedTests();
  }

  void _deleteOutsourceRecord(int index) {
    setState(() {
      _outsourcedTests.removeAt(index);
    });
    _saveOutsourcedTests();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Record deleted!'), backgroundColor: Colors.redAccent),
    );
  }

  // --- ACTIONS: PARTNER CENTERS ---
  void _showAddPartnerDialog() {
    _partnerNameController.clear();
    _partnerCommController.text = '15';
    _partnerPhoneController.clear();
    _partnerAddressController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.store, color: Colors.teal[800]),
              const SizedBox(width: 8),
              const Text('Add Partner Center'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _partnerNameController,
                decoration: const InputDecoration(labelText: 'Center Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _partnerCommController,
                decoration: const InputDecoration(labelText: 'Ledger Commission (%)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _partnerPhoneController,
                decoration: const InputDecoration(labelText: 'Phone/Mobile', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _partnerAddressController,
                decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (_partnerNameController.text.isEmpty) return;

                setState(() {
                  _partnerCenters.add({
                    'name': _partnerNameController.text,
                    'commission_percentage': double.tryParse(_partnerCommController.text) ?? 15.0,
                    'phone': _partnerPhoneController.text,
                    'address': _partnerAddressController.text,
                  });
                });

                _savePartnerCenters();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Partner Reference Center Added!'), backgroundColor: Colors.teal),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[800], foregroundColor: Colors.white),
              child: const Text('Save Center'),
            ),
          ],
        );
      },
    );
  }

  void _deletePartnerCenter(int index) {
    setState(() {
      _partnerCenters.removeAt(index);
    });
    _savePartnerCenters();
  }

  // --- GENERAL LAYOUT BUILDER ---
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: labController,
      builder: (context, _) {
        if (_isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF9FAFB),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(72),
            child: Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.blue[900],
                unselectedLabelColor: Colors.grey[600],
                indicatorColor: Colors.blue[900],
                indicatorWeight: 3,
                tabs: const [
                  Tab(icon: Icon(Icons.outbox), text: 'Outsourced Reference Labs (Sent Tests)'),
                  Tab(icon: Icon(Icons.store), text: 'Reference Partners (Collection Points)'),
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOutsourcedLabsTab(),
              _buildReferencePartnersTab(),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 1: OUTSOURCED REFERENCE LABS
  // ==========================================
  Widget _buildOutsourcedLabsTab() {
    // Stats calculation
    final double totalOutsourceCost = _outsourcedTests.fold(0.0, (sum, val) => sum + (val['outsource_cost'] ?? 0.0));
    final int dispatchedCount = _outsourcedTests.where((x) => x['status'] == 'Dispatched').length;
    final int receivedCount = _outsourcedTests.where((x) => x['status'] == 'Received').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter & Add row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Outsourced Diagnostic Referrals',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[950]),
                  ),
                  const SizedBox(height: 4),
                  const Text('Track diagnostic tests dispatched to external reference laboratories (Chughtai, Aga Khan, etc.)', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddOutsourceDialog,
                icon: const Icon(Icons.add),
                label: const Text('Outsource New Test'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats cards
          Row(
            children: [
              _buildStatsCard('Total Outsource Actions', '${_outsourcedTests.length} Referrals', Icons.swap_horiz, Colors.purple[700]!),
              const SizedBox(width: 16),
              _buildStatsCard('Outsource Expenses', 'Rs ${totalOutsourceCost.toStringAsFixed(0)}', Icons.payment, Colors.red[700]!),
              const SizedBox(width: 16),
              _buildStatsCard('Dispatched to Labs', '$dispatchedCount Pending', Icons.local_shipping, Colors.blue[800]!),
              const SizedBox(width: 16),
              _buildStatsCard('Reports Received', '$receivedCount Completed', Icons.check_circle, Colors.green[800]!),
            ],
          ),
          const SizedBox(height: 32),

          // Detailed Table
          Card(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reference Outsource Register', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const Divider(height: 24),
                  if (_outsourcedTests.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text('No outsourced reference test register exists yet.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.blue[900]!.withAlpha(10)),
                        columns: const [
                          DataColumn(label: Text('Patient Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Test Referred', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Reference Lab', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Outsource Cost', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Referral Date', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _outsourcedTests.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final val = entry.value;
                          final dateVal = DateTime.tryParse(val['date']) ?? DateTime.now();

                          return DataRow(cells: [
                            DataCell(Text(val['patient_name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(val['test_name'])),
                            DataCell(Text(val['reference_lab'], style: TextStyle(color: Colors.indigo[800], fontWeight: FontWeight.w600))),
                            DataCell(Text('Rs ${val['outsource_cost']}')),
                            DataCell(Text('${dateVal.day}/${dateVal.month}/${dateVal.year}')),
                            DataCell(DropdownButton<String>(
                              value: val['status'],
                              style: TextStyle(
                                color: val['status'] == 'Received'
                                    ? Colors.green[800]
                                    : val['status'] == 'Dispatched'
                                        ? Colors.blue[800]
                                        : Colors.amber[900],
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Under Process', child: Text('Under Process')),
                                DropdownMenuItem(value: 'Dispatched', child: Text('Dispatched')),
                                DropdownMenuItem(value: 'Received', child: Text('Received')),
                              ],
                              onChanged: (newVal) {
                                if (newVal != null) {
                                  _updateOutsourceStatus(idx, newVal);
                                }
                              },
                            )),
                            DataCell(IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _deleteOutsourceRecord(idx),
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
  }

  // ==========================================
  // TAB 2: REFERENCE PARTNERS (INBOUND CENTERS)
  // ==========================================
  Widget _buildReferencePartnersTab() {
    // Group patient count by patient referred centers
    // Center names are grouped when matched to Patient.doctorName (referrer)
    final Map<String, List<Patient>> partnerGroups = {};
    for (var p in labController.patients) {
      partnerGroups.putIfAbsent(p.doctorName, () => []).add(p);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter & Add row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reference Partners & Collection Ledger',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal[950]),
                  ),
                  const SizedBox(height: 4),
                  const Text('Manage inbound franchise, clinic collections points, and affiliate referrers', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddPartnerDialog,
                icon: const Icon(Icons.add_business),
                label: const Text('Add Reference Partner'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Detailed Table Card
          Card(
            color: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Inbound Franchises & Partner Ledger', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                  const Divider(height: 24),
                  if (_partnerCenters.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text('No partners registered yet.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.teal[900]!.withAlpha(10)),
                        columns: const [
                          DataColumn(label: Text('Partner Center Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Phone/Mobile', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Total Referred Cases', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Revenue Generated', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Commission Rate', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Total Commission Due', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _partnerCenters.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final val = entry.value;
                          final name = val['name'];

                          // calculate ledger stats from live clinical database
                          final patients = partnerGroups[name] ?? [];
                          final double revenue = patients.fold(0.0, (sum, p) => sum + p.amount);
                          final double rate = (val['commission_percentage'] as num).toDouble();
                          final double dueCommission = revenue * (rate / 100);

                          return DataRow(cells: [
                            DataCell(Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(val['phone'] ?? '-')),
                            DataCell(Text('${patients.length} patients')),
                            DataCell(Text('Rs ${revenue.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Text('$rate %')),
                            DataCell(Text('Rs ${dueCommission.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _showPartnerPatientsDetail(name, patients),
                                  icon: const Icon(Icons.visibility, size: 16),
                                  label: const Text('Ledger'),
                                  style: TextButton.styleFrom(foregroundColor: Colors.teal[800]),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () {
                                    setState(() {
                                      _deletePartnerCenter(idx);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Partner removed.'), backgroundColor: Colors.redAccent),
                                    );
                                  },
                                ),
                              ],
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
  }

  void _showPartnerPatientsDetail(String partnerName, List<Patient> patients) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.store, color: Colors.teal[800]),
              const SizedBox(width: 8),
              Text('Patients Ledger - $partnerName'),
            ],
          ),
          content: SizedBox(
            width: 700,
            child: patients.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No patients registered under this partner center yet. To register one, select this center in the Patient Form Referrer.', style: TextStyle(color: Colors.grey)),
                    ),
                  )
                : SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.teal[50]),
                      columns: const [
                        DataColumn(label: Text('Patient Name', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Test Ordered', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Gross Bill', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: patients.map((p) {
                        return DataRow(cells: [
                          DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(p.testName)),
                          DataCell(Text('${p.date.day}/${p.date.month}/${p.date.year}')),
                          DataCell(Text('Rs ${p.amount}')),
                        ]);
                      }).toList(),
                    ),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close Ledger'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold)),
                Icon(icon, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
