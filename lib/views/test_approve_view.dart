import 'package:flutter/material.dart';

class TestApproveView extends StatelessWidget {
  const TestApproveView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Test Verification & Approval', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // Filters
          Card(
            color: Colors.white,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(child: _buildTextField('Search Case No/Name')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDropdown('Status', ['Pending Approval', 'Approved', 'Rejected'])),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.search),
                    label: const Text('Search'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Approval Table
          Card(
            color: Colors.white,
            elevation: 2,
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.green[800]),
                headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                columns: const [
                  DataColumn(label: Text('Case No')),
                  DataColumn(label: Text('Patient Name')),
                  DataColumn(label: Text('Test Name')),
                  DataColumn(label: Text('Result Date')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Action')),
                ],
                rows: [
                  _buildApproveRow('10293', 'Muhammad Ali', 'Liver Function Test', '16/05/2026', 'Pending'),
                  _buildApproveRow('10291', 'Zahid Hussain', 'CBC', '15/05/2026', 'Pending'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildApproveRow(String caseNo, String name, String test, String date, String status) {
    return DataRow(cells: [
      DataCell(Text(caseNo)),
      DataCell(Text(name, style: const TextStyle(fontWeight: FontWeight.bold))),
      DataCell(Text(test)),
      DataCell(Text(date)),
      DataCell(Chip(label: Text(status), backgroundColor: Colors.orange[100])),
      DataCell(Row(
        children: [
          IconButton(icon: const Icon(Icons.visibility, color: Colors.blue), onPressed: () {}),
          IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () {}),
        ],
      )),
    ]);
  }

  Widget _buildTextField(String label) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
    return DropdownButtonFormField<String>(
      initialValue: items.first,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        border: const OutlineInputBorder(),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (val) {},
    );
  }
}
