/// Formats prices in soles for UI (buyer / seller).
String formatSolesPrice(double price) {
  if (price % 1 == 0) return 's/${price.toInt()}';
  final s = price.toStringAsFixed(2);
  final trimmed = s
      .replaceAll(RegExp(r'0+$'), '')
      .replaceAll(RegExp(r'\.$'), '');
  return 's/$trimmed';
}
