import '../../../core/money/money.dart';
import '../../catalog/entities/config_snapshot.dart';
import '../../catalog/entities/order_history_summary.dart';
import '../entities/drink_item.dart';
import '../entities/order_totals.dart';

class CalculateOrderTotals {
  const CalculateOrderTotals();

  /// Calculates totals for a set of drinks using a config snapshot.
  ///
  /// Discount is applied to subtotal first; VAT is calculated on the discounted
  /// amount (taxableAmount). This can be adjusted later if requirements differ.
  OrderTotals call({
    required List<DrinkItem> drinks,
    required ConfigSnapshot config,
    required OrderHistorySummary history,
  }) {
    final subtotal = _calculateSubtotal(drinks: drinks, baseDrinkPrice: config.baseDrinkPrice);

    final discountPercent = config.discountPolicy.eligiblePercent(history);
    final rawDiscount = _percentOf(subtotal, discountPercent);
    final discountAmount = rawDiscount.min(config.discountPolicy.maxDiscountAmount).max(Money.zero);

    final taxableAmount = (subtotal - discountAmount).max(Money.zero);
    final vatAmount = _percentOf(taxableAmount, config.vatPercent.value).max(Money.zero);
    final total = taxableAmount + vatAmount;

    return OrderTotals(
      subtotal: subtotal,
      discountAmount: discountAmount,
      taxableAmount: taxableAmount,
      vatAmount: vatAmount,
      total: total,
    );
  }

  Money _calculateSubtotal({
    required List<DrinkItem> drinks,
    required Money baseDrinkPrice,
  }) {
    var sum = Money.zero;
    for (final d in drinks) {
      sum = sum +
          baseDrinkPrice +
          d.flavour.priceDelta +
          d.topping.priceDelta +
          d.consistency.priceDelta;
    }
    return sum;
  }

  /// Returns (amount * percent) rounded to nearest cent, half-up.
  Money _percentOf(Money amount, int percent) {
    if (percent <= 0 || amount.isZero) return Money.zero;
    final p = percent.clamp(0, 100);
    final numerator = amount.cents * p;
    final rounded = (numerator + 50) ~/ 100;
    return Money(rounded);
  }
}


