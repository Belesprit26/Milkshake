String formatUpdatedAt(int millis) {
  if (millis <= 0) return '-';
  final d = DateTime.fromMillisecondsSinceEpoch(millis);
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final yyyy = d.year.toString().padLeft(4, '0');
  final hh = d.hour.toString().padLeft(2, '0');
  final min = d.minute.toString().padLeft(2, '0');
  return '$dd/$mm/$yyyy $hh:$min';
}