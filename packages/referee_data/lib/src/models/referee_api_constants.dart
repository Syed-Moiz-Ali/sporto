/// Canonical API codes for the referee match/toss/score endpoints.
///
/// All UI/bloc conditions must reference these constants instead of raw
/// string literals so the contract lives in the model layer.
class RefereeTossActions {
  const RefereeTossActions._();

  static const String call = 'CALL';
  static const String flip = 'FLIP';
  static const String enterResult = 'ENTER_RESULT';
  static const String setDecision = 'SET_DECISION';
  static const String setStartingPlayers = 'SET_STARTING_PLAYERS';
}

class RefereeTossStates {
  const RefereeTossStates._();

  static const String pending = 'TOSS_PENDING';
  static const String calling = 'TOSS_CALLING';
  static const String flipped = 'TOSS_FLIPPED';
  static const String decisionPending = 'DECISION_PENDING';
  static const String startingSetupPending = 'STARTING_SETUP_PENDING';
  static const String completed = 'TOSS_COMPLETED';
  static const String disabled = 'TOSS_DISABLED';
}

class RefereeTossSides {
  const RefereeTossSides._();

  static const String heads = 'HEADS';
  static const String tails = 'TAILS';
}

class RefereeTossDecisions {
  const RefereeTossDecisions._();

  static const String batFirst = 'BAT_FIRST';
  static const String bowlFirst = 'BOWL_FIRST';
}

class RefereeStartingRoles {
  const RefereeStartingRoles._();

  static const String striker = 'STRIKER';
  static const String nonStriker = 'NON_STRIKER';
  static const String openingBowler = 'OPENING_BOWLER';
}

class RefereeScoreActions {
  const RefereeScoreActions._();

  static const String start = 'START';
  static const String setBatters = 'SET_BATTERS';
  static const String setBowler = 'SET_BOWLER';
  static const String setWicketKeeper = 'SET_WICKET_KEEPER';
  static const String addEvent = 'ADD_EVENT';
  static const String undoLast = 'UNDO_LAST';
  static const String endPeriod = 'END_PERIOD';
  static const String startSuperOver = 'START_SUPER_OVER';
  static const String complete = 'COMPLETE';
}

class RefereeCricketEventCodes {
  const RefereeCricketEventCodes._();

  static const String run = 'RUN';
  static const String wicket = 'WICKET';
  static const String wide = 'WIDE';
  static const String noBall = 'NO_BALL';
  static const String bye = 'BYE';
  static const String legBye = 'LEG_BYE';
  static const String penaltyRun = 'PENALTY_RUN';
}

class RefereeWicketTypeOption {
  const RefereeWicketTypeOption(this.code, this.label);

  final String code;
  final String label;
}

class RefereeWicketTypes {
  const RefereeWicketTypes._();

  static const String bowled = 'BOWLED';
  static const String caught = 'CAUGHT';
  static const String caughtAndBowled = 'CAUGHT_AND_BOWLED';
  static const String lbw = 'LBW';
  static const String runOut = 'RUN_OUT';
  static const String stumped = 'STUMPED';
  static const String hitWicket = 'HIT_WICKET';
  static const String retiredHurt = 'RETIRED_HURT';
  static const String retiredOut = 'RETIRED_OUT';
  static const String obstruction = 'OBSTRUCTING_THE_FIELD';
  static const String hitBallTwice = 'HIT_BALL_TWICE';
  static const String timedOut = 'TIMED_OUT';
  static const String mankad = 'MANKAD';

  /// Types the referee can pick when recording a wicket.
  static const List<RefereeWicketTypeOption> selectable = [
    RefereeWicketTypeOption(bowled, 'Bowled'),
    RefereeWicketTypeOption(caught, 'Caught'),
    RefereeWicketTypeOption(lbw, 'LBW'),
    RefereeWicketTypeOption(runOut, 'Run Out'),
    RefereeWicketTypeOption(stumped, 'Stumped'),
    RefereeWicketTypeOption(hitWicket, 'Hit Wicket'),
    RefereeWicketTypeOption(retiredHurt, 'Retired Hurt'),
  ];
}

class RefereeScoreEventTypes {
  const RefereeScoreEventTypes._();

  static const String matchStarted = 'MATCH_STARTED';
  static const String inningsStarted = 'INNINGS_STARTED';
  static const String batterReplaced = 'BATTER_REPLACED';
  static const String bowlerChanged = 'BOWLER_CHANGED';
  static const String overStarted = 'OVER_STARTED';
  static const String wicketKeeperChanged = 'WICKET_KEEPER_CHANGED';
  static const String ballRecorded = 'BALL_RECORDED';
  static const String strikeRotated = 'STRIKE_ROTATED';
  static const String overComplete = 'OVER_COMPLETE';
  static const String wicketRecorded = 'WICKET_RECORDED';
  static const String inningsComplete = 'INNINGS_COMPLETE';
  static const String inningsChanged = 'INNINGS_CHANGED';
  static const String superOverStarted = 'SUPER_OVER_STARTED';
  static const String matchCompleted = 'MATCH_COMPLETED';
  static const String eventUndone = 'EVENT_UNDONE';
}

class RefereeScoreRuntimeStates {
  const RefereeScoreRuntimeStates._();

  static const String live = 'LIVE';
  static const String completed = 'COMPLETED';
}

class RefereeMatchStatusLabels {
  const RefereeMatchStatusLabels._();

  static const String pending = 'PENDING';
  static const String live = 'LIVE';
  static const String completed = 'COMPLETED';
  static const String cancelled = 'CANCELLED';
}
