import 'package:equatable/equatable.dart';

/// Immutable money value stored in minor units (cents).
///
/// - Avoids floating point issues.
/// - Currency formatting is intentionally out of scope for domain logic.
class Money extends Equatable implements Comparable<Money> {
  const Money(this.cents);

  final int cents;

  static const Money zero = Money(0);

  Money operator +(Money other) => Money(cents + other.cents);
  Money operator -(Money other) => Money(cents - other.cents);
  Money operator -() => Money(-cents);

  Money multipliedByInt(int factor) => Money(cents * factor);

  Money min(Money other) => cents <= other.cents ? this : other;
  Money max(Money other) => cents >= other.cents ? this : other;

  bool get isNegative => cents < 0;
  bool get isZero => cents == 0;

  @override
  int compareTo(Money other) => cents.compareTo(other.cents);

  @override
  List<Object?> get props => [cents];

  @override
  String toString() => 'Money(cents: $cents)';
}


