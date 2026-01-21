import 'package:flutter_test/flutter_test.dart';
import 'package:milkshake/core/money/money.dart';
import 'package:milkshake/domain/catalog/entities/config_snapshot.dart';
import 'package:milkshake/domain/catalog/entities/discount_tier.dart';
import 'package:milkshake/domain/catalog/entities/frequent_customer_discount_policy.dart';
import 'package:milkshake/domain/catalog/entities/lookup_item_snapshot.dart';
import 'package:milkshake/domain/catalog/entities/lookup_type.dart';
import 'package:milkshake/domain/catalog/entities/order_history_summary.dart';
import 'package:milkshake/domain/catalog/value_objects/drink_count.dart';
import 'package:milkshake/domain/catalog/value_objects/vat_percent.dart';
import 'package:milkshake/domain/orders/entities/drink_item.dart';
import 'package:milkshake/domain/orders/usecases/calculate_order_totals.dart';

void main() {
  group('CalculateOrderTotals', () {
    test('computes subtotal, discount, VAT, total (discount before VAT)', () {
      const calc = CalculateOrderTotals();

      final config = ConfigSnapshot(
        vatPercent: const VatPercent(15),
        maxDrinks: const DrinkCount(10),
        baseDrinkPrice: const Money(1000), // R10.00 base
        discountPolicy: FrequentCustomerDiscountPolicy(
          tiers: const [
            DiscountTier(minPaidOrders: 3, minDrinksPerOrder: 2, percentOff: 10),
          ],
          maxDiscountAmount: const Money(999999),
        ),
      );

      final flavour = LookupItemSnapshot(
        id: 'f1',
        type: LookupType.flavour,
        name: 'Vanilla',
        priceDelta: const Money(200), // +R2.00
      );
      final topping = LookupItemSnapshot(
        id: 't1',
        type: LookupType.topping,
        name: 'Oreo crumbs',
        priceDelta: const Money(300), // +R3.00
      );
      final consistency = LookupItemSnapshot(
        id: 'c1',
        type: LookupType.consistency,
        name: 'Thick',
        priceDelta: const Money(100), // +R1.00
      );

      final drinks = [
        DrinkItem(flavour: flavour, topping: topping, consistency: consistency),
        DrinkItem(flavour: flavour, topping: topping, consistency: consistency),
      ];

      // Eligible for 10% (>=3 paid orders, and >=3 orders with at least 2 drinks)
      final history = OrderHistorySummary(
        paidOrdersCount: 3,
        paidOrdersWithAtLeastDrinks: const {2: 3},
      );

      final totals = calc(
        drinks: drinks,
        config: config,
        history: history,
      );

      // Each drink: 1000 + 200 + 300 + 100 = 1600
      // Subtotal: 3200
      // Discount 10%: 320
      // Taxable: 2880
      // VAT 15%: 432
      // Total: 3312
      expect(totals.subtotal, const Money(3200));
      expect(totals.discountAmount, const Money(320));
      expect(totals.taxableAmount, const Money(2880));
      expect(totals.vatAmount, const Money(432));
      expect(totals.total, const Money(3312));
    });

    test('caps discount amount', () {
      const calc = CalculateOrderTotals();

      final config = ConfigSnapshot(
        vatPercent: const VatPercent(15),
        maxDrinks: const DrinkCount(10),
        baseDrinkPrice: const Money(1000),
        discountPolicy: FrequentCustomerDiscountPolicy(
          tiers: const [
            DiscountTier(minPaidOrders: 1, minDrinksPerOrder: 1, percentOff: 50),
          ],
          maxDiscountAmount: const Money(100), // cap at R1.00
        ),
      );

      final drink = DrinkItem(
        flavour: LookupItemSnapshot(
          id: 'f1',
          type: LookupType.flavour,
          name: 'Vanilla',
          priceDelta: const Money(0),
        ),
        topping: LookupItemSnapshot(
          id: 't1',
          type: LookupType.topping,
          name: 'None',
          priceDelta: const Money(0),
        ),
        consistency: LookupItemSnapshot(
          id: 'c1',
          type: LookupType.consistency,
          name: 'Milky',
          priceDelta: const Money(0),
        ),
      );

      final history = OrderHistorySummary(
        paidOrdersCount: 1,
        paidOrdersWithAtLeastDrinks: const {1: 1},
      );

      final totals = calc(
        drinks: [drink],
        config: config,
        history: history,
      );

      // Subtotal 1000, 50% would be 500, capped to 100.
      expect(totals.subtotal, const Money(1000));
      expect(totals.discountAmount, const Money(100));
    });
  });
}


