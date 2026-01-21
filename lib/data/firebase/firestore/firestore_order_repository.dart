import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/error/failure.dart';
import '../../../core/money/money.dart';
import '../../../core/result/result.dart';
import '../../../domain/catalog/entities/config_snapshot.dart';
import '../../../domain/catalog/entities/discount_tier.dart';
import '../../../domain/catalog/entities/frequent_customer_discount_policy.dart';
import '../../../domain/catalog/entities/lookup_item_snapshot.dart';
import '../../../domain/catalog/entities/lookup_type.dart';
import '../../../domain/catalog/value_objects/drink_count.dart';
import '../../../domain/catalog/value_objects/vat_percent.dart';
import '../../../domain/orders/entities/drink_item.dart';
import '../../../domain/orders/entities/order_draft.dart';
import '../../../domain/orders/entities/order_list_item.dart';
import '../../../domain/orders/entities/order_status.dart';
import '../../../domain/orders/entities/order_totals.dart';
import '../../../domain/orders/repositories/order_repository.dart';

class FirestoreOrderRepository implements OrderRepository {
  FirestoreOrderRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Future<Result<OrderDraft>> createDraft(OrderDraft draft) async {
    try {
      final ref = _firestore.collection('orders').doc();
      final now = FieldValue.serverTimestamp();
      await ref.set({
        ..._toMap(draft),
        'createdAt': now,
        'updatedAt': now,
      });
      return Ok(draft.copyWith(id: ref.id));
    } catch (e) {
      return Err(UnexpectedFailure('Failed to create order draft: $e'));
    }
  }

  @override
  Future<Result<OrderDraft>> updateDraft(OrderDraft draft) async {
    try {
      final id = draft.id;
      if (id == null || id.isEmpty) {
        return Err(const ValidationFailure('Order draft id is missing.'));
      }
      final ref = _firestore.collection('orders').doc(id);
      await ref.update({
        ..._toMap(draft),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return Ok(draft);
    } catch (e) {
      return Err(UnexpectedFailure('Failed to update order draft: $e'));
    }
  }

  @override
  Future<Result<List<OrderListItem>>> listForUser(String uid) async {
    try {
      final q = await _firestore
          .collection('orders')
          .where('uid', isEqualTo: uid)
          .orderBy('updatedAt', descending: true)
          .limit(100)
          .get();

      final items = <OrderListItem>[];
      for (final doc in q.docs) {
        final data = doc.data();
        final statusStr = (data['status'] ?? '').toString();
        final status = _statusFromString(statusStr);

        final totals = data['totals'];
        final totalCents = totals is Map ? _readInt(totals['totalCents'], fallback: 0) : 0;

        final pickup = data['pickup'];
        final pickupStore = pickup is Map ? pickup['store'] : null;
        final pickupStoreName =
            pickupStore is Map ? (pickupStore['name'] ?? '').toString() : '';
        final pickupTime = pickup is Map ? (pickup['time'] ?? '').toString() : '';

        final updatedAt = data['updatedAt'];
        final updatedAtMillis = updatedAt is Timestamp ? updatedAt.millisecondsSinceEpoch : 0;

        final rawItems = data['items'];
        final drinkCount = rawItems is List ? rawItems.length : 0;

        items.add(
          OrderListItem(
            id: doc.id,
            status: status,
            total: Money(totalCents),
            updatedAtMillis: updatedAtMillis,
            drinkCount: drinkCount,
            pickupStoreName: pickupStoreName,
            pickupTime: pickupTime,
          ),
        );
      }

      return Ok(items);
    } catch (e) {
      return Err(UnexpectedFailure('Failed to load order history: $e'));
    }
  }

  @override
  Future<Result<OrderDraft>> getById(String orderId) async {
    try {
      final snap = await _firestore.collection('orders').doc(orderId).get();
      final data = snap.data();
      if (data == null) {
        return Err(const ValidationFailure('Order not found.'));
      }
      final draft = _fromMap(orderId: snap.id, data: data);
      return Ok(draft);
    } catch (e) {
      return Err(UnexpectedFailure('Failed to load order: $e'));
    }
  }

  @override
  Future<Result<void>> setStatus({required String orderId, required OrderStatus status}) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': _statusToString(status),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Ok(null);
    } catch (e) {
      return Err(UnexpectedFailure('Failed to update order status: $e'));
    }
  }

  Map<String, Object?> _toMap(OrderDraft draft) {
    return {
      'uid': draft.uid,
      'status': _statusToString(draft.status),
      'pickup': {
        'store': _lookupToMap(draft.pickupStore),
        'time': draft.pickupTime,
      },
      'configSnapshot': _configToMap(draft.configSnapshot),
      'items': draft.items.map(_drinkToMap).toList(),
      'totals': _totalsToMap(draft.totals),
    };
  }

  Map<String, Object?> _lookupToMap(LookupItemSnapshot s) {
    return {
      'id': s.id,
      'type': s.type.name,
      'name': s.name,
      'priceDeltaCents': s.priceDelta.cents,
    };
  }

  Map<String, Object?> _drinkToMap(DrinkItem d) {
    return {
      'flavour': _lookupToMap(d.flavour),
      'topping': _lookupToMap(d.topping),
      'consistency': _lookupToMap(d.consistency),
    };
  }

  Map<String, Object?> _totalsToMap(OrderTotals t) {
    return {
      'subtotalCents': t.subtotal.cents,
      'discountCents': t.discountAmount.cents,
      'taxableCents': t.taxableAmount.cents,
      'vatCents': t.vatAmount.cents,
      'totalCents': t.total.cents,
    };
  }

  Map<String, Object?> _configToMap(ConfigSnapshot c) {
    return {
      'version': c.version,
      'vatPercent': c.vatPercent.value,
      'maxDrinks': c.maxDrinks.value,
      'baseDrinkPriceCents': c.baseDrinkPrice.cents,
      'discount': {
        'maxDiscountCents': c.discountPolicy.maxDiscountAmount.cents,
        'tiers': c.discountPolicy.tiers
            .map((t) => {
                  'minPaidOrders': t.minPaidOrders,
                  'minDrinksPerOrder': t.minDrinksPerOrder,
                  'percentOff': t.percentOff,
                })
            .toList(),
      },
    };
  }

  String _statusToString(OrderStatus s) {
    return switch (s) {
      OrderStatus.draft => 'draft',
      OrderStatus.pendingPayment => 'pending_payment',
      OrderStatus.paid => 'paid',
      OrderStatus.cancelled => 'cancelled',
      OrderStatus.fulfilled => 'fulfilled',
    };
  }

  OrderStatus _statusFromString(String s) {
    return switch (s) {
      'draft' => OrderStatus.draft,
      'pending_payment' => OrderStatus.pendingPayment,
      'paid' => OrderStatus.paid,
      'cancelled' => OrderStatus.cancelled,
      'fulfilled' => OrderStatus.fulfilled,
      _ => OrderStatus.draft,
    };
  }

  int _readInt(Object? value, {required int fallback}) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  OrderDraft _fromMap({required String orderId, required Map<String, Object?> data}) {
    final uid = (data['uid'] ?? '').toString();
    final status = _statusFromString((data['status'] ?? '').toString());

    final pickup = data['pickup'];
    final pickupTime = pickup is Map ? (pickup['time'] ?? '12:00').toString() : '12:00';
    final pickupStoreRaw = pickup is Map ? pickup['store'] : null;
    final pickupStore = _lookupFromMap(pickupStoreRaw) ??
        const LookupItemSnapshot(
          id: 'unknown',
          type: LookupType.store,
          name: 'Unknown store',
          priceDelta: Money.zero,
        );

    final configRaw = data['configSnapshot'];
    final config = _configFromMap(configRaw) ??
        ConfigSnapshot(
          vatPercent: const VatPercent(15),
          maxDrinks: const DrinkCount(10),
          baseDrinkPrice: Money.zero,
          discountPolicy: const FrequentCustomerDiscountPolicy(
            tiers: [],
            maxDiscountAmount: Money.zero,
          ),
          version: null,
        );

    final itemsRaw = data['items'];
    final items = <DrinkItem>[];
    if (itemsRaw is List) {
      for (final i in itemsRaw) {
        if (i is! Map) continue;
        final flavour = _lookupFromMap(i['flavour']);
        final topping = _lookupFromMap(i['topping']);
        final consistency = _lookupFromMap(i['consistency']);
        if (flavour == null || topping == null || consistency == null) continue;
        items.add(DrinkItem(flavour: flavour, topping: topping, consistency: consistency));
      }
    }

    final totalsRaw = data['totals'];
    final totals = _totalsFromMap(totalsRaw) ??
        const OrderTotals(
          subtotal: Money.zero,
          discountAmount: Money.zero,
          taxableAmount: Money.zero,
          vatAmount: Money.zero,
          total: Money.zero,
        );

    return OrderDraft(
      id: orderId,
      uid: uid,
      status: status,
      configSnapshot: config,
      items: items,
      totals: totals,
      pickupStore: pickupStore,
      pickupTime: pickupTime,
    );
  }

  LookupItemSnapshot? _lookupFromMap(Object? raw) {
    if (raw is! Map) return null;
    final id = (raw['id'] ?? '').toString();
    final typeStr = (raw['type'] ?? '').toString();
    final name = (raw['name'] ?? '').toString();
    final cents = _readInt(raw['priceDeltaCents'], fallback: 0);
    if (id.isEmpty || name.isEmpty) return null;

    LookupType type;
    try {
      type = LookupType.values.byName(typeStr);
    } catch (_) {
      type = LookupType.flavour;
    }

    return LookupItemSnapshot(
      id: id,
      type: type,
      name: name,
      priceDelta: Money(cents),
    );
  }

  OrderTotals? _totalsFromMap(Object? raw) {
    if (raw is! Map) return null;
    return OrderTotals(
      subtotal: Money(_readInt(raw['subtotalCents'], fallback: 0)),
      discountAmount: Money(_readInt(raw['discountCents'], fallback: 0)),
      taxableAmount: Money(_readInt(raw['taxableCents'], fallback: 0)),
      vatAmount: Money(_readInt(raw['vatCents'], fallback: 0)),
      total: Money(_readInt(raw['totalCents'], fallback: 0)),
    );
  }

  ConfigSnapshot? _configFromMap(Object? raw) {
    if (raw is! Map) return null;

    final vat = _readInt(raw['vatPercent'], fallback: 15).clamp(0, 100);
    final maxDrinks = _readInt(raw['maxDrinks'], fallback: 10);
    final baseCents = _readInt(raw['baseDrinkPriceCents'], fallback: 0);
    final version = raw['version']?.toString();

    final discountRaw = raw['discount'];
    Money maxDiscount = Money.zero;
    final tiers = <DiscountTier>[];
    if (discountRaw is Map) {
      maxDiscount = Money(_readInt(discountRaw['maxDiscountCents'], fallback: 0));
      final tiersRaw = discountRaw['tiers'];
      if (tiersRaw is List) {
        for (final t in tiersRaw) {
          if (t is! Map) continue;
          final minPaidOrders = _readInt(t['minPaidOrders'], fallback: 0);
          final minDrinksPerOrder = _readInt(t['minDrinksPerOrder'], fallback: 0);
          final percentOff = _readInt(t['percentOff'], fallback: 0);
          if (minPaidOrders <= 0 || minDrinksPerOrder <= 0 || percentOff <= 0) continue;
          tiers.add(
            DiscountTier(
              minPaidOrders: minPaidOrders,
              minDrinksPerOrder: minDrinksPerOrder,
              percentOff: percentOff.clamp(0, 100),
            ),
          );
        }
      }
    }

    return ConfigSnapshot(
      vatPercent: VatPercent(vat),
      maxDrinks: DrinkCount(maxDrinks < 1 ? 1 : maxDrinks),
      baseDrinkPrice: Money(baseCents),
      discountPolicy: FrequentCustomerDiscountPolicy(
        tiers: tiers,
        maxDiscountAmount: maxDiscount,
      ),
      version: version,
    );
  }
}


