import 'package:equatable/equatable.dart';

import '../../../core/money/money.dart';
import 'lookup_type.dart';

class LookupItem extends Equatable {
  const LookupItem({
    required this.id,
    required this.type,
    required this.name,
    required this.priceDelta,
    required this.active,
    required this.updatedAtMillis,
  });

  final String id;
  final LookupType type;
  final String name;
  final Money priceDelta;
  final bool active;
  final int updatedAtMillis;

  @override
  List<Object?> get props => [id, type, name, priceDelta, active, updatedAtMillis];
}


