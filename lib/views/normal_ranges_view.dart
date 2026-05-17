import 'package:flutter/material.dart';
import '../controllers/lab_controller.dart';
import '../models/lab_test.dart';
import '../models/test_parameter.dart';

class NormalRangesView extends StatefulWidget {
  const NormalRangesView({super.key});

  @override
  State<NormalRangesView> createState() => _NormalRangesViewState();
}

class _NormalRangesViewState extends State<NormalRangesView> {
  String _searchQuery = '';

  void _editRange(LabTest test) {
    final List<_EditableParam> editableParams = test.parameters
        .map((p) => _EditableParam(
              name: p.name,
              unit: p.unit,
              min: p.minValue.toString(),
              max: p.maxValue.toString(),
            ))
        .toList();

    // Controllers for the main test if no parameters
    final mainUnitController = TextEditingController(text: test.unit);
    final mainMinController = TextEditingController(text: test.minValue.toString());
    final mainMaxController = TextEditingController(text: test.maxValue.toString());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            titlePadding: EdgeInsets.zero,
            title: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[900],
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Configure: ${test.code}',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      for (var ep in editableParams) {
                        ep.dispose();
                      }
                      mainUnitController.dispose();
                      mainMinController.dispose();
                      mainMaxController.dispose();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            content: SizedBox(
              width: 850,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Customize sub-parameters, names, units, and ranges dynamically. Adding sub-parameters turns a single-value test into a multi-parameter test.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    if (editableParams.isEmpty) ...[
                      const Text(
                        'Main Test Configuration (Single-value test)',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: mainUnitController,
                              decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder(), isDense: true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: mainMinController,
                              decoration: const InputDecoration(labelText: 'Min Range', border: OutlineInputBorder(), isDense: true),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: TextField(
                              controller: mainMaxController,
                              decoration: const InputDecoration(labelText: 'Max Range', border: OutlineInputBorder(), isDense: true),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          'Test Sub-Parameters',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: editableParams.length,
                        itemBuilder: (context, index) {
                          final ep = editableParams[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Colors.grey[200]!),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: ep.nameController,
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                                          decoration: const InputDecoration(
                                            labelText: 'Parameter Name',
                                            hintText: 'e.g. Hemoglobin',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        tooltip: 'Delete Parameter',
                                        onPressed: () {
                                          setDialogState(() {
                                            editableParams[index].dispose();
                                            editableParams.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: TextField(
                                          controller: ep.unitController,
                                          decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder(), isDense: true),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 1,
                                        child: TextField(
                                          controller: ep.minController,
                                          decoration: const InputDecoration(labelText: 'Min Value', border: OutlineInputBorder(), isDense: true),
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 1,
                                        child: TextField(
                                          controller: ep.maxController,
                                          decoration: const InputDecoration(labelText: 'Max Value', border: OutlineInputBorder(), isDense: true),
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            editableParams.add(_EditableParam(
                              name: '',
                              unit: '-',
                              min: '0.0',
                              max: '0.0',
                            ));
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Sub-Parameter'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  for (var ep in editableParams) {
                    ep.dispose();
                  }
                  mainUnitController.dispose();
                  mainMinController.dispose();
                  mainMaxController.dispose();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final List<TestParameter> updatedParams = [];
                  for (var ep in editableParams) {
                    if (ep.nameController.text.trim().isNotEmpty) {
                      updatedParams.add(TestParameter(
                        name: ep.nameController.text.trim(),
                        unit: ep.unitController.text.trim(),
                        minValue: double.tryParse(ep.minController.text) ?? 0,
                        maxValue: double.tryParse(ep.maxController.text) ?? 0,
                      ));
                    }
                  }

                  final updatedTest = LabTest(
                    code: test.code,
                    name: test.name,
                    price: test.price,
                    category: test.category,
                    reportingTime: test.reportingTime,
                    unit: updatedParams.isEmpty ? mainUnitController.text : test.unit,
                    minValue: updatedParams.isEmpty ? (double.tryParse(mainMinController.text) ?? 0) : test.minValue,
                    maxValue: updatedParams.isEmpty ? (double.tryParse(mainMaxController.text) ?? 0) : test.maxValue,
                    parameters: updatedParams,
                  );

                  labController.updateLabTest(updatedTest);

                  // Clean up controllers
                  for (var ep in editableParams) {
                    ep.dispose();
                  }
                  mainUnitController.dispose();
                  mainMinController.dispose();
                  mainMaxController.dispose();

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Configuration for ${test.code} updated successfully!')),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[700], foregroundColor: Colors.white),
                child: const Text('Save Configuration'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddNewTestDialog() {
    final formKey = GlobalKey<FormState>();
    String code = '';
    String name = '';
    String category = labController.categories.isNotEmpty ? labController.categories.first : 'Biochemistry';
    double price = 0;
    
    // Sub-parameters state inside the dialog
    final List<_EditableParam> newParams = [];

    // Main test controllers if they decide not to have sub-parameters
    final mainUnitController = TextEditingController(text: '-');
    final mainMinController = TextEditingController(text: '0.0');
    final mainMaxController = TextEditingController(text: '0.0');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            titlePadding: EdgeInsets.zero,
            title: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[900],
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add New Lab Test', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      for (var ep in newParams) {
                        ep.dispose();
                      }
                      mainUnitController.dispose();
                      mainMinController.dispose();
                      mainMaxController.dispose();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            content: SizedBox(
              width: 850,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      // Core details in a Row
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              decoration: const InputDecoration(labelText: 'Test Code (e.g. HBA1C)', border: OutlineInputBorder(), isDense: true),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              onSaved: (v) => code = v!.trim().toUpperCase(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              decoration: const InputDecoration(labelText: 'Test Full Name', border: OutlineInputBorder(), isDense: true),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                              onSaved: (v) => name = v!.trim(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: category,
                              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder(), isDense: true),
                              items: labController.categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (v) => setDialogState(() => category = v!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(labelText: 'Price (Rs.)', border: OutlineInputBorder(), isDense: true),
                              keyboardType: TextInputType.number,
                              validator: (v) => v == null || double.tryParse(v) == null ? 'Enter valid price' : null,
                              onSaved: (v) => price = double.parse(v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 8),

                      if (newParams.isEmpty) ...[
                        const Text(
                          'Main Test Configuration (Single-value test)',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: mainUnitController,
                                decoration: const InputDecoration(labelText: 'Unit (e.g. mg/dL)', border: OutlineInputBorder(), isDense: true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: mainMinController,
                                decoration: const InputDecoration(labelText: 'Min Range', border: OutlineInputBorder(), isDense: true),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: mainMaxController,
                                decoration: const InputDecoration(labelText: 'Max Range', border: OutlineInputBorder(), isDense: true),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            'Test Sub-Parameters',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: newParams.length,
                          itemBuilder: (context, index) {
                            final ep = newParams[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6.0),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(color: Colors.grey[200]!),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: ep.nameController,
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                                            decoration: const InputDecoration(
                                              labelText: 'Parameter Name',
                                              hintText: 'e.g. Hemoglobin',
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          tooltip: 'Delete Parameter',
                                          onPressed: () {
                                            setDialogState(() {
                                              newParams[index].dispose();
                                              newParams.removeAt(index);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: TextField(
                                            controller: ep.unitController,
                                            decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder(), isDense: true),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 1,
                                          child: TextField(
                                            controller: ep.minController,
                                            decoration: const InputDecoration(labelText: 'Min Value', border: OutlineInputBorder(), isDense: true),
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 1,
                                          child: TextField(
                                            controller: ep.maxController,
                                            decoration: const InputDecoration(labelText: 'Max Value', border: OutlineInputBorder(), isDense: true),
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setDialogState(() {
                              newParams.add(_EditableParam(
                                name: '',
                                unit: '-',
                                min: '0.0',
                                max: '0.0',
                              ));
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Add Sub-Parameter'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  for (var ep in newParams) {
                    ep.dispose();
                  }
                  mainUnitController.dispose();
                  mainMinController.dispose();
                  mainMaxController.dispose();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    
                    // Check if test code already exists
                    final exists = labController.availableTests.any((t) => t.code.toUpperCase() == code);
                    if (exists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Test code "$code" already exists!'), backgroundColor: Colors.red[800]),
                      );
                      return;
                    }

                    final List<TestParameter> parameters = [];
                    for (var ep in newParams) {
                      if (ep.nameController.text.trim().isNotEmpty) {
                        parameters.add(TestParameter(
                          name: ep.nameController.text.trim(),
                          unit: ep.unitController.text.trim(),
                          minValue: double.tryParse(ep.minController.text) ?? 0,
                          maxValue: double.tryParse(ep.maxController.text) ?? 0,
                        ));
                      }
                    }

                    final newTest = LabTest(
                      code: code,
                      name: name,
                      price: price,
                      category: category,
                      unit: parameters.isEmpty ? mainUnitController.text : '-',
                      minValue: parameters.isEmpty ? (double.tryParse(mainMinController.text) ?? 0) : 0,
                      maxValue: parameters.isEmpty ? (double.tryParse(mainMaxController.text) ?? 0) : 0,
                      parameters: parameters,
                    );

                    labController.addLabTest(newTest);

                    // Clean up controllers
                    for (var ep in newParams) {
                      ep.dispose();
                    }
                    mainUnitController.dispose();
                    mainMinController.dispose();
                    mainMaxController.dispose();

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Test "$name" ($code) added successfully!'), backgroundColor: Colors.green[800]),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[700], foregroundColor: Colors.white),
                child: const Text('Save Lab Test'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: labController,
      builder: (context, _) {
        final filteredTests = labController.availableTests.where((test) {
          return test.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 test.code.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Manual Range & Machine Configuration', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Adjust units and reference ranges manually for each test and its sub-parameters.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search test to edit range...', 
                        prefixIcon: Icon(Icons.search), 
                        border: OutlineInputBorder(), 
                        filled: true, 
                        fillColor: Colors.white,
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _showAddNewTestDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add New Test', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Card(
                color: Colors.white,
                elevation: 2,
                child: SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.blue[900]),
                    headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    columns: const [
                      DataColumn(label: Text('Code')),
                      DataColumn(label: Text('Test Name')),
                      DataColumn(label: Text('Details')),
                      DataColumn(label: Text('Unit')),
                      DataColumn(label: Text('Reference Range')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: filteredTests.map((test) {
                      return DataRow(cells: [
                        DataCell(Text(test.code, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(test.name)),
                        DataCell(Text('${test.parameters.length} Sub-tests')),
                        DataCell(Text(test.parameters.isEmpty ? test.unit : 'Multiple')),
                        DataCell(Text(test.parameters.isEmpty ? '${test.minValue} - ${test.maxValue}' : 'Mixed')),
                        DataCell(IconButton(
                          icon: const Icon(Icons.settings, color: Colors.blue),
                          onPressed: () => _editRange(test),
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EditableParam {
  final TextEditingController nameController;
  final TextEditingController unitController;
  final TextEditingController minController;
  final TextEditingController maxController;

  _EditableParam({
    required String name,
    required String unit,
    required String min,
    required String max,
  })  : nameController = TextEditingController(text: name),
        unitController = TextEditingController(text: unit),
        minController = TextEditingController(text: min),
        maxController = TextEditingController(text: max);

  void dispose() {
    nameController.dispose();
    unitController.dispose();
    minController.dispose();
    maxController.dispose();
  }
}
