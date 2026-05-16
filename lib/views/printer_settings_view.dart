import 'package:flutter/material.dart';
import '../controllers/lab_controller.dart';

class PrinterSettingsView extends StatelessWidget {
  const PrinterSettingsView({super.key});

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
              const Text('Printer & Report Configuration', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Select Report Printer Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      
                      _buildPrinterOption('A4 / Laser (Standard Reports)', 'A4 / Laser'),
                      _buildPrinterOption('80mm Thermal (Receipts)', '80mm Thermal'),
                      _buildPrinterOption('58mm Thermal (Small Receipts)', '58mm Thermal'),
                      _buildPrinterOption('Dot Matrix (Legacy)', 'Dot Matrix'),
                      
                      const SizedBox(height: 32),
                      const Text('Other Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Auto-print receipt after save'),
                        value: true,
                        onChanged: (v) {},
                      ),
                      SwitchListTile(
                        title: const Text('Include lab logo on reports'),
                        value: true,
                        onChanged: (v) {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrinterOption(String label, String value) {
    return RadioListTile<String>(
      title: Text(label),
      value: value,
      groupValue: labController.printerType,
      onChanged: (val) => labController.updatePrinter(val!),
    );
  }
}
