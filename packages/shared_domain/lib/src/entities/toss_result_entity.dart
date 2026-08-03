import 'package:equatable/equatable.dart';
import '../enums/enums.dart';

class TossResultEntity extends Equatable {
  final String winnerTeamId;
  final TossChoice choice;

  const TossResultEntity({
    required this.winnerTeamId,
    required this.choice,
  });

  Map<String, dynamic> toJson() => {
        'winnerTeamId': winnerTeamId,
        'choice': choice.name,
      };

  factory TossResultEntity.fromJson(Map<String, dynamic> json) => TossResultEntity(
        winnerTeamId: json['winnerTeamId'] as String,
        choice: TossChoice.values.byName(json['choice'] as String),
      );

  @override
  List<Object?> get props => [winnerTeamId, choice];
}
