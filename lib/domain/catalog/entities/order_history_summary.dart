import 'package:equatable/equatable.dart';

class OrderHistorySummary extends Equatable {
  const OrderHistorySummary({
    required this.paidOrdersCount,
    required this.paidOrdersWithAtLeastDrinks,
  });

  final int paidOrdersCount;

  final Map<int, int> paidOrdersWithAtLeastDrinks;

  int ordersWithAtLeastDrinks(int minDrinks) =>
      paidOrdersWithAtLeastDrinks[minDrinks] ?? 0;

  @override
  List<Object?> get props => [paidOrdersCount, paidOrdersWithAtLeastDrinks];
}


