import 'package:equatable/equatable.dart';
import '../enums/enums.dart';
import 'team_entity.dart';

abstract class BaseMatchEntity extends Equatable {
  final String id;
  final String tournamentName;
  final SportType sportType;
  final TeamEntity teamA;
  final TeamEntity teamB;
  final String venue;
  final DateTime scheduledTime;
  final MatchStatus status;
  final String refereeName;
  final bool isVerifiedByReferee;
  final SyncStatus syncStatus;

  const BaseMatchEntity({
    required this.id,
    required this.tournamentName,
    required this.sportType,
    required this.teamA,
    required this.teamB,
    required this.venue,
    required this.scheduledTime,
    required this.status,
    required this.refereeName,
    this.isVerifiedByReferee = false,
    this.syncStatus = SyncStatus.synced,
  });

  @override
  List<Object?> get props => [
        id,
        tournamentName,
        sportType,
        teamA,
        teamB,
        venue,
        scheduledTime,
        status,
        refereeName,
        isVerifiedByReferee,
        syncStatus,
      ];
}
