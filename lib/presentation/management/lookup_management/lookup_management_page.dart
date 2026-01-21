import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milkshake/di/locator.dart';
import 'package:milkshake/presentation/management/lookup_management/widgets/config_section.dart';
import 'package:milkshake/presentation/management/lookup_management/widgets/editor_card.dart';
import 'package:milkshake/presentation/management/lookup_management/widgets/lookup_section.dart';
import 'package:milkshake/presentation/shared/widgets/app_form_container.dart';
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
                        LookupTableCard(
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
                        LookupTableCard(
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
                        ConfigTableCard(
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
                        EditorCard(state: state),
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


