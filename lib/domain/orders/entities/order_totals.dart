import 'package:equatable/equatable.dart';

import '../../../core/money/money.dart';

class OrderTotals extends Equatable {
  const OrderTotals({
    required this.subtotal,
    required this.discountAmount,
    required this.taxableAmount,
    required this.vatAmount,
    required this.total,
  });

  final Money subtotal;
  final Money discountAmount;
  final Money taxableAmount;
  final Money vatAmount;
  final Money total;

  @override
  List<Object?> get props => [subtotal, discountAmount, taxableAmount, vatAmount, total];
}


