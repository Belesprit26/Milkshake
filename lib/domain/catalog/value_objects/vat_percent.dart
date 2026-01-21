import 'package:equatable/equatable.dart';

class VatPercent extends Equatable {
  const VatPercent(this.value) : assert(value >= 0 && value <= 100);

  final int value;

  @override
  List<Object?> get props => [value];
}


