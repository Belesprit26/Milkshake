import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../di/locator.dart';
import '../../shared/widgets/app_form_container.dart';
import '../../shared/formatters/zar_format.dart';
import '../../shared/widgets/app_tile_card.dart';
import 'order_history_bloc.dart';
import '../confirm_order/confirm_order_page.dart';
import '../../../domain/orders/entities/order_status.dart';
import '../../../domain/orders/entities/order_list_item.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderHistoryBloc>()..add(const OrderHistoryStarted()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Orders')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: AppFormContainer(
            title: 'Orders',
            subtitle: 'Confirmed orders (payment pending) and successful orders.',
            expandChild: true,
            padding: EdgeInsets.zero,
            child: BlocBuilder<OrderHistoryBloc, OrderHistoryState>(
              builder: (context, state) {
                if (state.status == OrderHistoryStatus.loading ||
                    state.status == OrderHistoryStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == OrderHistoryStatus.failure) {
                  return Center(child: Text(state.error ?? 'Failed to load orders.'));
                }
                final nonDraft = state.items.where((o) => o.status != OrderStatus.draft).toList();
                final pending = nonDraft.where((o) => o.status == OrderStatus.pendingPayment).toList();
                final history = nonDraft.where((o) => o.status != OrderStatus.pendingPayment).toList();

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<OrderHistoryBloc>().add(const OrderHistoryRefreshRequested());
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (nonDraft.isEmpty) const Center(child: Text('No orders yet.')),

                      if (pending.isNotEmpty) ...[
                        Text('Pending payment', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        ...pending.map((o) => _OrderTile(o)).toList(),
                        const SizedBox(height: 16),
                      ],

                      if (history.isNotEmpty) ...[
                        Text('Order history', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        ...history.map((o) => _OrderTile(o)).toList(),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile(this.o);
  final OrderListItem o;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppTileCard(
        title: Text('${o.pickupStoreName} • ${o.pickupTime}'),
        subtitle: Text('Drinks: ${o.drinkCount} • Status: ${o.status.name}'),
        trailing: Text(formatZar(o.total)),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ConfirmOrderPage(orderId: o.id)),
          );
        },
      ),
    );
  }
}


