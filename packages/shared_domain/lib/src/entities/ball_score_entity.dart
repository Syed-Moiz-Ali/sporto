import 'package:equatable/equatable.dart';
import '../enums/enums.dart';

class BallScoreEntity extends Equatable {
  final int ballNumber;
  final int runs;
  final bool isWide;
  final bool isNoBall;
  final bool isWicket;
  final WicketType? wicketType;
  final String strikerName;
  final String bowlerName;

  const BallScoreEntity({
    required this.ballNumber,
    required this.runs,
    this.isWide = false,
    this.isNoBall = false,
    this.isWicket = false,
    this.wicketType,
    required this.strikerName,
    required this.bowlerName,
  });

  Map<String, dynamic> toJson() => {
        'ballNumber': ballNumber,
        'runs': runs,
        'isWide': isWide,
        'isNoBall': isNoBall,
        'isWicket': isWicket,
        'wicketType': wicketType?.name,
        'strikerName': strikerName,
        'bowlerName': bowlerName,
      };

  factory BallScoreEntity.fromJson(Map<String, dynamic> json) => BallScoreEntity(
        ballNumber: json['ballNumber'] as int,
        runs: json['runs'] as int,
        isWide: json['isWide'] as bool? ?? false,
        isNoBall: json['isNoBall'] as bool? ?? false,
        isWicket: json['isWicket'] as bool? ?? false,
        wicketType: json['wicketType'] != null
            ? WicketType.values.byName(json['wicketType'] as String)
            : null,
        strikerName: json['strikerName'] as String,
        bowlerName: json['bowlerName'] as String,
      );

  @override
  List<Object?> get props => [
        ballNumber,
        runs,
        isWide,
        isNoBall,
        isWicket,
        wicketType,
        strikerName,
        bowlerName
      ];
}
