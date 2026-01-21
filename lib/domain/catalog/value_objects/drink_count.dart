import 'package:equatable/equatable.dart';

class DrinkCount extends Equatable {
  const DrinkCount(this.value) : assert(value >= 1);

  final int value;

  bool allows(int count) => count >= 1 && count <= value;

  @override
  List<Object?> get props => [value];
}


