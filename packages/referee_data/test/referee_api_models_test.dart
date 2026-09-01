import 'package:flutter_test/flutter_test.dart';
import 'package:referee_data/referee_data.dart';

void main() {
  test('parses the populated referee application response', () {
    final application = RefereeApplicationResponse.fromJson({
      'application_number': 'REF-V2PJIK0I',
      'application_status': 2,
      'submitted_at': '2026-08-23 14:15:03',
      'personal_information': {
        'first_name': 'Sujith',
        'last_name': 'Reddy',
        'email': 'sujith@example.com',
        'mobile_number': '9700000201',
        'date_of_birth': '1999-08-21',
        'gender': 'male',
      },
      'address': {
        'address_line_1': 'Test address',
        'city': 'Hyderabad',
        'state': 'Telangana',
        'pincode': '500001',
        'country': 'India',
      },
      'sports': {
        'sport_ids': [1, 2],
        'experience_years': 4,
        'highest_qualification': 'State Level',
      },
      'availability': {
        'availability': ['monday', 'saturday'],
        'preferred_city': 'Hyderabad',
        'travel_radius': 25,
        'emergency_contact_name': 'Contact',
        'emergency_contact_number': '9700000202',
      },
      'documents': [
        {'id': 2, 'type': 2, 'file_url': 'https://example.com/id.png'},
      ],
      'timeline': [
        {
          'status': 2,
          'reason': 'Application submitted for review.',
          'date': '2026-08-23 14:15:03',
        },
      ],
    });

    expect(application.applicationNumber, 'REF-V2PJIK0I');
    expect(application.isPendingReview, isTrue);
    expect(application.sports.sportIds, [1, 2]);
    expect(application.availability.days, ['monday', 'saturday']);
    expect(application.documents.single.type, 2);
    expect(application.timeline.single.status, 2);
  });

  test('serializes request bodies with backend field names', () {
    const request = RefereeAvailabilityRequest(
      availability: ['monday'],
      preferredCity: 'Hyderabad',
      travelRadius: 25,
      emergencyContactName: 'Contact',
      emergencyContactNumber: '9700000202',
    );

    expect(request.toJson(), {
      'availability': ['monday'],
      'preferred_city': 'Hyderabad',
      'travel_radius': 25,
      'emergency_contact_name': 'Contact',
      'emergency_contact_number': '9700000202',
    });
  });
}
