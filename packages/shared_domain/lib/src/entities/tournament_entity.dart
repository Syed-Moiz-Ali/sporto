import 'package:equatable/equatable.dart';
import '../enums/enums.dart';

class TournamentEntity extends Equatable {
  final String id;
  final String name;
  final SportType sportType;
  final String category;
  final DateTime startDate;
  final int oversPerInning;
  final int totalTeams;
  final int matchDurationMinutes;
  final int breakMinutes;
  final List<String> venues;
  final double entryFee;
  final double prizePool;
  final String status;
  final SyncStatus syncStatus;

  const TournamentEntity({
    required this.id,
    required this.name,
    this.sportType = SportType.cricket,
    required this.category,
    required this.startDate,
    this.oversPerInning = 20,
    required this.totalTeams,
    this.matchDurationMinutes = 60,
    this.breakMinutes = 15,
    required this.venues,
    required this.entryFee,
    required this.prizePool,
    this.status = 'Active',
    this.syncStatus = SyncStatus.synced,
  });

  TournamentEntity copyWith({
    SyncStatus? syncStatus,
    String? status,
  }) {
    return TournamentEntity(
      id: id,
      name: name,
      sportType: sportType,
      category: category,
      startDate: startDate,
      oversPerInning: oversPerInning,
      totalTeams: totalTeams,
      matchDurationMinutes: matchDurationMinutes,
      breakMinutes: breakMinutes,
      venues: venues,
      entryFee: entryFee,
      prizePool: prizePool,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sportType': sportType.name,
        'category': category,
        'startDate': startDate.toIso8601String(),
        'oversPerInning': oversPerInning,
        'totalTeams': totalTeams,
        'matchDurationMinutes': matchDurationMinutes,
        'breakMinutes': breakMinutes,
        'venues': venues,
        'entryFee': entryFee,
        'prizePool': prizePool,
        'status': status,
        'syncStatus': syncStatus.name,
      };

  factory TournamentEntity.fromJson(Map<String, dynamic> json) => TournamentEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        sportType: SportType.values.byName(json['sportType'] as String? ?? 'cricket'),
        category: json['category'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        oversPerInning: json['oversPerInning'] as int? ?? 20,
        totalTeams: json['totalTeams'] as int,
        matchDurationMinutes: json['matchDurationMinutes'] as int? ?? 60,
        breakMinutes: json['breakMinutes'] as int? ?? 15,
        venues: List<String>.from(json['venues'] as List),
        entryFee: (json['entryFee'] as num).toDouble(),
        prizePool: (json['prizePool'] as num).toDouble(),
        status: json['status'] as String? ?? 'Active',
        syncStatus: SyncStatus.values.byName(json['syncStatus'] as String? ?? 'synced'),
      );

  @override
  List<Object?> get props => [
        id,
        name,
        sportType,
        category,
        startDate,
        oversPerInning,
        totalTeams,
        matchDurationMinutes,
        breakMinutes,
        venues,
        entryFee,
        prizePool,
        status,
        syncStatus,
      ];
}
