import 'package:flutter/material.dart';
import '../controllers/lab_controller.dart';

class GeneralSettingsView extends StatefulWidget {
  const GeneralSettingsView({super.key});

  @override
  State<GeneralSettingsView> createState() => _GeneralSettingsViewState();
}

class _GeneralSettingsViewState extends State<GeneralSettingsView> {
  final _nameController = TextEditingController(text: labController.labName);
  final _addressController = TextEditingController(text: labController.labAddress);
  final _phoneController = TextEditingController(text: labController.labPhone);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('General Lab Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildTextField('Laboratory Name', _nameController, Icons.business),
                  const SizedBox(height: 16),
                  _buildTextField('Physical Address', _addressController, Icons.location_on),
                  const SizedBox(height: 16),
                  _buildTextField('Contact Phone', _phoneController, Icons.phone),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        labController.updateLabInfo(
                          name: _nameController.text,
                          address: _addressController.text,
                          phone: _phoneController.text,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lab Information Updated!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
                      icon: const Icon(Icons.save),
                      label: const Text('Save Settings', style: TextStyle(fontSize: 18)),
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

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
