import 'package:flutter/material.dart';
import '../controllers/lab_controller.dart';

class BranchSetupView extends StatefulWidget {
  const BranchSetupView({super.key});

  @override
  State<BranchSetupView> createState() => _BranchSetupViewState();
}

class _BranchSetupViewState extends State<BranchSetupView> {
  final _branchController = TextEditingController();

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
              const Text('Branch Management', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _branchController,
                      decoration: const InputDecoration(labelText: 'New Branch Name', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_branchController.text.isNotEmpty) {
                        labController.addBranch(_branchController.text);
                        _branchController.clear();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Branch'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(20)),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Card(
                color: Colors.white,
                child: Column(
                  children: labController.branches.map((branch) {
                    return ListTile(
                      leading: const Icon(Icons.location_city, color: Colors.blue),
                      title: Text(branch, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => labController.removeBranch(branch),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
