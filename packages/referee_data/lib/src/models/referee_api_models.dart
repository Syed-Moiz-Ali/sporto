int _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _stringValue(Object? value) => value?.toString();

Map<String, dynamic> _mapValue(Object? value) {
  return value is Map ? Map<String, dynamic>.from(value) : const {};
}

List<dynamic> _listValue(Object? value) => value is List ? value : const [];

class RefereePersonalRequest {
  const RefereePersonalRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String dateOfBirth;
  final String gender;

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'date_of_birth': dateOfBirth,
        'gender': gender,
      };
}

class RefereeAddressRequest {
  const RefereeAddressRequest({
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
  });

  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String country;

  Map<String, dynamic> toJson() => {
        'address_line_1': addressLine1,
        if (addressLine2 != null) 'address_line_2': addressLine2,
        'city': city,
        'state': state,
        'pincode': pincode,
        'country': country,
      };
}

class RefereeSportsRequest {
  const RefereeSportsRequest({
    required this.sportIds,
    required this.experienceYears,
    required this.highestQualification,
  });

  final List<int> sportIds;
  final int experienceYears;
  final String highestQualification;

  Map<String, dynamic> toJson() => {
        'sport_ids': sportIds,
        'experience_years': experienceYears,
        'highest_qualification': highestQualification,
      };
}

class RefereeAvailabilityRequest {
  const RefereeAvailabilityRequest({
    required this.availability,
    required this.preferredCity,
    required this.travelRadius,
    required this.emergencyContactName,
    required this.emergencyContactNumber,
  });

  final List<String> availability;
  final String preferredCity;
  final int travelRadius;
  final String emergencyContactName;
  final String emergencyContactNumber;

  Map<String, dynamic> toJson() => {
        'availability': availability,
        'preferred_city': preferredCity,
        'travel_radius': travelRadius,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_number': emergencyContactNumber,
      };
}

class RefereeDocumentRequest {
  const RefereeDocumentRequest({
    required this.type,
    required this.filePath,
  });

  final int type;
  final String filePath;

  Map<String, dynamic> toJson() => {'type': type, 'file_path': filePath};
}

class RefereePersonalInformation {
  const RefereePersonalInformation({
    this.firstName,
    this.lastName,
    this.email,
    this.mobileNumber,
    this.dateOfBirth,
    this.gender,
  });

  final String? firstName;
  final String? lastName;
  final String? email;
  final String? mobileNumber;
  final String? dateOfBirth;
  final String? gender;

  factory RefereePersonalInformation.fromJson(Map<String, dynamic> json) =>
      RefereePersonalInformation(
        firstName: _stringValue(json['first_name']),
        lastName: _stringValue(json['last_name']),
        email: _stringValue(json['email']),
        mobileNumber: _stringValue(json['mobile_number']),
        dateOfBirth: _stringValue(json['date_of_birth']),
        gender: _stringValue(json['gender']),
      );
}

class RefereeAddress {
  const RefereeAddress({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.pincode,
    this.country,
  });

  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;

  factory RefereeAddress.fromJson(Map<String, dynamic> json) => RefereeAddress(
        addressLine1: _stringValue(json['address_line_1']),
        addressLine2: _stringValue(json['address_line_2']),
        city: _stringValue(json['city']),
        state: _stringValue(json['state']),
        pincode: _stringValue(json['pincode']),
        country: _stringValue(json['country']),
      );
}

class RefereeSportsInformation {
  const RefereeSportsInformation({
    this.sportIds = const [],
    this.experienceYears = 0,
    this.highestQualification,
  });

  final List<int> sportIds;
  final int experienceYears;
  final String? highestQualification;

  factory RefereeSportsInformation.fromJson(Map<String, dynamic> json) =>
      RefereeSportsInformation(
        sportIds: _listValue(json['sport_ids']).map(_intValue).toList(),
        experienceYears: _intValue(json['experience_years']),
        highestQualification: _stringValue(json['highest_qualification']),
      );
}

class RefereeAvailability {
  const RefereeAvailability({
    this.days = const [],
    this.preferredCity,
    this.travelRadius = 0,
    this.emergencyContactName,
    this.emergencyContactNumber,
  });

  final List<String> days;
  final String? preferredCity;
  final int travelRadius;
  final String? emergencyContactName;
  final String? emergencyContactNumber;

  factory RefereeAvailability.fromJson(Map<String, dynamic> json) =>
      RefereeAvailability(
        days: _listValue(json['availability'])
            .map((value) => value.toString())
            .toList(),
        preferredCity: _stringValue(json['preferred_city']),
        travelRadius: _intValue(json['travel_radius']),
        emergencyContactName: _stringValue(json['emergency_contact_name']),
        emergencyContactNumber: _stringValue(json['emergency_contact_number']),
      );
}

class RefereeDocument {
  const RefereeDocument({
    required this.id,
    required this.type,
    required this.fileUrl,
  });

  final int id;
  final int type;
  final String fileUrl;

  factory RefereeDocument.fromJson(Map<String, dynamic> json) =>
      RefereeDocument(
        id: _intValue(json['id']),
        type: _intValue(json['type']),
        fileUrl: _stringValue(json['file_url'] ?? json['file_path']) ?? '',
      );
}

class RefereeApplicationTimeline {
  const RefereeApplicationTimeline({
    required this.status,
    this.reason,
    this.date,
  });

  final int status;
  final String? reason;
  final String? date;

  factory RefereeApplicationTimeline.fromJson(Map<String, dynamic> json) =>
      RefereeApplicationTimeline(
        status: _intValue(json['status']),
        reason: _stringValue(json['reason']),
        date: _stringValue(json['date']),
      );
}

class RefereeApplicationResponse {
  const RefereeApplicationResponse({
    required this.applicationNumber,
    required this.applicationStatus,
    this.submittedAt,
    required this.personalInformation,
    required this.address,
    required this.sports,
    required this.availability,
    this.documents = const [],
    this.timeline = const [],
  });

  final String applicationNumber;
  final int applicationStatus;
  final String? submittedAt;
  final RefereePersonalInformation personalInformation;
  final RefereeAddress address;
  final RefereeSportsInformation sports;
  final RefereeAvailability availability;
  final List<RefereeDocument> documents;
  final List<RefereeApplicationTimeline> timeline;

  bool get isDraft => applicationStatus == 1;
  bool get isPendingReview => applicationStatus == 2;
  bool get isApproved => applicationStatus == 3;

  factory RefereeApplicationResponse.fromJson(Map<String, dynamic> json) =>
      RefereeApplicationResponse(
        applicationNumber: _stringValue(json['application_number']) ?? '',
        applicationStatus: _intValue(json['application_status']),
        submittedAt: _stringValue(json['submitted_at']),
        personalInformation: RefereePersonalInformation.fromJson(
          _mapValue(json['personal_information'] ?? json['personal']),
        ),
        address: RefereeAddress.fromJson(_mapValue(json['address'])),
        sports: RefereeSportsInformation.fromJson(_mapValue(json['sports'])),
        availability:
            RefereeAvailability.fromJson(_mapValue(json['availability'])),
        documents: _listValue(json['documents'])
            .whereType<Map>()
            .map((value) =>
                RefereeDocument.fromJson(Map<String, dynamic>.from(value)))
            .toList(),
        timeline: _listValue(json['timeline'])
            .whereType<Map>()
            .map((value) => RefereeApplicationTimeline.fromJson(
                Map<String, dynamic>.from(value)))
            .toList(),
      );
}

class RefereeApplicationStatusResponse {
  const RefereeApplicationStatusResponse({
    required this.applicationNumber,
    required this.applicationStatus,
    this.statusLabel,
    this.submittedAt,
    this.timeline = const [],
  });

  final String applicationNumber;
  final int applicationStatus;
  final String? statusLabel;
  final String? submittedAt;
  final List<RefereeApplicationTimeline> timeline;

  factory RefereeApplicationStatusResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      RefereeApplicationStatusResponse(
        applicationNumber: _stringValue(json['application_number']) ?? '',
        applicationStatus:
            _intValue(json['application_status'] ?? json['status']),
        statusLabel: _stringValue(json['status_label']),
        submittedAt: _stringValue(json['submitted_at']),
        timeline: _listValue(json['timeline'])
            .whereType<Map>()
            .map((value) => RefereeApplicationTimeline.fromJson(
                Map<String, dynamic>.from(value)))
            .toList(),
      );
}
