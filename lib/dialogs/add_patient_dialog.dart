import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../controllers/lab_controller.dart';

class AddPatientDialog extends StatefulWidget {
  const AddPatientDialog({super.key});

  @override
  State<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _testName = '';
  double _amount = 0;
  double _discount = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Patient Registration'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Patient Name'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => _name = val!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Test Name'),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => _testName = val!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount (Rs)'),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || double.tryParse(val) == null ? 'Invalid' : null,
                onSaved: (val) => _amount = double.parse(val!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Discount (Rs)'),
                keyboardType: TextInputType.number,
                onSaved: (val) => _discount = double.tryParse(val ?? '') ?? 0.0,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final patient = Patient(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: _name,
                testName: _testName,
                amount: _amount,
                discount: _discount,
                status: PatientStatus.pendingSample,
                date: DateTime.now(),
              );
              labController.addPatient(patient);
              Navigator.pop(context);
            }
          },
          child: const Text('Register'),
        ),
      ],
    );
  }
}
