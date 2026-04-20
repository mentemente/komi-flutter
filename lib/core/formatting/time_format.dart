/// Converts `"06:30"` / `"23:55"` to text like `6:30 am` for banners.
String formatTime12hFrom24(String time24) {
  if (time24.isEmpty) return '';
  final parts = time24.split(':');
  if (parts.length < 2) return time24;
  final h = int.tryParse(parts[0]) ?? 0;
  final m = int.tryParse(parts[1]) ?? 0;
  final period = h >= 12 ? 'pm' : 'am';
  final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
  if (m == 0) return '$h12 $period';
  return '$h12:${m.toString().padLeft(2, '0')} $period';
}
