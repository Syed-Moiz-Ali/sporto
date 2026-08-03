import 'package:equatable/equatable.dart';

class PlayerEntity extends Equatable {
  final String id;
  final String name;
  final String role;
  final int jerseyNumber;

  const PlayerEntity({
    required this.id,
    required this.name,
    required this.role,
    required this.jerseyNumber,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'jerseyNumber': jerseyNumber,
      };

  factory PlayerEntity.fromJson(Map<String, dynamic> json) => PlayerEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        role: json['role'] as String,
        jerseyNumber: json['jerseyNumber'] as int,
      );

  @override
  List<Object?> get props => [id, name, role, jerseyNumber];
}
