import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../partner_api/application/partner_api_bloc.dart';

class ScheduleScreen extends StatefulWidget {
  final bool embedded;
  final bool? isLoading;
  final PartnerRemoteDataSource? remoteDataSource;
  final List<PartnerTournamentMatchResponse>? initialMatches;

  const ScheduleScreen({
    super.key,
    this.embedded = false,
    this.isLoading,
    this.remoteDataSource,
    this.initialMatches,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _searchController = TextEditingController();
  int _selectedTabIndex = 0;
  int _selectedDayIndex = DateTime.now().weekday - 1; // Today selected
  static const _tabs = ['All', 'Live', 'Upcoming', 'Completed'];
  static const _weekdayNames = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];
  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  /// Real current week (Monday-first). The old hardcoded August week never
  /// matched the actual calendar.
  List<DateTime> get _weekDays {
    final now = DateTime.now();
    final monday =
        DateTime(now.year, now.month, now.day - (now.weekday - 1));
    return List.generate(
      7,
      (i) => monday.add(Duration(days: i)),
    );
  }

  String _greetingFor(DateTime now) {
    if (now.hour < 12) return 'Good Morning';
    if (now.hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// "Oct 17, Today" / "Oct 18, Tomorrow" / "Oct 19, Sun" for the selected
  /// day — never a hardcoded calendar date.
  String _selectedDayLabel() {
    final index = _selectedDayIndex.clamp(0, _weekDays.length - 1);
    final day = _weekDays[index];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final label = '${_monthNames[day.month - 1]} ${day.day}';
    if (day == today) return '$label, Today';
    if (day == today.add(const Duration(days: 1))) return '$label, Tomorrow';
    return '$label, ${_weekdayNames[day.weekday - 1]}';
  }

  late final PartnerRemoteDataSource _remoteDataSource = widget.remoteDataSource ??
      PartnerRemoteDataSource(
        apiClient: SportoApiClient(tokenProvider: AuthSessionStore().getToken),
      );
  List<PartnerTournamentMatchResponse>? _apiMatches;
  bool _isLoadingMatches = false;
  int? _loadedTournamentsHash;
  String? _matchesError;
  List<PartnerTournamentResponse> _lastTournaments = const [];

  @override
  void initState() {
    super.initState();
    if (widget.initialMatches != null) {
      _apiMatches = List.of(widget.initialMatches!);
    }
  }

  void _syncMatchesWithTournaments(List<PartnerTournamentResponse> tournaments) {
    if (widget.initialMatches != null || tournaments.isEmpty) return;
    final hash = tournaments.fold<int>(0, (prev, t) => prev ^ t.id.hashCode);
    if (_loadedTournamentsHash == hash || _isLoadingMatches) return;
    _loadedTournamentsHash = hash;
    _lastTournaments = List.of(tournaments);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchMatches(tournaments);
    });
  }

  Future<void> _fetchMatches(List<PartnerTournamentResponse> tournaments) async {
    setState(() {
      _isLoadingMatches = true;
      _matchesError = null;
    });
    try {
      final allMatches = <PartnerTournamentMatchResponse>[];
      for (final t in tournaments) {
        final matches = await _remoteDataSource.listTournamentMatchesData(t.id);
        allMatches.addAll(matches);
      }
      if (!mounted) return;
      setState(() {
        _apiMatches = allMatches;
        _isLoadingMatches = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _apiMatches ??= [];
        _isLoadingMatches = false;
        _matchesError = error is SportoApiException
            ? error.message
            : 'Matches could not be loaded. Please try again.';
      });
    }
  }

  void _retryMatches() {
    _loadedTournamentsHash = null;
    _syncMatchesWithTournaments(_lastTournaments);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final scale = context.sportoScale;

    PartnerApiLoadedState? loaded;
    bool isApiLoading = false;
    try {
      final bloc = BlocProvider.of<PartnerApiBloc>(context, listen: true);
      isApiLoading = bloc.state is PartnerApiLoadingState ||
          bloc.state is PartnerApiInitialState;
      if (bloc.state is PartnerApiLoadedState) {
        loaded = bloc.state as PartnerApiLoadedState;
      }
    } catch (_) {}

    final isLoading = widget.isLoading ?? isApiLoading;
    final partnerName = loaded?.displayName ?? 'Partner';
    final tournaments =
        loaded?.tournaments ?? const <PartnerTournamentResponse>[];
    _syncMatchesWithTournaments(tournaments);

    final totalCount = '${tournaments.length}';
    final rawMatches = _apiMatches ?? const <PartnerTournamentMatchResponse>[];
    // Counts come from real loaded matches — backend tournament statuses
    // never reach 6/7, so counting tournaments would always show zero live.
    final liveCount = '${rawMatches.where((m) => m.isLive).length}';
    final upcomingCount =
        '${rawMatches.where((m) => !m.isLive && !m.isCompleted).length}';

    final query = _searchController.text.trim().toLowerCase();
    final tournamentMap = {for (final t in tournaments) t.id: t.name};

    final filteredMatches = rawMatches.where((m) {
      if (query.isNotEmpty) {
        final matchesQuery = m.displayTeamA.toLowerCase().contains(query) ||
            m.displayTeamB.toLowerCase().contains(query) ||
            m.displayRound.toLowerCase().contains(query) ||
            m.displayVenue.toLowerCase().contains(query);
        if (!matchesQuery) return false;
      }
      switch (_selectedTabIndex) {
        case 1:
          return m.isLive;
        case 2:
          return !m.isLive && !m.isCompleted;
        case 3:
          return m.isCompleted;
        default:
          return true;
      }
    }).toList();

    final todayMatches = filteredMatches.where((m) => m.isLive).toList();
    final upcomingMatches =
        filteredMatches.where((m) => !m.isLive && !m.isCompleted).toList();

    final content = SafeArea(
      bottom: false,
      child: SportoResponsiveContent(
        padding: EdgeInsets.zero,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            context.sportoResponsive.horizontalPadding,
            10 * scale,
            context.sportoResponsive.horizontalPadding,
            context.sportoResponsive.bottomContentPadding(context),
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isLoading)
                      const SportoShimmer(
                        width: 140,
                        height: 20,
                        borderRadius: 4,
                      )
                    else
                      Text(
                        partnerName,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontSize: 18 * scale),
                      ),
                    SizedBox(height: 4 * scale),
                    if (isLoading)
                      const SportoShimmer(
                        width: 90,
                        height: 14,
                        borderRadius: 4,
                      )
                    else
                      Text(
                        _greetingFor(DateTime.now()),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: cs.tertiary),
                      ),
                  ],
                ),
                Icon(Icons.light_mode_outlined, color: cs.onSurface),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'Today’s Scheduled',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: isLoading
                      ? _statShimmer(context)
                      : _stat(context, totalCount, 'Matches'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: isLoading
                      ? _statShimmer(context)
                      : _stat(context, liveCount, 'Live'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: isLoading
                      ? _statShimmer(context)
                      : _stat(context, upcomingCount, 'Upcoming'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _arrow(context, Icons.chevron_left, onTap: () {
                  if (_selectedDayIndex > 0) {
                    setState(() => _selectedDayIndex--);
                  }
                }),
                Expanded(
                  child: Text(
                    _selectedDayLabel(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
                _arrow(context, Icons.chevron_right, onTap: () {
                  if (_selectedDayIndex < _weekDays.length - 1) {
                    setState(() => _selectedDayIndex++);
                  }
                }),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < _weekDays.length; i++)
                  Expanded(
                    child: _day(
                      context,
                      _weekdayNames[i],
                      _weekDays[i].day.toString().padLeft(2, '0'),
                      i == _selectedDayIndex,
                      () => setState(() => _selectedDayIndex = i),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 28),
            _buildSearchBar(),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < _tabs.length; i++)
                    GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = i),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 24),
                        child: Text(
                          _tabs[i],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: i == _selectedTabIndex
                                ? cs.tertiary
                                : cs.onSurfaceVariant,
                            fontWeight: i == _selectedTabIndex
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Today’s Matches',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            if (isLoading || _isLoadingMatches)
              _matchShimmer(context, live: true)
            else if (todayMatches.isNotEmpty)
              for (final m in todayMatches.take(2))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _matchFromApi(
                    context,
                    m,
                    tournamentTitle: tournamentMap[m.tournamentId],
                  ),
                )
            else
              _emptyMatchCard('No live matches scheduled today.'),
            const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = 0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'View All  ›',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: context.sporto.info),
                      ),
                    ),
                  ),
                ],
              ),
              if (_matchesError != null && !isLoading) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0x1AFEBD38),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0x4DFEBD38)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _matchesError!,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.white70),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _retryMatches,
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                              color: Color(0xFFFEBD38),
                              fontSize: 12,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            const SizedBox(height: 12),
            if (isLoading || _isLoadingMatches) ...[
              _matchShimmer(context),
              const SizedBox(height: 12),
              _matchShimmer(context, compact: true),
            ] else if (upcomingMatches.isNotEmpty) ...[
              for (var i = 0; i < upcomingMatches.take(3).length; i++) ...[
                _matchFromApi(
                  context,
                  upcomingMatches[i],
                  tournamentTitle:
                      tournamentMap[upcomingMatches[i].tournamentId],
                  compact: i > 0,
                ),
                if (i != upcomingMatches.take(3).length - 1)
                  const SizedBox(height: 12),
              ],
            ] else ...[
              _emptyMatchCard('No upcoming matches scheduled.'),
            ],
          ],
        ),
      ),
    );
    return widget.embedded ? content : SportoScreenShell(body: content);
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        cursorColor: const Color(0xFF20C783),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: const Color(0xFF101317),
          hintText: 'Search matches...',
          hintStyle: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 10),
            child: SportoAssetIcon(
              SportoAssets.searchNormal,
              size: 20,
              color: Color(0xFF6B7280),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          suffixIcon: const Padding(
            padding: EdgeInsets.only(right: 14),
            child: Icon(Icons.sort, color: Color(0xFF6B7280), size: 20),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: Color(0xFF1B1E24)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: Color(0xFF1B1E24)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: const BorderSide(color: Color(0xFF20C783), width: 1.2),
          ),
        ),
      ),
    );
  }

  Widget _stat(BuildContext c, String value, String label) => SportoCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(c).textTheme.titleLarge),
            Text(label, style: Theme.of(c).textTheme.bodySmall),
          ],
        ),
      );

  Widget _statShimmer(BuildContext c) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF13171E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1F242C)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SportoShimmer(width: 32, height: 22, borderRadius: 4),
            SizedBox(height: 6),
            SportoShimmer(width: 50, height: 12, borderRadius: 4),
          ],
        ),
      );

  Widget _arrow(BuildContext c, IconData icon, {VoidCallback? onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: c.sporto.field,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: c.sporto.info),
        ),
      );

  Widget _day(
    BuildContext c,
    String day,
    String date,
    bool active,
    VoidCallback onTap,
  ) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? Theme.of(c).colorScheme.tertiary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                day,
                style: Theme.of(c)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: active ? Colors.black : null),
              ),
              Text(
                date,
                style: Theme.of(c)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: active ? Colors.black : null),
              ),
            ],
          ),
        ),
      );

  Widget _matchShimmer(BuildContext context,
      {bool live = false, bool compact = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF13171E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F242C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SportoShimmer(
                width: live ? 70 : 60,
                height: 14,
                borderRadius: 4,
              ),
              const SportoShimmer(width: 86, height: 20, borderRadius: 6),
            ],
          ),
          const SizedBox(height: 10),
          const SportoShimmer(width: 170, height: 16, borderRadius: 4),
          const SizedBox(height: 6),
          const SportoShimmer(width: 110, height: 12, borderRadius: 4),
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(
                child: SportoShimmer(height: 12, borderRadius: 4),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Vs',
                  style: TextStyle(color: Color(0xFF2C313A), fontSize: 11),
                ),
              ),
              Expanded(
                child: SportoShimmer(height: 12, borderRadius: 4),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 14),
            const Align(
              alignment: Alignment.centerRight,
              child: SportoShimmer(
                width: 115,
                height: 32,
                borderRadius: 100,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyMatchCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF13171E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F242C)),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Color(0xFF8E95A2), fontSize: 12),
        ),
      ),
    );
  }

  Widget _matchFromApi(
    BuildContext c,
    PartnerTournamentMatchResponse match, {
    String? tournamentTitle,
    bool compact = false,
  }) {
    final cs = Theme.of(c).colorScheme;
    final live = match.isLive;
    final roundBadge = match.stage?.name ??
        (match.stageName.isNotEmpty ? match.stageName : null) ??
        match.displayRound;
    final timeStr = live
        ? '● Live Now'
        : (match.displayTime.isNotEmpty
            ? match.displayTime
            : (match.isNeedsReview ? 'Schedule Pending' : 'Scheduled'));

    return SportoCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  timeStr,
                  maxLines: 1,
                  style: TextStyle(
                    color: live ? c.sporto.live : c.sporto.info,
                    fontSize: 12,
                  ),
                ),
              ),
              if (roundBadge.isNotEmpty)
                SportoBadge(text: roundBadge, color: cs.secondary),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            tournamentTitle ?? 'Tournament Match',
            style: Theme.of(c).textTheme.bodyLarge,
          ),
          Text(
            'Cricket  •  ${match.displayVenue}',
            style: Theme.of(c)
                .textTheme
                .bodySmall
                ?.copyWith(color: cs.tertiary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  match.displayTeamA,
                  style: Theme.of(c).textTheme.bodySmall,
                ),
              ),
              Text('Vs', style: Theme.of(c).textTheme.bodySmall),
              Expanded(
                child: Text(
                  match.displayTeamB,
                  textAlign: TextAlign.end,
                  style: Theme.of(c).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: SportoPillButton(
                label: live ? 'Open Live Match' : 'View Details',
                color: live ? c.sporto.live : c.sporto.info,
                filled: live,
                onTap: () {},
              ),
            ),
          ],
        ],
      ),
    );
  }
}
