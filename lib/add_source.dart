import 'package:flutter/material.dart';

class AddSourceDialog extends StatelessWidget {
  final List<String> availableBanks;
  final List<String> selectedBanks;
  final void Function(String key, String value) onAddSource;

  const AddSourceDialog({
    required this.availableBanks,
    required this.selectedBanks,
    required this.onAddSource,
  });

  @override
  Widget build(BuildContext context) {
    String selectedBank = '';
    String cashAmount = '';

    return AlertDialog(
      title: const Text('Add Source'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (availableBanks.isNotEmpty)
            DropdownButton<String>(
              hint: const Text('Select Bank'),
              value: selectedBank.isEmpty ? null : selectedBank,
              onChanged: (newValue) {
                selectedBank = newValue ?? '';
              },
              items: availableBanks.map((bank) {
                return DropdownMenuItem<String>(
                  value: bank,
                  child: Text(bank),
                );
              }).toList(),
            ),
          if (availableBanks.isEmpty)
            TextField(
              decoration: const InputDecoration(labelText: 'Cash Amount'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                cashAmount = value;
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (selectedBank.isNotEmpty) {
              onAddSource('Bank', selectedBank);
            } else if (cashAmount.isNotEmpty) {
              onAddSource('Cash', cashAmount);
            }
            Navigator.of(context).pop();
          },
          child: const Text('Add'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
