import 'package:flutter/material.dart';

class CreateListingDialog extends StatefulWidget {
  const CreateListingDialog({super.key});

  @override
  State<CreateListingDialog> createState() => _CreateListingDialogState();
}

class _CreateListingDialogState extends State<CreateListingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cropController = TextEditingController();
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  String _quality = 'Grade A';
  bool _organic = false;

  @override
  void dispose() {
    _cropController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Create Listing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cropController,
                  decoration: const InputDecoration(labelText: 'Crop type'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _qtyController,
                  decoration: const InputDecoration(labelText: 'Quantity (e.g., 100 kg)'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price per kg (KES)'),
                  keyboardType: TextInputType.number,
                  validator: (v) => double.tryParse(v ?? '') == null ? 'Enter a number' : null,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _quality,
                  items: const ['Grade A', 'Grade B', 'Grade C']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _quality = v ?? 'Grade A'),
                  decoration: const InputDecoration(labelText: 'Quality Grade'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Organic'),
                  value: _organic,
                  onChanged: (v) => setState(() => _organic = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() == true) {
                            Navigator.pop(context, {
                              'cropType': _cropController.text.trim(),
                              'quantity': _qtyController.text.trim(),
                              'pricePerKg': double.parse(_priceController.text.trim()),
                              'qualityGrade': _quality,
                              'isOrganic': _organic,
                            });
                          }
                        },
                        child: const Text('Create'),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}