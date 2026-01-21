import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../di/locator.dart';
import '../../shared/widgets/app_form_container.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_dropdown_field.dart';
import '../../shared/formatters/zar_format.dart';
import '../../../domain/catalog/entities/lookup_item.dart';
import '../../../domain/catalog/entities/lookup_type.dart';
import 'lookup_management_bloc.dart';

class LookupManagementPage extends StatelessWidget {
  const LookupManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LookupManagementBloc>()..add(const LookupManagementStarted()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Lookup Management')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: AppFormContainer(
            title: 'Milkshake Selections',
            maxWidth: 1100,
            expandChild: true,
            padding: EdgeInsets.zero,
            child: BlocBuilder<LookupManagementBloc, LookupManagementState>(
              builder: (context, state) {
                if (state.status == LookupManagementStatus.loading ||
                    state.status == LookupManagementStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == LookupManagementStatus.unauthorized) {
                  return const Center(child: Text('Not authorized.'));
                }
                if (state.status == LookupManagementStatus.failure) {
                  return Center(child: Text(state.error ?? 'Failed to load.'));
                }

                return LayoutBuilder(
                  builder: (context, c) {
                    final main = ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _LookupTableCard(
                          title: 'Milkshake Flavours',
                          items: state.flavours,
                          onAdd: () => context.read<LookupManagementBloc>().add(
                                const LookupManagementAddNewPressed(ManagementSection.flavours),
                              ),
                          onEdit: (id) => context.read<LookupManagementBloc>().add(
                                LookupManagementEditPressed(ManagementSection.flavours, id),
                              ),
                          onDelete: (id) => context.read<LookupManagementBloc>().add(
                                LookupManagementDeletePressed(ManagementSection.flavours, id),
                              ),
                        ),
                        const SizedBox(height: 16),
                        _LookupTableCard(
                          title: 'Milkshake Toppings',
                          items: state.toppings,
                          onAdd: () => context.read<LookupManagementBloc>().add(
                                const LookupManagementAddNewPressed(ManagementSection.toppings),
                              ),
                          onEdit: (id) => context.read<LookupManagementBloc>().add(
                                LookupManagementEditPressed(ManagementSection.toppings, id),
                              ),
                          onDelete: (id) => context.read<LookupManagementBloc>().add(
                                LookupManagementDeletePressed(ManagementSection.toppings, id),
                              ),
                        ),
                        const SizedBox(height: 24),
                        Text('Config Values', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        _ConfigTableCard(
                          vatPercent: state.vatPercent,
                          maxDrinks: state.maxDrinks,
                          baseDrinkPriceCents: state.baseDrinkPriceCents,
                          updatedAtMillis: state.configUpdatedAtMillis,
                          onAdd: () => context.read<LookupManagementBloc>().add(
                                const LookupManagementAddNewPressed(ManagementSection.config),
                              ),
                          onEdit: (field) => context.read<LookupManagementBloc>().add(
                                LookupManagementEditPressed(ManagementSection.config, field),
                              ),
                        ),
                        const SizedBox(height: 16),
                        _EditorCard(state: state),
                      ],
                    );
                    return main;
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LookupTableCard extends StatelessWidget {
  const _LookupTableCard({
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
                    _TableHeaderRow(),
                    const SizedBox(height: 8),
                    for (final item in rows) _LookupRow(item: item, onEdit: onEdit, onDelete: onDelete),
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

class _TableHeaderRow extends StatelessWidget {
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

class _ConfigTableCard extends StatelessWidget {
  const _ConfigTableCard({
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
    final updatedLabel = _formatUpdatedAt(updatedAtMillis);
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
                    _TableHeaderRow(),
                    const SizedBox(height: 8),
                    _ConfigRow(
                      name: 'Maximum Drinks',
                      value: maxDrinks.toString(),
                      updatedAt: updatedLabel,
                      onEdit: () => onEdit('maxDrinks'),
                    ),
                    const SizedBox(height: 8),
                    _ConfigRow(
                      name: 'VAT',
                      value: '$vatPercent%',
                      updatedAt: updatedLabel,
                      onEdit: () => onEdit('vatPercent'),
                    ),
                    const SizedBox(height: 8),
                    _ConfigRow(
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

class _EditorCard extends StatefulWidget {
  const _EditorCard({required this.state});

  final LookupManagementState state;

  @override
  State<_EditorCard> createState() => _EditorCardState();
}

class _EditorCardState extends State<_EditorCard> {
  late final TextEditingController _name;
  late final TextEditingController _value;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.state.formName);
    _value = TextEditingController(text: widget.state.formValue);
  }

  @override
  void didUpdateWidget(covariant _EditorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changed = oldWidget.state.formId != widget.state.formId ||
        oldWidget.state.formSection != widget.state.formSection;
    if (changed) {
      _name.text = widget.state.formName;
      _value.text = widget.state.formValue;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final title = state.isEditing ? 'Edit' : 'Add New';

    final typeItems = const [
      ManagementSection.flavours,
      ManagementSection.toppings,
      ManagementSection.config,
    ];

    final typeLabel = (ManagementSection s) => switch (s) {
          ManagementSection.flavours => 'Flavour',
          ManagementSection.toppings => 'Topping',
          ManagementSection.config => 'Config',
        };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(width: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              if (state.error != null) ...[
                Text(
                  state.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 12),
              ],
              AppTextField(
                label: 'Name',
                hintText: 'Insert',
                controller: _name,
                onChanged: (v) => context.read<LookupManagementBloc>().add(
                      LookupManagementFormNameChanged(v),
                    ),
              ),
              const SizedBox(height: 12),
              AppDropdownField<ManagementSection>(
                label: 'Type',
                value: state.formSection,
                items: typeItems,
                itemLabel: typeLabel,
                enabled: !state.isEditing,
                onChanged: (v) {
                  if (v == null) return;
                  context.read<LookupManagementBloc>().add(LookupManagementFormTypeChanged(v));
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Value',
                hintText: 'Insert',
                controller: _value,
                onChanged: (v) => context.read<LookupManagementBloc>().add(
                      LookupManagementFormValueChanged(v),
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.read<LookupManagementBloc>().add(
                            const LookupManagementCancelPressed(),
                          ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: state.status == LookupManagementStatus.saving
                          ? null
                          : () => context.read<LookupManagementBloc>().add(
                                const LookupManagementSavePressed(),
                              ),
                      child: Text(state.status == LookupManagementStatus.saving ? 'Saving…' : 'Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LookupRow extends StatelessWidget {
  const _LookupRow({
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
            child: Text(_formatUpdatedAt(item.updatedAtMillis), style: TextStyle(color: textColor)),
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

class _ConfigRow extends StatelessWidget {
  const _ConfigRow({
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

String _formatUpdatedAt(int millis) {
  if (millis <= 0) return '-';
  final d = DateTime.fromMillisecondsSinceEpoch(millis);
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yyyy = d.year.toString().padLeft(4, '0');
  final hh = d.hour.toString().padLeft(2, '0');
  final min = d.minute.toString().padLeft(2, '0');
  return '$dd/$mm/$yyyy $hh:$min';
}


