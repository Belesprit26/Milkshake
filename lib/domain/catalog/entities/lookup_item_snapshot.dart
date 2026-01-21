import 'package:equatable/equatable.dart';

import '../../../core/money/money.dart';
import 'lookup_type.dart';

/// A snapshot of a lookup item (flavour/topping/consistency/store) captured at a
/// point in time, intended to be stored on orders so history does not change.
class LookupItemSnapshot extends Equatable {
  const LookupItemSnapshot({
    required this.id,
    required this.type,
    required this.name,
    required this.priceDelta,
  });

  final String id;
  final LookupType type;
  final String name;

  /// Price contribution for this lookup selection.
  final Money priceDelta;

  @override
  List<Object?> get props => [id, type, name, priceDelta];
}


