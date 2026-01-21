import 'package:equatable/equatable.dart';

import '../../catalog/entities/config_snapshot.dart';
import '../../catalog/entities/lookup_item_snapshot.dart';
import 'drink_item.dart';
import 'order_status.dart';
import 'order_totals.dart';

class OrderDraft extends Equatable {
  const OrderDraft({
    required this.uid,
    required this.status,
    required this.configSnapshot,
    required this.items,
    required this.totals,
    required this.pickupStore,
    required this.pickupTime,
    this.id,
  });

  final String? id;
  final String uid;
  final OrderStatus status;

  /// Captured pricing snapshot used to compute totals.
  final ConfigSnapshot configSnapshot;

  /// One "DRINK DETAIL" container per drink.
  final List<DrinkItem> items;

  final OrderTotals totals;

  /// Store selection snapshot (type=store).
  final LookupItemSnapshot pickupStore;

  /// ISO-like "HH:mm" for now; we can evolve this later (DateTime + timezone).
  final String pickupTime;

  OrderDraft copyWith({
    String? id,
    OrderStatus? status,
    List<DrinkItem>? items,
    OrderTotals? totals,
    LookupItemSnapshot? pickupStore,
    String? pickupTime,
  }) {
    return OrderDraft(
      id: id ?? this.id,
      uid: uid,
      status: status ?? this.status,
      configSnapshot: configSnapshot,
      items: items ?? this.items,
      totals: totals ?? this.totals,
      pickupStore: pickupStore ?? this.pickupStore,
      pickupTime: pickupTime ?? this.pickupTime,
    );
  }

  @override
  List<Object?> get props => [
        id,
        uid,
        status,
        configSnapshot,
        items,
        totals,
        pickupStore,
        pickupTime,
      ];
}


