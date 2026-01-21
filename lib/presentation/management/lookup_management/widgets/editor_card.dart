import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milkshake/presentation/management/lookup_management/lookup_management_bloc.dart';
import 'package:milkshake/presentation/shared/widgets/app_dropdown_field.dart';
import 'package:milkshake/presentation/shared/widgets/app_text_field.dart';

class EditorCard extends StatefulWidget {
  const EditorCard({required this.state});

  final LookupManagementState state;

  @override
  State<EditorCard> createState() => _EditorCardState();
}

class _EditorCardState extends State<EditorCard> {
  late final TextEditingController _name;
  late final TextEditingController _value;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.state.formName);
    _value = TextEditingController(text: widget.state.formValue);
  }

  @override
  void didUpdateWidget(covariant EditorCard oldWidget) {
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


