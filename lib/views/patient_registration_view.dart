import 'package:flutter/material.dart';
import '../controllers/lab_controller.dart';
import '../models/lab_test.dart';
import '../models/patient.dart';

class PatientRegistrationView extends StatefulWidget {
  const PatientRegistrationView({super.key});

  @override
  State<PatientRegistrationView> createState() => _PatientRegistrationViewState();
}

class _PatientRegistrationViewState extends State<PatientRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  
  // Form State Bindings
  String _patientName = '';
  String _doctorName = 'Self';
  String _gender = 'Male';
  String _age = '';
  String _mobile = '';
  String _address = '';
  String _branch = '';
  
  final List<LabTest> _selectedTests = [];
  double _discountAmount = 0;
  double _receivedAmount = 0;

  final _discountController = TextEditingController();
  final _receivedController = TextEditingController();

  double get _totalAmount => _selectedTests.fold(0, (sum, test) => sum + test.price);
  double get _payableAmount => _totalAmount - _discountAmount;

  @override
  void initState() {
    super.initState();
    if (labController.branches.isNotEmpty) {
      _branch = labController.branches.first;
    } else {
      _branch = 'Main Branch';
    }
  }

  @override
  void dispose() {
    _discountController.dispose();
    _receivedController.dispose();
    super.dispose();
  }

  void _addTest(LabTest test) {
    if (!_selectedTests.any((t) => t.code == test.code)) {
      setState(() {
        _selectedTests.add(test);
      });
    }
  }

  void _removeTest(String code) {
    setState(() {
      _selectedTests.removeWhere((t) => t.code == code);
    });
  }

  void _savePatient() {
    if (_formKey.currentState!.validate() && _selectedTests.isNotEmpty) {
      _formKey.currentState!.save();

      final newPatient = Patient(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _patientName,
        doctorName: _doctorName,
        testName: _selectedTests.map((t) => t.code).join(', '),
        amount: _totalAmount,
        discount: _discountAmount,
        status: PatientStatus.pendingSample,
        date: DateTime.now(),
        gender: _gender,
        age: _age,
        mobile: _mobile,
        address: _address,
        branch: _branch,
        receivedAmount: _receivedAmount,
      );

      labController.addPatient(newPatient);

      // Show bill print preview dialog
      _showBillPrintPreview(newPatient, List.from(_selectedTests));

      // Clear form
      setState(() {
        _selectedTests.clear();
        _discountAmount = 0;
        _receivedAmount = 0;
        _discountController.clear();
        _receivedController.clear();
        _gender = 'Male';
        _age = '';
        _mobile = '';
        _address = '';
        if (labController.branches.isNotEmpty) {
          _branch = labController.branches.first;
        }
      });
      _formKey.currentState!.reset();
    } else if (_selectedTests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one test')),
      );
    }
  }

  void _showBillPrintPreview(Patient patient, List<LabTest> tests) {
    final double total    = tests.fold(0, (s, t) => s + t.price);
    final double payable  = total - patient.discount;
    final double balance  = payable - patient.receivedAmount;
    final String caseId   = patient.id.substring(patient.id.length - 5).toUpperCase();
    final String dateStr  = '${patient.date.day}/${patient.date.month}/${patient.date.year}';
    final String timeStr  =
        '${patient.date.hour}:${patient.date.minute.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 620,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Dialog header bar ──────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt_long, color: Colors.teal),
                      SizedBox(width: 8),
                      Text('Bill / Receipt Print Preview',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Bill sent to printer successfully!'),
                              backgroundColor: Colors.teal,
                            ),
                          );
                        },
                        icon: const Icon(Icons.print),
                        label: const Text('Print'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal[800],
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20),

              // ── Bill content ───────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lab letterhead
                    Center(
                      child: Column(
                        children: [
                          Text(
                            labController.labName.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2),
                          ),
                          const Text('CLINICAL LABORATORY',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text(
                            labController.labAddress,
                            style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                          ),
                          Text(
                            'Ph: ${labController.labPhone}',
                            style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8),
                          const Divider(thickness: 1.5, color: Colors.black),
                          const Text('PATIENT RECEIPT / BILL',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          const Divider(thickness: 1, color: Colors.black),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Case ID & Date row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _billRow('Case ID', caseId),
                        _billRow('Date', '$dateStr  $timeStr'),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Patient info
                    _billRow('Patient Name', patient.name.toUpperCase()),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(child: _billRow('Age / Gender', '${patient.age} Y / ${patient.gender}')),
                        Expanded(child: _billRow('Mobile', patient.mobile.isEmpty ? '-' : patient.mobile)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _billRow('Referred By', patient.doctorName),
                    if (patient.branch.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _billRow('Branch', patient.branch),
                    ],
                    const SizedBox(height: 12),
                    const Divider(),

                    // Tests table header
                    Container(
                      color: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: const Row(
                        children: [
                          Expanded(flex: 2, child: Text('Test Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Expanded(flex: 4, child: Text('Test Name',  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Expanded(flex: 2, child: Text('Price',      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.right)),
                        ],
                      ),
                    ),

                    // Tests rows
                    ...tests.map((t) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(t.code, style: const TextStyle(fontSize: 12))),
                          Expanded(flex: 4, child: Text(t.name, style: const TextStyle(fontSize: 12))),
                          Expanded(flex: 2, child: Text('Rs ${t.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12), textAlign: TextAlign.right)),
                        ],
                      ),
                    )),

                    const Divider(),
                    const SizedBox(height: 4),

                    // Billing summary
                    _amountRow('Total Amount',    'Rs ${total.toStringAsFixed(0)}'),
                    if (patient.discount > 0)
                      _amountRow('Discount',      '- Rs ${patient.discount.toStringAsFixed(0)}', color: Colors.red),
                    _amountRow('Payable Amount',  'Rs ${payable.toStringAsFixed(0)}', bold: true),
                    const Divider(height: 12),
                    _amountRow('Received Amount', 'Rs ${patient.receivedAmount.toStringAsFixed(0)}', color: Colors.green[800]!),
                    _amountRow('Balance Due',     'Rs ${balance.toStringAsFixed(0)}',
                        color: balance > 0 ? Colors.red[800]! : Colors.green[800]!,
                        bold: true),

                    const SizedBox(height: 16),
                    const Divider(thickness: 1, color: Colors.black),
                    const Center(
                      child: Text(
                        'Thank you for choosing our laboratory.',
                        style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widgets for bill layout
  Widget _billRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 12),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _amountRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(value,  style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Patient Registration', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            // Header Info Card (Branch & Time)
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ListenableBuilder(
                        listenable: labController,
                        builder: (context, _) {
                          return DropdownButtonFormField<String>(
                            value: labController.branches.contains(_branch) 
                                ? _branch 
                                : (labController.branches.isNotEmpty ? labController.branches.first : null),
                            decoration: const InputDecoration(labelText: 'Branch', border: OutlineInputBorder()),
                            items: labController.branches
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _branch = val;
                                });
                              }
                            },
                          );
                        }
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _buildReadOnlyField('Date/Time', DateTime.now().toString().split('.')[0])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Patient Info Section Card
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Patient Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Patient Name', border: OutlineInputBorder()),
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            onSaved: (v) => _patientName = v!,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _gender,
                            decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                            items: ['Male', 'Female', 'Other']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _gender = val;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()),
                            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            onSaved: (v) => _age = v!,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Mobile', border: OutlineInputBorder()),
                            onSaved: (v) => _mobile = v ?? '',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ListenableBuilder(
                            listenable: labController,
                            builder: (context, _) {
                              return DropdownButtonFormField<String>(
                                value: _doctorName,
                                decoration: const InputDecoration(labelText: 'Referring Doctor', border: OutlineInputBorder()),
                                items: labController.doctors
                                    .map((e) => DropdownMenuItem(value: e.name, child: Text(e.name)))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _doctorName = val;
                                    });
                                  }
                                },
                              );
                            }
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2, 
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                            onSaved: (v) => _address = v ?? '',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Test Selection Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search and Selected Tests Table
                Expanded(
                  flex: 2,
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Test Selection', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                          const Divider(),
                          
                          // Search Box Autocomplete
                          Autocomplete<LabTest>(
                            displayStringForOption: (option) => '${option.code} - ${option.name}',
                            optionsBuilder: (TextEditingValue textEditingValue) {
                              if (textEditingValue.text == '') {
                                return const Iterable<LabTest>.empty();
                              }
                              return labController.availableTests.where((test) {
                                return test.name.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
                                       test.code.toLowerCase().contains(textEditingValue.text.toLowerCase());
                              });
                            },
                            onSelected: (LabTest selection) {
                              _addTest(selection);
                            },
                            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                decoration: const InputDecoration(
                                  labelText: 'Search Test (CBC, LFT, etc.)',
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Selected Tests Table
                          SizedBox(
                            width: double.infinity,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                              columns: const [
                                DataColumn(label: Text('Code')),
                                DataColumn(label: Text('Test Name')),
                                DataColumn(label: Text('Price')),
                                DataColumn(label: Text('Action')),
                              ],
                              rows: _selectedTests.map((test) {
                                return DataRow(cells: [
                                  DataCell(Text(test.code)),
                                  DataCell(Text(test.name)),
                                  DataCell(Text('Rs ${test.price}')),
                                  DataCell(IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeTest(test.code),
                                  )),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Billing Panel
                Expanded(
                  flex: 1,
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Billing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                          const Divider(),
                          _buildSummaryRow('Total Amount:', 'Rs $_totalAmount'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _discountController,
                            decoration: const InputDecoration(labelText: 'Discount Amount', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              setState(() {
                                _discountAmount = double.tryParse(v) ?? 0;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryRow('Payable Amount:', 'Rs $_payableAmount', isBold: true),
                          const Divider(),
                          TextFormField(
                            controller: _receivedController,
                            decoration: const InputDecoration(labelText: 'Received Amount', border: OutlineInputBorder()),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              setState(() {
                                _receivedAmount = double.tryParse(v) ?? 0;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryRow('Balance:', 'Rs ${_payableAmount - _receivedAmount}', color: Colors.red),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _savePatient,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
                              icon: const Icon(Icons.save),
                              label: const Text('Save & Print', style: TextStyle(fontSize: 18)),
                            ),
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
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), filled: true, fillColor: Colors.grey[100]),
    );
  }
}
