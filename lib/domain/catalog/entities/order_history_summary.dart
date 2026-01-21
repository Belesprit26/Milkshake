import 'package:equatable/equatable.dart';

/// Minimal view of a patron's order history needed for discount eligibility.
///
/// Keep this "domain-shaped" so we can compute it from Firestore later.
class OrderHistorySummary extends Equatable {
  const OrderHistorySummary({
    required this.paidOrdersCount,
    required this.paidOrdersWithAtLeastDrinks,
  });

  final int paidOrdersCount;

  /// Map: drinks threshold -> number of paid orders with >= that drink count.
  final Map<int, int> paidOrdersWithAtLeastDrinks;

  int ordersWithAtLeastDrinks(int minDrinks) =>
      paidOrdersWithAtLeastDrinks[minDrinks] ?? 0;

  @override
  List<Object?> get props => [paidOrdersCount, paidOrdersWithAtLeastDrinks];
}


