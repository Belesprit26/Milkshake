import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:milkshake/di/locator.dart';
import 'package:milkshake/domain/auth/usecases/sign_out.dart';
import 'package:milkshake/presentation/management/lookup_management/lookup_management_page.dart';
import 'package:milkshake/presentation/orders/confirm_order/confirm_order_page.dart';
import 'package:milkshake/presentation/orders/drafts/drafts_page.dart';
import 'package:milkshake/presentation/orders/order_draft/widgets/drink_count.dart';
import 'package:milkshake/presentation/orders/order_draft/widgets/milkshake_card.dart';
import 'package:milkshake/presentation/orders/order_history/order_history_page.dart';
import 'package:milkshake/presentation/shared/formatters/zar_format.dart';
import 'package:milkshake/presentation/shared/widgets/app_form_container.dart';


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
            tooltip: 'Lookup management',
            onPressed: () async {
              final bloc = context.read<OrderDraftBloc>();
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LookupManagementPage()),
              );
              if (bloc.isClosed) return;
              bloc.add(OrderDraftStarted(orderId: bloc.state.orderId));
            },
            icon: const Icon(Icons.admin_panel_settings),
          ),
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
                const DrinkCountInput(),
                const SizedBox(height: 16),

                for (var i = 0; i < state.drinks.length; i++) ...[
                  MilkshakeCard(key: ValueKey('milkshake_$i'), index: i),
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



