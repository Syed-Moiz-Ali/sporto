import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String mobileNumber;
  final String role; // 'partner', 'referee', 'player'
  final String? badgeId;
  final String? dob;
  final String? gender;
  final String? city;
  final String? state;
  final List<String> favoriteSports;
  final bool isProfileComplete;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.role,
    this.badgeId,
    this.dob,
    this.gender,
    this.city,
    this.state,
    this.favoriteSports = const [],
    this.isProfileComplete = false,
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? mobileNumber,
    String? role,
    String? badgeId,
    String? dob,
    String? gender,
    String? city,
    String? state,
    List<String>? favoriteSports,
    bool? isProfileComplete,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      role: role ?? this.role,
      badgeId: badgeId ?? this.badgeId,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      city: city ?? this.city,
      state: state ?? this.state,
      favoriteSports: favoriteSports ?? this.favoriteSports,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'mobileNumber': mobileNumber,
        'role': role,
        'badgeId': badgeId,
        'dob': dob,
        'gender': gender,
        'city': city,
        'state': state,
        'favoriteSports': favoriteSports,
        'isProfileComplete': isProfileComplete,
      };

  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        mobileNumber: json['mobileNumber'] as String? ?? '',
        role: json['role'] as String,
        badgeId: json['badgeId'] as String?,
        dob: json['dob'] as String?,
        gender: json['gender'] as String?,
        city: json['city'] as String?,
        state: json['state'] as String?,
        favoriteSports: (json['favoriteSports'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
        isProfileComplete: json['isProfileComplete'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        mobileNumber,
        role,
        badgeId,
        dob,
        gender,
        city,
        state,
        favoriteSports,
        isProfileComplete,
      ];
}
