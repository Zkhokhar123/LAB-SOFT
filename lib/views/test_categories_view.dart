import 'package:flutter/material.dart';
import '../controllers/lab_controller.dart';

class TestCategoriesView extends StatefulWidget {
  const TestCategoriesView({super.key});

  @override
  State<TestCategoriesView> createState() => _TestCategoriesViewState();
}

class _TestCategoriesViewState extends State<TestCategoriesView> {
  final _categoryController = TextEditingController();

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
              const Text('Test Categories', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(labelText: 'New Category Name', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_categoryController.text.isNotEmpty) {
                        labController.addCategory(_categoryController.text);
                        _categoryController.clear();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Category'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], foregroundColor: Colors.white, padding: const EdgeInsets.all(20)),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: labController.categories.map((category) {
                  return Chip(
                    label: Text(category),
                    backgroundColor: Colors.blue[50],
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () => labController.removeCategory(category),
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
