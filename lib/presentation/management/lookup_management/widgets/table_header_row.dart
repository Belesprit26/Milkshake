import 'package:flutter/material.dart';

class TableHeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Name', style: style)),
          Expanded(flex: 2, child: Text('Type', style: style)),
          Expanded(flex: 2, child: Text('Value', style: style)),
          Expanded(flex: 3, child: Text('Last Updated', style: style)),
          Expanded(flex: 2, child: Text('Actions', style: style)),
        ],
      ),
    );
  }
}