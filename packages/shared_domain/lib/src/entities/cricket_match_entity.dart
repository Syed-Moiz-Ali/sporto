import '../enums/enums.dart';
import 'base_match_entity.dart';
import 'team_entity.dart';
import 'toss_result_entity.dart';
import 'ball_score_entity.dart';

class CricketMatchEntity extends BaseMatchEntity {
  final int totalOvers;
  final int matchDurationMinutes;
  final int breakDurationMinutes;
  final TossResultEntity? tossResult;
  final int teamAScore;
  final int teamAWickets;
  final double teamAOvers;
  final int teamBScore;
  final int teamBWickets;
  final double teamBOvers;
  final int currentInning;
  final List<BallScoreEntity> commentary;

  const CricketMatchEntity({
    required super.id,
    required super.tournamentName,
    required super.teamA,
    required super.teamB,
    required super.venue,
    required super.scheduledTime,
    required super.status,
    required super.refereeName,
    super.isVerifiedByReferee = false,
    super.syncStatus = SyncStatus.synced,
    this.totalOvers = 20,
    this.matchDurationMinutes = 60,
    this.breakDurationMinutes = 15,
    this.tossResult,
    this.teamAScore = 0,
    this.teamAWickets = 0,
    this.teamAOvers = 0.0,
    this.teamBScore = 0,
    this.teamBWickets = 0,
    this.teamBOvers = 0.0,
    this.currentInning = 1,
    this.commentary = const [],
  }) : super(sportType: SportType.cricket);

  CricketMatchEntity copyWith({
    MatchStatus? status,
    bool? isVerifiedByReferee,
    SyncStatus? syncStatus,
    TossResultEntity? tossResult,
    int? teamAScore,
    int? teamAWickets,
    double? teamAOvers,
    int? teamBScore,
    int? teamBWickets,
    double? teamBOvers,
    int? currentInning,
    List<BallScoreEntity>? commentary,
  }) {
    return CricketMatchEntity(
      id: id,
      tournamentName: tournamentName,
      teamA: teamA,
      teamB: teamB,
      venue: venue,
      scheduledTime: scheduledTime,
      status: status ?? this.status,
      refereeName: refereeName,
      isVerifiedByReferee: isVerifiedByReferee ?? this.isVerifiedByReferee,
      syncStatus: syncStatus ?? this.syncStatus,
      totalOvers: totalOvers,
      matchDurationMinutes: matchDurationMinutes,
      breakDurationMinutes: breakDurationMinutes,
      tossResult: tossResult ?? this.tossResult,
      teamAScore: teamAScore ?? this.teamAScore,
      teamAWickets: teamAWickets ?? this.teamAWickets,
      teamAOvers: teamAOvers ?? this.teamAOvers,
      teamBScore: teamBScore ?? this.teamBScore,
      teamBWickets: teamBWickets ?? this.teamBWickets,
      teamBOvers: teamBOvers ?? this.teamBOvers,
      currentInning: currentInning ?? this.currentInning,
      commentary: commentary ?? this.commentary,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tournamentName': tournamentName,
        'sportType': sportType.name,
        'teamA': teamA.toJson(),
        'teamB': teamB.toJson(),
        'venue': venue,
        'scheduledTime': scheduledTime.toIso8601String(),
        'status': status.name,
        'refereeName': refereeName,
        'isVerifiedByReferee': isVerifiedByReferee,
        'syncStatus': syncStatus.name,
        'totalOvers': totalOvers,
        'matchDurationMinutes': matchDurationMinutes,
        'breakDurationMinutes': breakDurationMinutes,
        'tossResult': tossResult?.toJson(),
        'teamAScore': teamAScore,
        'teamAWickets': teamAWickets,
        'teamAOvers': teamAOvers,
        'teamBScore': teamBScore,
        'teamBWickets': teamBWickets,
        'teamBOvers': teamBOvers,
        'currentInning': currentInning,
        'commentary': commentary.map((c) => c.toJson()).toList(),
      };

  factory CricketMatchEntity.fromJson(Map<String, dynamic> json) => CricketMatchEntity(
        id: json['id'] as String,
        tournamentName: json['tournamentName'] as String,
        teamA: TeamEntity.fromJson(Map<String, dynamic>.from(json['teamA'] as Map)),
        teamB: TeamEntity.fromJson(Map<String, dynamic>.from(json['teamB'] as Map)),
        venue: json['venue'] as String,
        scheduledTime: DateTime.parse(json['scheduledTime'] as String),
        status: MatchStatus.values.byName(json['status'] as String),
        refereeName: json['refereeName'] as String,
        isVerifiedByReferee: json['isVerifiedByReferee'] as bool? ?? false,
        syncStatus: SyncStatus.values.byName(json['syncStatus'] as String? ?? 'synced'),
        totalOvers: json['totalOvers'] as int? ?? 20,
        matchDurationMinutes: json['matchDurationMinutes'] as int? ?? 60,
        breakDurationMinutes: json['breakDurationMinutes'] as int? ?? 15,
        tossResult: json['tossResult'] != null
            ? TossResultEntity.fromJson(Map<String, dynamic>.from(json['tossResult'] as Map))
            : null,
        teamAScore: json['teamAScore'] as int? ?? 0,
        teamAWickets: json['teamAWickets'] as int? ?? 0,
        teamAOvers: (json['teamAOvers'] as num? ?? 0.0).toDouble(),
        teamBScore: json['teamBScore'] as int? ?? 0,
        teamBWickets: json['teamBWickets'] as int? ?? 0,
        teamBOvers: (json['teamBOvers'] as num? ?? 0.0).toDouble(),
        currentInning: json['currentInning'] as int? ?? 1,
        commentary: (json['commentary'] as List? ?? [])
            .map((c) => BallScoreEntity.fromJson(Map<String, dynamic>.from(c as Map)))
            .toList(),
      );

  @override
  List<Object?> get props => [
        ...super.props,
        totalOvers,
        matchDurationMinutes,
        breakDurationMinutes,
        tossResult,
        teamAScore,
        teamAWickets,
        teamAOvers,
        teamBScore,
        teamBWickets,
        teamBOvers,
        currentInning,
        commentary,
      ];
}
