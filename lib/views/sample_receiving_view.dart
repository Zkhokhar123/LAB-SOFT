import 'package:flutter/material.dart';

class SampleReceivingView extends StatefulWidget {
  const SampleReceivingView({super.key});

  @override
  State<SampleReceivingView> createState() => _SampleReceivingViewState();
}

class _SampleReceivingViewState extends State<SampleReceivingView> {
  bool _showFilters = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sample Receiving', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
                onPressed: () => setState(() => _showFilters = !_showFilters),
                tooltip: 'Toggle Filters',
              )
            ],
          ),
          const SizedBox(height: 16),
          
          if (_showFilters) ...[
            // Filter Panel
            Card(
              color: Colors.white,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Case No')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildTextField('Patient Name')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildTextField('Mobile No.')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildDropdown('Doctor', ['All', 'Dr. Sarah Khan', 'Dr. Ahmed'])),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Date From:'),
                        const SizedBox(width: 8),
                        Expanded(child: _buildTextField('01/05/2026')),
                        const SizedBox(width: 8),
                        const Text('Date To:'),
                        const SizedBox(width: 8),
                        Expanded(child: _buildTextField('16/05/2026')),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.refresh),
                          label: const Text('Update List'),
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
              child: DataTable(
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
                rows: [
                  _buildPatientRow('10293', 'Muhammad Ali', '34 Y / M', '16/05/2026 10:30', 'Dr. Sarah Khan', 2),
                  _buildPatientRow('10294', 'Fatima Bibi', '28 Y / F', '16/05/2026 11:15', 'Self', 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildPatientRow(String caseNo, String name, String ageSex, String dateTime, String doctor, int testCount) {
    return DataRow(cells: [
      DataCell(Checkbox(value: false, onChanged: (v) {})),
      DataCell(Text(caseNo)),
      DataCell(Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(ageSex)),
      DataCell(Text(dateTime)),
      DataCell(Text(doctor)),
      DataCell(ActionChip(
        label: Text('$testCount Tests'),
        onPressed: () {
          _showTestDetailsDialog(name, caseNo);
        },
      )),
    ]);
  }

  void _showTestDetailsDialog(String name, String caseNo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tests for $name ($caseNo)'),
        content: SizedBox(
          width: 500,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Received')),
              DataColumn(label: Text('Test Code')),
              DataColumn(label: Text('Test Name')),
            ],
            rows: const [
              DataRow(cells: [
                DataCell(Checkbox(value: true, onChanged: null)),
                DataCell(Text('T-001')),
                DataCell(Text('Liver Function Test')),
              ]),
              DataRow(cells: [
                DataCell(Checkbox(value: false, onChanged: null)),
                DataCell(Text('T-002')),
                DataCell(Text('CBC')),
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Confirm Receipt')),
        ],
      ),
    );
  }

  Widget _buildTextField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        initialValue: items.first,
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (val) {},
      ),
    );
  }
}
