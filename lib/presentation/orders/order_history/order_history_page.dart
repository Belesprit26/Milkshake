import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../di/locator.dart';
import '../../shared/widgets/app_form_container.dart';
import '../../shared/formatters/zar_format.dart';
import 'order_history_bloc.dart';
import '../confirm_order/confirm_order_page.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderHistoryBloc>()..add(const OrderHistoryStarted()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Order history')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: AppFormContainer(
            title: 'Order history',
            subtitle: 'Your saved drafts and orders.',
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
                if (state.items.isEmpty) {
                  return const Center(child: Text('No orders yet.'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<OrderHistoryBloc>().add(const OrderHistoryRefreshRequested());
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final o = state.items[i];
                      return ListTile(
                        title: Text('${o.pickupStoreName} • ${o.pickupTime}'),
                        subtitle: Text('Drinks: ${o.drinkCount} • Status: ${o.status.name}'),
                        trailing: Text(formatZar(o.total)),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ConfirmOrderPage(orderId: o.id)),
                          );
                        },
                      );
                    },
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


