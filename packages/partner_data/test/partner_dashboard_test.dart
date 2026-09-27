import 'package:flutter_test/flutter_test.dart';
import 'package:partner_data/partner_data.dart';

void main() {
  test('summary totals are independent of paginated tournaments', () {
    final dashboard = PartnerDashboard.fromJson({
      'summary': {'total_tournaments': '42', 'total_matches': 100,
        'total_registrations': 250, 'revenue': {'amount': '8000.50', 'currency': 'INR'}},
      'tournaments': {'data': [{'id': 62, 'counts': {'teams': 10}}],
        'current_page': 2, 'last_page': 3}
    });
    expect(dashboard.count('total_tournaments'), '42');
    expect(dashboard.tournaments.length, 1);
    expect(dashboard.pagination['current_page'], 2);
    expect(dashboard.revenueLabel, 'INR 8000.50');
  });
  test('missing metrics are unavailable, explicit zeros remain zero', () {
    final dashboard = PartnerDashboard.fromJson({'summary': {'total_matches': 0}});
    expect(dashboard.count('total_matches'), '0');
    expect(dashboard.count('total_tournaments'), '—');
    expect(dashboard.revenueLabel, '—');
  });
  test('only approved application status grants dashboard access', () {
    expect(PartnerApplicationWorkflowStatus.fromValue(4), PartnerApplicationWorkflowStatus.approved);
    for (final code in [1, 2, 3, 5, 99]) {
      expect(PartnerApplicationWorkflowStatus.fromValue(code), isNot(PartnerApplicationWorkflowStatus.approved));
    }
  });
}
