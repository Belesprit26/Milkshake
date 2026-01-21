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

int parseZarToCents(String input) {
  final s = input.trim().replaceAll('R', '').replaceAll(' ', '');
  if (s.isEmpty) return 0;
  final neg = s.startsWith('-');
  final raw = neg ? s.substring(1) : s;
  final parts = raw.split('.');
  final whole = int.tryParse(parts[0].isEmpty ? '0' : parts[0]) ?? 0;
  final fracRaw = parts.length > 1 ? parts[1] : '';
  final frac = int.tryParse(fracRaw.padRight(2, '0').substring(0, 2)) ?? 0;
  final cents = whole * 100 + frac;
  return neg ? -cents : cents;
}


