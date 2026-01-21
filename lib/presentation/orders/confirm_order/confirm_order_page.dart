import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../di/locator.dart';
import '../../shared/widgets/app_form_container.dart';
import '../../shared/widgets/app_text_field.dart';
import 'confirm_order_bloc.dart';
import '../../../domain/orders/entities/order_status.dart';
import '../../shared/formatters/zar_format.dart';

class ConfirmOrderPage extends StatelessWidget {
  const ConfirmOrderPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ConfirmOrderBloc>()..add(ConfirmOrderStarted(orderId)),
      child: BlocListener<ConfirmOrderBloc, ConfirmOrderState>(
        listenWhen: (p, n) => p.checkoutUrl != n.checkoutUrl && n.checkoutUrl != null,
        listener: (context, state) async {
          final url = state.checkoutUrl;
          if (url == null) return;
          final uri = Uri.tryParse(url);
          if (uri == null) return;
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Order Summary')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: AppFormContainer(
              title: 'Confirm order',
              subtitle: 'Review your draft and continue to payment.',
              expandChild: true,
              padding: EdgeInsets.zero,
              child: BlocBuilder<ConfirmOrderBloc, ConfirmOrderState>(
                builder: (context, state) {
                if (state.status == ConfirmOrderStatus.loading ||
                    state.status == ConfirmOrderStatus.initial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.status == ConfirmOrderStatus.failure) {
                  return Center(child: Text(state.error ?? 'Failed to load order.'));
                }

                final order = state.order!;
                final vatPercent = order.configSnapshot.vatPercent.value;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Milky Shaky', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Divider(color: Colors.black.withValues(alpha: 0.08)),
                    const SizedBox(height: 8),

                    _SummaryRow(label: 'Number of Drinks', value: '${order.items.length}'),
                    const SizedBox(height: 8),
                    _SummaryRow(label: 'Subtotal', value: formatZar(order.totals.subtotal)),
                    const SizedBox(height: 8),
                    _SummaryRow(label: 'VAT ($vatPercent%)', value: formatZar(order.totals.vatAmount)),

                    const SizedBox(height: 12),
                    Divider(color: Colors.black.withValues(alpha: 0.08)),
                    const SizedBox(height: 12),

                    AppTextField(
                      label: 'Frequent Customer Discount',
                      hintText: 'Insert',
                      initialValue: formatZar(order.totals.discountAmount),
                      readOnly: true,
                      enabled: false,
                    ),

                    const SizedBox(height: 12),
                    _SummaryRow(
                      label: 'Total cost',
                      value: formatZar(order.totals.total),
                      emphasize: true,
                    ),
                    const SizedBox(height: 16),

                    FilledButton(
                      onPressed: state.status == ConfirmOrderStatus.submitting
                          ? null
                          : () {
                              if (order.status == OrderStatus.draft) {
                                context.read<ConfirmOrderBloc>().add(const ConfirmOrderPressed());
                              } else if (order.status == OrderStatus.pendingPayment) {
                                context.read<ConfirmOrderBloc>().add(const ConfirmOrderPayPressed());
                              }
                            },
                      child: Text(
                        state.status == ConfirmOrderStatus.submitting ? 'Working…' : 'Continue',
                      ),
                    ),

                    const SizedBox(height: 12),
                    Text(
                      'Continue when all data captured',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),

                    if (state.error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        state.error!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                  ],
                );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = emphasize ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium;
    final valueStyle = emphasize ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium;
    return Row(
      children: [
        Text(label, style: labelStyle),
        const Spacer(),
        Text(value, style: valueStyle),
      ],
    );
  }
}


