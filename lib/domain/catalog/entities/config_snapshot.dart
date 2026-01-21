import 'package:equatable/equatable.dart';

import '../../../core/money/money.dart';
import '../value_objects/drink_count.dart';
import '../value_objects/vat_percent.dart';
import 'frequent_customer_discount_policy.dart';

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

  final Money baseDrinkPrice;

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


