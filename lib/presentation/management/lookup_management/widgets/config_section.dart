import 'package:flutter/material.dart';
import 'package:milkshake/presentation/management/lookup_management/widgets/table_header_row.dart';
import 'package:milkshake/presentation/shared/formatters/format_updated_at.dart';
import 'package:milkshake/presentation/shared/formatters/zar_format.dart';

class ConfigTableCard extends StatelessWidget {
  const ConfigTableCard({
    required this.vatPercent,
    required this.maxDrinks,
    required this.baseDrinkPriceCents,
    required this.updatedAtMillis,
    required this.onAdd,
    required this.onEdit,
  });

  final int vatPercent;
  final int maxDrinks;
  final int baseDrinkPriceCents;
  final int updatedAtMillis;
  final VoidCallback onAdd;
  final ValueChanged<String> onEdit;

  @override
  Widget build(BuildContext context) {
    final updatedLabel = formatUpdatedAt(updatedAtMillis);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Configurations', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 860,
                child: Column(
                  children: [
                    TableHeaderRow(),
                    const SizedBox(height: 8),
                    ConfigRow(
                      name: 'Maximum Drinks',
                      value: maxDrinks.toString(),
                      updatedAt: updatedLabel,
                      onEdit: () => onEdit('maxDrinks'),
                    ),
                    const SizedBox(height: 8),
                    ConfigRow(
                      name: 'VAT',
                      value: '$vatPercent%',
                      updatedAt: updatedLabel,
                      onEdit: () => onEdit('vatPercent'),
                    ),
                    const SizedBox(height: 8),
                    ConfigRow(
                      name: 'Base Drink Price',
                      value: formatZarCents(baseDrinkPriceCents),
                      updatedAt: updatedLabel,
                      onEdit: () => onEdit('baseDrinkPriceCents'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConfigRow extends StatelessWidget {
  const ConfigRow({
    required this.name,
    required this.value,
    required this.updatedAt,
    required this.onEdit,
  });

  final String name;
  final String value;
  final String updatedAt;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(name)),
          const Expanded(flex: 2, child: Text('Config')),
          Expanded(flex: 2, child: Text(value)),
          Expanded(flex: 3, child: Text(updatedAt)),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                TextButton(onPressed: null, child: const Text('Delete')),
                TextButton(onPressed: onEdit, child: const Text('Edit')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
