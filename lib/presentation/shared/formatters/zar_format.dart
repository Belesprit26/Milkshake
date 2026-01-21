import '../../../core/money/money.dart';

String formatZar(Money money) => formatZarCents(money.cents);

String formatZarCents(int cents) {
  final isNeg = cents < 0;
  final abs = cents.abs();
  final rands = abs ~/ 100;
  final rem = abs % 100;
  final formatted = 'R$rands.${rem.toString().padLeft(2, '0')}';
  return isNeg ? '-$formatted' : formatted;
}


