/// Pure formatting helpers shared by the referee wallet screens.
///
/// The backend returns money as decimal strings that the data layer parses to
/// `double`. These helpers keep the Indian digit grouping used by the Figma
/// designs while staying honest for missing values (`—`) and non-INR
/// currencies.
library;

// ---------------------------------------------------------------------------
// Money formatting
// ---------------------------------------------------------------------------

/// Formats [rupees] using the Indian digit grouping (1,20,400 / 3,800).
///
/// The default renders `₹ 1,20,400`; pass `space: false` for Figma variants
/// such as `+₹1,000` and `₹1000`.
String formatIndianRupees(
  int rupees, {
  bool space = true,
  bool grouping = true,
}) {
  final negative = rupees < 0;
  final digits = rupees.abs().toString();
  final grouped = grouping ? _groupIndianDigits(digits) : digits;
  final symbol = space ? '₹ ' : '₹';
  return '${negative ? '-' : ''}$symbol$grouped';
}

/// Compact Indian money label used by the Total Earnings card (`₹ 8.40L`).
String formatIndianCompactRupees(int rupees) {
  final negative = rupees < 0;
  final value = rupees.abs();
  final sign = negative ? '-' : '';
  if (value >= 10000000) {
    return '₹ $sign${(value / 10000000).toStringAsFixed(2)}Cr';
  }
  if (value >= 100000) {
    return '₹ $sign${(value / 100000).toStringAsFixed(2)}L';
  }
  return formatIndianRupees(rupees);
}

/// Formats an API amount with the currency-aware grouping used by the wallet.
///
/// `null` renders an em dash so the UI never invents a balance. INR (or a
/// missing currency, the backend default) uses Indian grouping; every other
/// currency uses western grouping with the ISO code as prefix.
String formatCurrencyAmount(
  double? amount, {
  String? currency,
  bool space = true,
}) {
  if (amount == null) return '—';
  final negative = amount < 0;
  final absolute = amount.abs();
  final code = (currency ?? 'INR').trim().toUpperCase();
  final isIndian = code.isEmpty || code == 'INR';
  final symbol = isIndian ? (space ? '₹ ' : '₹') : '$code ';
  final number = _formatDecimal(absolute, indian: isIndian);
  return '${negative ? '-' : ''}$symbol$number';
}

/// Compact currency label used by the Total Earnings stat card.
///
/// Only INR is abbreviated (L / Cr); other currencies render in full so the
/// compact card never shows a misleading local abbreviation.
String formatCompactCurrencyAmount(double? amount, {String? currency}) {
  if (amount == null) return '—';
  final code = (currency ?? 'INR').trim().toUpperCase();
  final isIndian = code.isEmpty || code == 'INR';
  if (!isIndian) {
    return formatCurrencyAmount(amount, currency: currency);
  }
  final negative = amount < 0;
  final value = amount.abs();
  final sign = negative ? '-' : '';
  if (value >= 10000000) {
    return '$sign₹ ${(value / 10000000).toStringAsFixed(2)}Cr';
  }
  if (value >= 100000) {
    return '$sign₹ ${(value / 100000).toStringAsFixed(2)}L';
  }
  return formatCurrencyAmount(amount, currency: currency);
}

// ---------------------------------------------------------------------------
// Date / status formatting
// ---------------------------------------------------------------------------

const _monthLabels = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Parses an API date string, returning `null` for blank or invalid values.
DateTime? parseApiDate(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}

/// Formats an API date for the ledger. Invalid values are returned verbatim
/// rather than discarded, so no information is invented.
String? formatApiDate(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return null;
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  final local = parsed.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = _monthLabels[local.month - 1];
  final date = '$day $month ${local.year}';
  // Only append a time when the source actually carried one.
  if (!RegExp(r'\d{1,2}:\d{2}').hasMatch(value)) return date;
  final hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '$date, $hour12:$minute $period';
}

/// Humanises an API status token (`in_progress` -> `In Progress`).
///
/// A missing status renders `—`; no lifecycle value is inferred.
String formatStatusLabel(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return '—';
  final words = value
      .replaceAll(RegExp(r'[_-]+'), ' ')
      .toLowerCase()
      .split(' ')
      .where((word) => word.isNotEmpty);
  return words
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

// ---------------------------------------------------------------------------
// Digit grouping
// ---------------------------------------------------------------------------

String _formatDecimal(double value, {required bool indian}) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final integer = parts.first;
  final cents = parts.last;
  final grouped =
      indian ? _groupIndianDigits(integer) : _groupWesternDigits(integer);
  return cents == '00' ? grouped : '$grouped.$cents';
}

String _groupIndianDigits(String digits) {
  if (digits.length <= 3) return digits;
  final lastThree = digits.substring(digits.length - 3);
  var rest = digits.substring(0, digits.length - 3);
  final groups = <String>[];
  while (rest.length > 2) {
    groups.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) groups.insert(0, rest);
  return '${groups.join(',')},$lastThree';
}

String _groupWesternDigits(String digits) {
  if (digits.length <= 3) return digits;
  final groups = <String>[];
  var rest = digits;
  while (rest.length > 3) {
    groups.insert(0, rest.substring(rest.length - 3));
    rest = rest.substring(0, rest.length - 3);
  }
  if (rest.isNotEmpty) groups.insert(0, rest);
  return groups.join(',');
}
