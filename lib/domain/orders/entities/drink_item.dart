import 'package:equatable/equatable.dart';

import '../../catalog/entities/lookup_item_snapshot.dart';

class DrinkItem extends Equatable {
  const DrinkItem({
    required this.flavour,
    required this.topping,
    required this.consistency,
  });

  final LookupItemSnapshot flavour;
  final LookupItemSnapshot topping;
  final LookupItemSnapshot consistency;

  @override
  List<Object?> get props => [flavour, topping, consistency];
}


