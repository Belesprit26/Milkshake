import 'package:equatable/equatable.dart';

import '../../../core/money/money.dart';
import 'order_status.dart';

/// Lightweight order list model for history screens.
class OrderListItem extends Equatable {
  const OrderListItem({
    required this.id,
    required this.status,
    required this.total,
    required this.updatedAtMillis,
    required this.drinkCount,
    required this.pickupStoreName,
    required this.pickupTime,
  });

  final String id;
  final OrderStatus status;
  final Money total;
  final int updatedAtMillis;
  final int drinkCount;
  final String pickupStoreName;
  final String pickupTime;

  @override
  List<Object?> get props => [
        id,
        status,
        total,
        updatedAtMillis,
        drinkCount,
        pickupStoreName,
        pickupTime,
      ];
}


