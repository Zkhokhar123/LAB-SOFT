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
    // We create a list of controllers for all parameters
    final Map<String, Map<String, TextEditingController>> paramControllers = {};
    for (var p in test.parameters) {
      paramControllers[p.name] = {
        'unit': TextEditingController(text: p.unit),
        'min': TextEditingController(text: p.minValue.toString()),
        'max': TextEditingController(text: p.maxValue.toString()),
      };
    }

    // Controllers for the main test if no parameters
    final unitController = TextEditingController(text: test.unit);
    final minController = TextEditingController(text: test.minValue.toString());
    final maxController = TextEditingController(text: test.maxValue.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue[900],
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Text('Manual Range Configuration: ${test.code}', style: const TextStyle(color: Colors.white)),
        ),
        content: SizedBox(
          width: 800,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Different machines may have different ranges. Adjust them here manually.', style: TextStyle(color: Colors.grey)),
                ),
                
                if (test.parameters.isEmpty) ...[
                  _buildEditRow('Main Test', unitController, minController, maxController),
                ] else ...[
                  ...test.parameters.map((p) {
                    final controllers = paramControllers[p.name]!;
                    return _buildEditRow(p.name, controllers['unit']!, controllers['min']!, controllers['max']!);
                  }),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final List<TestParameter> updatedParams = [];
              for (var p in test.parameters) {
                final controllers = paramControllers[p.name]!;
                updatedParams.add(TestParameter(
                  name: p.name,
                  unit: controllers['unit']!.text,
                  minValue: double.tryParse(controllers['min']!.text) ?? 0,
                  maxValue: double.tryParse(controllers['max']!.text) ?? 0,
                ));
              }

              final updatedTest = LabTest(
                code: test.code,
                name: test.name,
                price: test.price,
                category: test.category,
                reportingTime: test.reportingTime,
                unit: test.parameters.isEmpty ? unitController.text : test.unit,
                minValue: test.parameters.isEmpty ? (double.tryParse(minController.text) ?? 0) : test.minValue,
                maxValue: test.parameters.isEmpty ? (double.tryParse(maxController.text) ?? 0) : test.maxValue,
                parameters: updatedParams,
              );
              
              labController.updateLabTest(updatedTest);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Range for ${test.code} updated successfully!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[700], foregroundColor: Colors.white),
            child: const Text('Save Machine Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditRow(String label, TextEditingController unit, TextEditingController min, TextEditingController max) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(flex: 2, child: TextField(controller: unit, decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder(), isDense: true))),
              const SizedBox(width: 8),
              Expanded(flex: 1, child: TextField(controller: min, decoration: const InputDecoration(labelText: 'Min Range', border: OutlineInputBorder(), isDense: true))),
              const SizedBox(width: 8),
              Expanded(flex: 1, child: TextField(controller: max, decoration: const InputDecoration(labelText: 'Max Range', border: OutlineInputBorder(), isDense: true))),
            ],
          ),
          const Divider(height: 24),
        ],
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

              TextField(
                decoration: const InputDecoration(hintText: 'Search test to edit range...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
                onChanged: (v) => setState(() => _searchQuery = v),
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
