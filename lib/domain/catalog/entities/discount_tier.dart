import 'package:equatable/equatable.dart';

class DiscountTier extends Equatable {
  const DiscountTier({
    required this.minPaidOrders,
    required this.minDrinksPerOrder,
    required this.percentOff,
  });

  final int minPaidOrders;
  final int minDrinksPerOrder;
  final int percentOff;

  @override
  List<Object?> get props => [minPaidOrders, minDrinksPerOrder, percentOff];
}


