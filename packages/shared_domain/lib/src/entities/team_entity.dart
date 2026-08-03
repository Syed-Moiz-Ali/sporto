import 'package:equatable/equatable.dart';
import 'player_entity.dart';

class TeamEntity extends Equatable {
  final String id;
  final String name;
  final String logoEmoji;
  final List<PlayerEntity> players;

  const TeamEntity({
    required this.id,
    required this.name,
    required this.logoEmoji,
    this.players = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logoEmoji': logoEmoji,
        'players': players.map((p) => p.toJson()).toList(),
      };

  factory TeamEntity.fromJson(Map<String, dynamic> json) => TeamEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        logoEmoji: json['logoEmoji'] as String,
        players: (json['players'] as List? ?? [])
            .map((p) => PlayerEntity.fromJson(Map<String, dynamic>.from(p as Map)))
            .toList(),
      );

  @override
  List<Object?> get props => [id, name, logoEmoji, players];
}
