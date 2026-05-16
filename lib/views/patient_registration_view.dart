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
  
  // Form State
  String _patientName = '';
  String _doctorName = 'Self';
  final List<LabTest> _selectedTests = [];
  double _discountAmount = 0;
  double _receivedAmount = 0;

  double get _totalAmount => _selectedTests.fold(0, (sum, test) => sum + test.price);
  double get _payableAmount => _totalAmount - _discountAmount;

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
      );

      labController.addPatient(newPatient);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient Registered Successfully!')),
      );
      
      // Clear form
      setState(() {
        _selectedTests.clear();
        _discountAmount = 0;
        _receivedAmount = 0;
      });
      _formKey.currentState!.reset();
    } else if (_selectedTests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one test')),
      );
    }
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
            
            // Header Info
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
                          return _buildDropdown('Branch', labController.branches);
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

            // Patient Info Section
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
                        Expanded(child: _buildDropdown('Gender', ['Male', 'Female', 'Other'])),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField('Age')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Mobile')),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ListenableBuilder(
                            listenable: labController,
                            builder: (context, _) {
                              return DropdownButtonFormField<String>(
                                initialValue: _doctorName,
                                decoration: const InputDecoration(labelText: 'Referring Doctor', border: OutlineInputBorder()),
                                items: labController.doctors
                                    .map((e) => DropdownMenuItem(value: e.name, child: Text(e.name)))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _doctorName = val!;
                                  });
                                },
                              );
                            }
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: _buildTextField('Address')),
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
                // Search and Table
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
                          
                          // Search Box
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

  Widget _buildTextField(String label) {
    return TextFormField(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), filled: true, fillColor: Colors.grey[100]),
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (val) {},
    );
  }
}
