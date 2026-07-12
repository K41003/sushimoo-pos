/// Safely converts a JSON value to a double.
///
/// The Laravel API returns DECIMAL columns as strings (e.g. "45000.00"),
/// so a naive `(json['x'] as num)` cast throws a CastError. This helper
/// accepts both [num] and [String] and falls back to [fallback] when the
/// value is missing or unparseable.
double parseDouble(dynamic value, [double fallback = 0.0]) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  final parsed = num.tryParse(value.toString());
  return parsed?.toDouble() ?? fallback;
}
