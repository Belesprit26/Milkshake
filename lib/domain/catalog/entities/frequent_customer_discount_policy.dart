import 'package:equatable/equatable.dart';

import '../../../core/money/money.dart';
import 'discount_tier.dart';
import 'order_history_summary.dart';

class FrequentCustomerDiscountPolicy extends Equatable {
  const FrequentCustomerDiscountPolicy({
    required this.tiers,
    required this.maxDiscountAmount,
  });

  final List<DiscountTier> tiers;
  final Money maxDiscountAmount;

  int eligiblePercent(OrderHistorySummary summary) {
    var best = 0;
    for (final tier in tiers) {
      final meetsOrders = summary.paidOrdersCount >= tier.minPaidOrders;
      final meetsDrinks = summary.ordersWithAtLeastDrinks(tier.minDrinksPerOrder) >=
          tier.minPaidOrders;

      if (meetsOrders && meetsDrinks && tier.percentOff > best) {
        best = tier.percentOff;
      }
    }
    return best.clamp(0, 100);
  }

  @override
  List<Object?> get props => [tiers, maxDiscountAmount];
}


