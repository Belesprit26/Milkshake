import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../../../di/locator.dart';
import '../../../domain/catalog/entities/lookup_item_snapshot.dart';
import '../../shared/widgets/app_form_container.dart';
import '../../../domain/auth/usecases/sign_out.dart';
import '../../shared/widgets/app_dropdown_field.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/formatters/zar_format.dart';
import '../drafts/drafts_page.dart';
import '../order_history/order_history_page.dart';
import '../confirm_order/confirm_order_page.dart';
import 'order_draft_bloc.dart';

class OrderDraftPage extends StatelessWidget {
  const OrderDraftPage({super.key, this.orderId});

  final String? orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderDraftBloc>()..add(OrderDraftStarted(orderId: orderId)),
      child: const _OrderDraftView(),
    );
  }
}

class _OrderDraftView extends StatelessWidget {
  const _OrderDraftView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Milky Shaky'),
        actions: [
          IconButton(
            tooltip: 'Drafts',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DraftsPage()),
              );
            },
            icon: const Icon(Icons.edit_note),
          ),
          IconButton(
            tooltip: 'Orders',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
              );
            },
            icon: const Icon(Icons.receipt_long),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await getIt<SignOut>()();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocBuilder<OrderDraftBloc, OrderDraftState>(
        builder: (context, state) {
          if (state.status == OrderDraftStatus.loading ||
              state.status == OrderDraftStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == OrderDraftStatus.failure) {
            return const Center(child: Text('Failed to load config/lookups.'));
          }

          final totals = state.totals;
          final totalLabel = totals == null ? '-' : formatZar(totals.total);

          return AppFormContainer(
            title: 'Order Placement',
            subtitle: 'All fields compulsory.',
            padding: EdgeInsets.zero,
            expandChild: true,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _DrinkCountInput(),
                const SizedBox(height: 16),

                for (var i = 0; i < state.drinks.length; i++) ...[
                  _MilkshakeCard(key: ValueKey('milkshake_$i'), index: i),
                  const SizedBox(height: 16),
                ],

                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Total:', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    Text(totalLabel, style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                if (state.message != null) Text(state.message!),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: state.isSaving
                      ? null
                      : () => context.read<OrderDraftBloc>().add(const OrderDraftSavePressed()),
                  child: Text(state.isSaving ? 'Saving…' : 'Save draft'),
                ),
                if (state.orderId != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Order ID: ${state.orderId}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ConfirmOrderPage(orderId: state.orderId!),
                        ),
                      );
                    },
                    child: const Text('Review & confirm'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DrinkCountInput extends StatefulWidget {
  const _DrinkCountInput();

  @override
  State<_DrinkCountInput> createState() => _DrinkCountInputState();
}

class _DrinkCountInputState extends State<_DrinkCountInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() => _error = null);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderDraftBloc, OrderDraftState>(
      buildWhen: (p, n) => p.drinkCount != n.drinkCount || p.config != n.config,
      builder: (context, state) {
        final max = state.config?.maxDrinks.value ?? 10;

        if (!_focusNode.hasFocus) {
          final desired = state.drinkCount.toString();
          if (_controller.text != desired) _controller.text = desired;
        }

        return AppTextField(
          label: 'Number of Milkshakes Required?',
          hintText: 'Insert number',
          controller: _controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.done,
          errorText: _error,
          onChanged: (v) {
            final parsed = int.tryParse(v);
            if (parsed == null) {
              setState(() => _error = 'Numeric value only');
              return;
            }
            if (parsed < 1) {
              setState(() => _error = 'Minimum is 1');
              return;
            }
            if (parsed > max) {
              setState(() => _error = 'Maximum is $max');
              return;
            }
            setState(() => _error = null);
            context.read<OrderDraftBloc>().add(OrderDraftDrinkCountChanged(parsed));
          },
        );
      },
    );
  }
}

class _MilkshakeCard extends StatefulWidget {
  const _MilkshakeCard({super.key, required this.index});
  final int index;

  @override
  State<_MilkshakeCard> createState() => _MilkshakeCardState();
}

class _MilkshakeCardState extends State<_MilkshakeCard> {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Milkshake ${index + 1}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),

              Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                    ],
                  ),
                  if (_locked)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ClipRRect(
                          borderRadius: borderRadius,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withOpacity(0.55),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
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
        );
      },
    );
  }
}


