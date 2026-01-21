import 'package:equatable/equatable.dart';

import '../../../core/money/money.dart';
import 'lookup_type.dart';

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

  final Money priceDelta;

  @override
  List<Object?> get props => [id, type, name, priceDelta];
}


