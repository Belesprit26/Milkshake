import 'package:flutter/material.dart';
import 'package:milkshake/domain/catalog/entities/lookup_item.dart';
import 'package:milkshake/domain/catalog/entities/lookup_type.dart';
import 'package:milkshake/presentation/management/lookup_management/widgets/table_header_row.dart';
import 'package:milkshake/presentation/shared/formatters/format_updated_at.dart';
import 'package:milkshake/presentation/shared/formatters/zar_format.dart';

class LookupTableCard extends StatelessWidget {
  const LookupTableCard({
    required this.title,
    required this.items,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final List<LookupItem> items;
  final VoidCallback onAdd;
  final ValueChanged<String> onEdit;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final show = items.where((x) => x.active).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final hidden = items.where((x) => !x.active).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final rows = [...show, ...hidden];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
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
                    for (final item in rows) LookupRow(item: item, onEdit: onEdit, onDelete: onDelete),
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


class LookupRow extends StatelessWidget {
  const LookupRow({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  final LookupItem item;
  final ValueChanged<String> onEdit;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final muted = !item.active;
    final textColor = muted ? Theme.of(context).colorScheme.onSurfaceVariant : null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(item.name, style: TextStyle(color: textColor)),
          ),
          Expanded(
            flex: 2,
            child: Text(_typeLabel(item.type), style: TextStyle(color: textColor)),
          ),
          Expanded(
            flex: 2,
            child: Text(formatZar(item.priceDelta), style: TextStyle(color: textColor)),
          ),
          Expanded(
            flex: 3,
            child: Text(formatUpdatedAt(item.updatedAtMillis), style: TextStyle(color: textColor)),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                TextButton(
                  onPressed: muted ? null : () => onDelete(item.id),
                  child: const Text('Delete'),
                ),
                TextButton(
                  onPressed: () => onEdit(item.id),
                  child: const Text('Edit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(LookupType t) {
    return switch (t) {
      LookupType.flavour => 'Flavour',
      LookupType.topping => 'Topping',
      LookupType.consistency => 'Consistency',
      LookupType.store => 'Store',
    };
  }
}