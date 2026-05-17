import 'package:flutter/material.dart';
import '../controllers/lab_controller.dart';
import '../models/lab_test.dart';
import '../models/test_parameter.dart';

class AddTestView extends StatefulWidget {
  const AddTestView({super.key});

  @override
  State<AddTestView> createState() => _AddTestViewState();
}

class _AddTestViewState extends State<AddTestView> {
  final _formKey = GlobalKey<FormState>();
  String _code = '';
  String _name = '';
  String _category = 'Biochemistry';
  double _price = 0;
  
  // For parameters
  final List<TestParameter> _tempParameters = [];

  void _addParameter(StateSetter setDialogState) {
    final nameController = TextEditingController();
    final unitController = TextEditingController();
    final minController = TextEditingController();
    final maxController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Test Parameter (e.g. WBC, RBC)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Parameter Name', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: unitController, decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: minController, decoration: const InputDecoration(labelText: 'Min', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: maxController, decoration: const InputDecoration(labelText: 'Max', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setDialogState(() {
                  _tempParameters.add(TestParameter(
                    name: nameController.text,
                    unit: unitController.text,
                    minValue: double.tryParse(minController.text) ?? 0,
                    maxValue: double.tryParse(maxController.text) ?? 0,
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add Parameter'),
          ),
        ],
      ),
    );
  }

  void _showAddTestDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add New Lab Test'),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Test Code (e.g. CBC)', border: OutlineInputBorder()),
                      onSaved: (v) => _code = v ?? '',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Test Full Name', border: OutlineInputBorder()),
                      onSaved: (v) => _name = v ?? '',
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    ListenableBuilder(
                      listenable: labController,
                      builder: (context, _) {
                        return DropdownButtonFormField<String>(
                          initialValue: _category,
                          decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                          items: labController.categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => _category = v!),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Price (Rs)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      onSaved: (v) => _price = double.tryParse(v ?? '0') ?? 0,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    
                    // Parameters Section
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Test Parameters', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        TextButton.icon(
                          onPressed: () => _addParameter(setDialogState),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Param'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._tempParameters.map((p) => ListTile(
                      dense: true,
                      title: Text(p.name),
                      subtitle: Text('${p.minValue} - ${p.maxValue} ${p.unit}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        onPressed: () => setDialogState(() => _tempParameters.remove(p)),
                      ),
                    )),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final newTest = LabTest(
                      code: _code.toUpperCase(),
                      name: _name,
                      category: _category,
                      price: _price,
                      parameters: List.from(_tempParameters),
                    );
                    labController.addLabTest(newTest);
                    setState(() => _tempParameters.clear());
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Test Added Successfully!')));
                  }
                },
                child: const Text('Save Full Test'),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: labController,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Test Library Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    onPressed: _showAddTestDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Test'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Card(
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.blue[900], borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4))),
                      child: const Row(
                        children: [
                          Expanded(flex: 1, child: Text('Code', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          Expanded(flex: 3, child: Text('Test Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('Details / Parameters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          Expanded(flex: 1, child: Text('Price', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: labController.availableTests.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final test = labController.availableTests[index];
                        return ExpansionTile(
                          title: Row(
                            children: [
                              Expanded(flex: 1, child: Text(test.code, style: const TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(flex: 3, child: Text(test.name)),
                              Expanded(flex: 2, child: Text('${test.parameters.length} params', style: const TextStyle(color: Colors.blue, fontSize: 12))),
                              Expanded(flex: 1, child: Text('Rs ${test.price}')),
                            ],
                          ),
                          children: test.parameters.map((p) => ListTile(
                            dense: true,
                            title: Text(p.name),
                            subtitle: Text('Unit: ${p.unit} | Range: ${p.minValue} - ${p.maxValue}'),
                          )).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
