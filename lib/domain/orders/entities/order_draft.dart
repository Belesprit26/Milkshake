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

  final ConfigSnapshot configSnapshot;

  final List<DrinkItem> items;

  final OrderTotals totals;

  final LookupItemSnapshot pickupStore;

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


