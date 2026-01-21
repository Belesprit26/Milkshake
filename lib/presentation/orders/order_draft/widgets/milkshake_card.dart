import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milkshake/domain/catalog/entities/lookup_item_snapshot.dart';
import 'package:milkshake/presentation/orders/order_draft/order_draft_bloc.dart';
import 'package:milkshake/presentation/shared/formatters/zar_format.dart';
import 'package:milkshake/presentation/shared/widgets/app_dropdown_field.dart';

class MilkshakeCard extends StatefulWidget {
  const MilkshakeCard({super.key, required this.index});
  final int index;

  @override
  State<MilkshakeCard> createState() => _MilkshakeCardState();
}

class _MilkshakeCardState extends State<MilkshakeCard> {
  bool _locked = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderDraftBloc, OrderDraftState>(
      buildWhen: (prev, next) => prev.drinks != next.drinks || prev.status != next.status,
      builder: (context, state) {
        final index = widget.index;
        final drink = state.drinks[index];
        final base = state.config?.baseDrinkPrice;
        final perDrink = base == null
            ? null
            : base + drink.flavour.priceDelta + drink.topping.priceDelta + drink.consistency.priceDelta;

        final borderRadius = BorderRadius.circular(16);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: borderRadius,
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Milkshake ${index + 1}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),

                  AppDropdownField<LookupItemSnapshot>(
                    label: 'Flavour',
                    value: drink.flavour,
                    items: state.flavours,
                    itemLabel: (x) => x.name,
                    enabled: !_locked,
                    onChanged: (v) {
                      if (v == null) return;
                      context.read<OrderDraftBloc>().add(
                        OrderDraftDrinkSelectionChanged(index: index, flavour: v),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  AppDropdownField<LookupItemSnapshot>(
                    label: 'Thick or Not',
                    value: drink.consistency,
                    items: state.consistencies,
                    itemLabel: (x) => x.name,
                    enabled: !_locked,
                    onChanged: (v) {
                      if (v == null) return;
                      context.read<OrderDraftBloc>().add(
                        OrderDraftDrinkSelectionChanged(index: index, consistency: v),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  AppDropdownField<LookupItemSnapshot>(
                    label: 'Topping',
                    value: drink.topping,
                    items: state.toppings,
                    itemLabel: (x) => x.name,
                    enabled: !_locked,
                    onChanged: (v) {
                      if (v == null) return;
                      context.read<OrderDraftBloc>().add(
                        OrderDraftDrinkSelectionChanged(index: index, topping: v),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Cost:', style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      Text(
                        perDrink == null ? '—' : formatZar(perDrink),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() => _locked = !_locked);
                    },
                    child: Text(_locked ? 'Edit' : 'Done'),
                  ),
                ],
              ),
              if (_locked)
                Positioned.fill(
                  left: -16,
                  right: -16,
                  top: 24,
                  bottom: 80,
                  child: IgnorePointer(
                    child: ClipRRect(
                      borderRadius: borderRadius,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

