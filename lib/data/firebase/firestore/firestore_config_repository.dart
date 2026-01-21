import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/money/money.dart';
import '../../../core/result/result.dart';
import '../../../core/error/failure.dart';
import '../../../domain/catalog/entities/config_snapshot.dart';
import '../../../domain/catalog/entities/discount_tier.dart';
import '../../../domain/catalog/entities/frequent_customer_discount_policy.dart';
import '../../../domain/catalog/repositories/config_repository.dart';
import '../../../domain/catalog/value_objects/drink_count.dart';
import '../../../domain/catalog/value_objects/vat_percent.dart';

/// Firestore-backed config repository.
///
/// Suggested document:
/// - Collection: `config`
/// - Document: `current`
/// - Fields:
///   - vatPercent (number)
///   - maxDrinks (number)
///   - baseDrinkPriceCents (number)
///   - version (string)
///   - discount:
///       - maxDiscountCents (number)
///       - tiers (array of maps: { minPaidOrders, minDrinksPerOrder, percentOff })
class FirestoreConfigRepository implements ConfigRepository {
  FirestoreConfigRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<Result<ConfigSnapshot>> getCurrentConfig() async {
    try {
      final snap = await _firestore.collection('config').doc('current').get();
      final data = snap.data();
      if (data == null) {
        return Err(const ValidationFailure('Missing config/current in Firestore.'));
      }

      final vat = _readInt(data['vatPercent'], fallback: 15).clamp(0, 100);
      final maxDrinks = _readInt(data['maxDrinks'], fallback: 10);
      final baseCents = _readInt(data['baseDrinkPriceCents'], fallback: 0);
      final version = data['version'] as String?;

      final discountMap = data['discount'];
      final discountPolicy = _parseDiscountPolicy(discountMap);

      return Ok(
        ConfigSnapshot(
          vatPercent: VatPercent(vat),
          maxDrinks: DrinkCount(maxDrinks < 1 ? 1 : maxDrinks),
          baseDrinkPrice: Money(baseCents),
          discountPolicy: discountPolicy,
          version: version,
        ),
      );
    } catch (e) {
      return Err(UnexpectedFailure('Failed to load config: $e'));
    }
  }

  FrequentCustomerDiscountPolicy _parseDiscountPolicy(Object? raw) {
    if (raw is! Map) {
      return const FrequentCustomerDiscountPolicy(
        tiers: [],
        maxDiscountAmount: Money.zero,
      );
    }
    final maxDiscountCents = _readInt(raw['maxDiscountCents'], fallback: 0);

    final tiersRaw = raw['tiers'];
    final tiers = <DiscountTier>[];
    if (tiersRaw is List) {
      for (final t in tiersRaw) {
        if (t is! Map) continue;
        final minPaidOrders = _readInt(t['minPaidOrders'], fallback: 0);
        final minDrinksPerOrder = _readInt(t['minDrinksPerOrder'], fallback: 0);
        final percentOff = _readInt(t['percentOff'], fallback: 0);
        if (minPaidOrders <= 0 || minDrinksPerOrder <= 0 || percentOff <= 0) {
          continue;
        }
        tiers.add(
          DiscountTier(
            minPaidOrders: minPaidOrders,
            minDrinksPerOrder: minDrinksPerOrder,
            percentOff: percentOff.clamp(0, 100),
          ),
        );
      }
    }

    return FrequentCustomerDiscountPolicy(
      tiers: tiers,
      maxDiscountAmount: Money(maxDiscountCents < 0 ? 0 : maxDiscountCents),
    );
  }

  int _readInt(Object? value, {required int fallback}) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}


