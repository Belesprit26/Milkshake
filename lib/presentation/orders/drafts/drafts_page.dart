import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../di/locator.dart';
import '../../shared/widgets/app_form_container.dart';
import '../../shared/formatters/zar_format.dart';
import '../../shared/widgets/app_tile_card.dart';
import '../order_draft/order_draft_page.dart';
import '../order_history/order_history_bloc.dart';
import '../confirm_order/confirm_order_page.dart';
import '../../../domain/orders/entities/order_status.dart';

class DraftsPage extends StatelessWidget {
  const DraftsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderHistoryBloc>()..add(const OrderHistoryStarted()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Drafts')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: AppFormContainer(
            title: 'Drafts',
            subtitle: 'Saved drafts (not yet confirmed).',
            expandChild: true,
            padding: EdgeInsets.zero,
            child: BlocBuilder<OrderHistoryBloc, OrderHistoryState>(
              builder: (context, state) {
                if (state.status == OrderHistoryStatus.loading ||
                    state.status == OrderHistoryStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == OrderHistoryStatus.failure) {
                  return Center(child: Text(state.error ?? 'Failed to load drafts.'));
                }

                final drafts = state.items.where((o) => o.status == OrderStatus.draft).toList();
                if (drafts.isEmpty) {
                  return const Center(child: Text('No drafts yet.'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<OrderHistoryBloc>().add(const OrderHistoryRefreshRequested());
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: drafts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final o = drafts[i];
                      return AppTileCard(
                        title: Text('${o.pickupStoreName} • ${o.pickupTime}'),
                        subtitle: Text('Drinks: ${o.drinkCount} • Draft'),
                        trailing: Text(formatZar(o.total)),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => OrderDraftPage(orderId: o.id)),
                          );
                        },
                        onLongPress: () {
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


