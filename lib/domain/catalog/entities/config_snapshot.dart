import 'package:equatable/equatable.dart';

import '../../../core/money/money.dart';
import '../value_objects/drink_count.dart';
import '../value_objects/vat_percent.dart';
import 'frequent_customer_discount_policy.dart';

/// The pricing/config snapshot that should be stored on an order.
class ConfigSnapshot extends Equatable {
  const ConfigSnapshot({
    required this.vatPercent,
    required this.maxDrinks,
    required this.discountPolicy,
    this.baseDrinkPrice = Money.zero,
    this.version,
  });

  final VatPercent vatPercent;
  final DrinkCount maxDrinks;
  final FrequentCustomerDiscountPolicy discountPolicy;

  /// Optional base price added to every drink (if your pricing model needs it).
  final Money baseDrinkPrice;

  /// Optional version identifier for traceability.
  final String? version;

  @override
  List<Object?> get props => [
        vatPercent,
        maxDrinks,
        discountPolicy,
        baseDrinkPrice,
        version,
      ];
}


