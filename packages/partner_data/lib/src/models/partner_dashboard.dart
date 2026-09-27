/// Dashboard aggregates are server totals, independent of the tournament page.
class PartnerDashboard {
  PartnerDashboard.fromJson(Map<String, dynamic> json)
      : summary = _map(json['summary']),
        tournaments = _items(json['tournaments']),
        pagination = _map(json['tournaments'] is Map
            ? json['tournaments']
            : json['pagination']);

  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> tournaments;
  final Map<String, dynamic> pagination;

  num? value(String key) {
    Object? raw = summary[key];
    for (final group in ['tournaments', 'matches', 'registrations']) {
      raw ??= _map(summary[group])[key];
    }
    return raw is num ? raw : num.tryParse(raw?.toString() ?? '');
  }

  String count(String key) => value(key)?.toInt().toString() ?? '—';

  String get revenueLabel {
    final raw = summary['revenue'] ?? summary['total_revenue'];
    final amount = raw is Map ? raw['amount'] : raw;
    final number = amount is num ? amount : num.tryParse('$amount');
    if (number == null) return '—';
    final currency = raw is Map ? raw['currency'] ?? 'INR' : 'INR';
    return '$currency ${number.toStringAsFixed(2)}';
  }

  static Map<String, dynamic> _map(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : {};

  static List<Map<String, dynamic>> _items(Object? value) {
    final items = value is Map ? value['data'] : value;
    return items is List
        ? items
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList()
        : [];
  }
}
