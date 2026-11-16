import 'dart:async';
import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/dependency_injector.dart';
import '../../../../core/match_action/match_action_resolver.dart';
import '../../../../core/match_request/match_request_refresh.dart';
import '../widgets/match_live_score.dart';
import '../widgets/referee_request_widgets.dart';

/// Referee App Home — redesigned to match the exported Figma package in
/// `new_screens/Home_redesign` (01_Home, 02_Home_-_Live, 03_Home_-_Today's
/// Match) pixel-for-pixel.
class RefereeHomeScreen extends StatefulWidget {
  final VoidCallback? onViewAll;
  final VoidCallback? onAvailability;
  final Future<RefereeHomePayload>? payloadFuture;
  final Future<List<RefereeMatchResponse>>? matchesFuture;
  final Future<RefereeIncomingRequestsBundle> Function()?
      incomingRequestsLoader;
  final Duration pollInterval;

  const RefereeHomeScreen({
    super.key,
    this.onViewAll,
    this.onAvailability,
    this.payloadFuture,
    this.matchesFuture,
    this.incomingRequestsLoader,
    this.pollInterval = const Duration(seconds: 20),
  });

  @override
  State<RefereeHomeScreen> createState() => RefereeHomeScreenState();
}

class RefereeHomePayload {
  const RefereeHomePayload({
    this.matches = const [],
    this.requests = const [],
    this.dashboard,
    this.requestsFailed = false,
  });

  final List<RefereeMatchResponse> matches;
  final List<RefereeMatchRequestResponse> requests;
  final RefereeDashboardResponse? dashboard;
  final bool requestsFailed;
}

class _FetchResult<T> {
  const _FetchResult({this.value, this.error});

  final T? value;
  final Object? error;
}

Future<_FetchResult<T>> _fetch<T>(Future<T> Function() task) async {
  try {
    return _FetchResult(value: await task());
  } catch (error) {
    return _FetchResult(error: error);
  }
}

class RefereeHomeScreenState extends State<RefereeHomeScreen>
    with WidgetsBindingObserver {
  late Future<RefereeHomePayload> _future;
  final List<RefereeMatchRequestResponse> _requests = [];
  bool _requestsLoaded = false;
  Object? _requestsError;
  bool _syncNoticeShown = false;
  Timer? _pollTimer;
  bool _polling = false;
  bool _statusEnabled = false;
  bool _statusInitialised = false;
  bool _refreshing = false;
  int _selectedMatchTab = 0;

  RefereeRemoteDataSource get _remote =>
      DependencyInjector.instance.refereeRemoteDataSource;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    MatchRequestRefresh.revision.addListener(_onRequestsChanged);
    final initial = widget.payloadFuture ??
        (widget.matchesFuture != null
            ? _loadFromMatches(widget.matchesFuture!)
            : _load());
    _future = initial;
    initial.then<void>((payload) {
      if (!mounted) return;
      setState(() => _applyPayload(payload));
      _startPolling();
    }).catchError((Object _) {
      if (!mounted) return;
      _startPolling();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    MatchRequestRefresh.revision.removeListener(_onRequestsChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _applyPayload(RefereeHomePayload payload) {
    _requests
      ..clear()
      ..addAll(payload.requests);
    _requestsLoaded = true;
    if (payload.requestsFailed) {
      _requestsError ??= const SportoApiException(
        'Unable to refresh incoming requests.',
      );
    } else {
      _requestsError = null;
    }
    final dashboard = payload.dashboard;
    if (dashboard != null) {
      _statusInitialised = true;
      _statusEnabled = dashboard.availability.isAvailable;
    }
  }

  void _onRequestsChanged() {
    if (mounted) refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refresh();
      _pollRequests();
    }
  }

  /// Public so the shell can refresh Home whenever it becomes visible.
  Future<void> refresh() => _refresh();

  void _startPolling() {
    final interval = widget.pollInterval;
    if (interval <= Duration.zero) return;
    final injected =
        widget.payloadFuture != null || widget.matchesFuture != null;
    if (injected && widget.incomingRequestsLoader == null) return;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(interval, (_) => _pollRequests());
  }

  Future<RefereeIncomingRequestsBundle> _loadIncomingRequests() {
    final loader = widget.incomingRequestsLoader;
    if (loader != null) return loader();
    return _remote.listIncomingRequestsData(
      retryOnEmpty: widget.pollInterval > Duration.zero,
    );
  }

  Future<void> _pollRequests() async {
    if (_polling || !mounted) return;
    _polling = true;
    try {
      final bundle = await _loadIncomingRequests();
      if (!mounted) return;
      final next = bundle.requests;
      final changed = !_sameRequestIds(_requests, next);
      if (changed || _requestsError != null) {
        setState(() {
          if (changed) {
            _requests
              ..clear()
              ..addAll(next);
            _requestsLoaded = true;
          }
          _requestsError = null;
        });
      }
      _syncNoticeShown = false;
    } catch (error) {
      if (!mounted) return;
      setState(() => _requestsError = error);
      _showRequestsSyncMessage();
    } finally {
      _polling = false;
    }
  }

  void _showRequestsSyncMessage() {
    if (_syncNoticeShown || !mounted) return;
    _syncNoticeShown = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not refresh requests. Showing the latest list.'),
      ),
    );
  }

  bool _sameRequestIds(
    List<RefereeMatchRequestResponse> a,
    List<RefereeMatchRequestResponse> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].assignmentId != b[i].assignmentId ||
          a[i].isBooking != b[i].isBooking) {
        return false;
      }
    }
    return true;
  }

  Future<RefereeHomePayload> _loadFromMatches(
    Future<List<RefereeMatchResponse>> source,
  ) async {
    final matches = await source;
    // Status loads in the background so prefetched/offline match payloads
    // render immediately.
    _refreshStatus();
    if (!_statusInitialised) {
      _statusInitialised = true;
      _statusEnabled = matches.isNotEmpty;
    }
    _selectedMatchTab = matches.any((m) => m.isLive) ? 0 : 1;
    return RefereeHomePayload(matches: matches);
  }

  Future<RefereeHomePayload> _load() async {
    // Dashboard is the primary source; `/matches` powers Live/Today tabs and
    // the incoming-requests bundle powers the request cards.
    final dashboardFuture = _fetch(_remote.getDashboardData);
    final matchesFuture = _fetch(() => _remote.listMyMatchesData(perPage: 50));
    final requestsFuture = _fetch(_loadIncomingRequests);

    final dashboardResult = await dashboardFuture;
    final matchesResult = await matchesFuture;
    final requestsResult = await requestsFuture;

    final dashboard = dashboardResult.value;
    if (dashboard == null && matchesResult.value == null) {
      throw dashboardResult.error ??
          matchesResult.error ??
          const SportoApiException('Unable to load home data.');
    }

    var matches = matchesResult.value ?? const <RefereeMatchResponse>[];
    if (matches.isEmpty && dashboard != null) {
      final seen = <String>{};
      matches = [
        for (final match in [
          ...dashboard.todayMatches.items,
          ...dashboard.todayBookings.items,
        ])
          if (seen.add('${match.isBooking}:${match.id}')) match,
      ];
    }

    final bundle = requestsResult.value;
    final requests = bundle?.requests ?? List.of(_requests);
    _requests
      ..clear()
      ..addAll(requests);
    _requestsLoaded = true;
    _requestsError = requestsResult.error;

    if (dashboard != null) {
      _statusInitialised = true;
      _statusEnabled = dashboard.availability.isAvailable;
    } else {
      await _refreshStatus();
    }
    _selectedMatchTab = matches.any((m) => m.isLive) ? 0 : 1;
    return RefereeHomePayload(
      matches: matches,
      requests: requests,
      dashboard: dashboard,
      requestsFailed: requestsResult.error != null,
    );
  }

  Future<void> _refreshStatus() async {
    try {
      final status = await _remote.getAvailabilityStatus();
      _statusInitialised = true;
      _statusEnabled = status.isAvailable;
      if (mounted) setState(() {});
    } catch (_) {
      // Fall back to the match/request heuristic when the status API fails.
    }
  }

  Future<void> _setStatus(bool value) async {
    final previous = _statusEnabled;
    setState(() {
      _statusEnabled = value;
      _statusInitialised = true;
    });
    try {
      final status = await _remote.updateAvailabilityStatus(value);
      if (!mounted) return;
      setState(() => _statusEnabled = status.isAvailable);
    } catch (error) {
      if (!mounted) return;
      setState(() => _statusEnabled = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update status: $error')),
      );
    }
  }

  Future<void> _refresh() async {
    if (_refreshing || !mounted) return;
    _refreshing = true;
    try {
      final next = _load();
      setState(() {
        _future = next;
      });
      try {
        await next;
      } catch (_) {
        // FutureBuilder renders the error card; keep refresh non-throwing.
      }
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _accept(RefereeMatchRequestResponse request) async {
    await context.push(
      '${AppRouter.acceptBookingRoute}?requestId=${request.assignmentId ?? request.id}',
      extra: request,
    );
    if (mounted) await _refresh();
  }

  Future<void> _decline(RefereeMatchRequestResponse request) async {
    try {
      await _remote.rejectMatchRequest(request.assignmentId ?? request.id);
      MatchRequestRefresh.bump();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request declined.')),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to decline request: $error')),
      );
    }
  }

  Future<void> _openRequestDetails(
    RefereeMatchRequestResponse request,
  ) async {
    await context.push(
      '${AppRouter.requestDetailsRoute}?requestId=${request.assignmentId ?? request.id}',
      extra: request,
    );
    if (mounted) await _refresh();
  }

  Future<void> _openIncomingRequests() async {
    await context.push(AppRouter.incomingRequestsRoute);
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;

    return Scaffold(
      backgroundColor: const Color(0xFF090C10),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<RefereeHomePayload>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _HomeSkeleton(scale: scale);
            }
            if (snapshot.hasError) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 120 * scale),
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        20 * scale,
                        4 * scale,
                        20 * scale,
                        0,
                      ),
                      child: _HomeHeader(
                        scale: scale,
                        wallet: _formatAmount(null),
                        displayName: null,
                        onWalletTap: () => context.push(AppRouter.walletRoute),
                        onBellTap: () =>
                            context.push(AppRouter.notificationSettingsRoute),
                      ),
                    ),
                    SizedBox(height: 24 * scale),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                      child: _HomeErrorCard(
                        scale: scale,
                        message: snapshot.error.toString(),
                        onRetry: _refresh,
                      ),
                    ),
                  ],
                ),
              );
            }

            final payload = snapshot.data ??
                const RefereeHomePayload(matches: [], requests: []);
            final dashboard = payload.dashboard;
            final wallet = dashboard?.wallet;
            final stats = dashboard?.statistics;
            final matches = payload.matches;
            final requests = _requestsLoaded
                ? List<RefereeMatchRequestResponse>.of(_requests)
                : payload.requests;

            final liveMatches = matches.where((m) => m.isLive).toList();
            final upcomingMatches = matches.where((m) => m.isUpcoming).toList();
            final completed = matches.where((m) => m.isCompleted).toList();

            final hasDashboard = dashboard != null;
            final liveCount =
                hasDashboard ? (stats?.liveMatches ?? 0) : liveMatches.length;
            final upcomingCount = hasDashboard
                ? (stats?.upcomingMatches ?? 0)
                : upcomingMatches.length;
            final completedCount = hasDashboard
                ? (stats?.completedMatches ?? 0)
                : completed.length;
            final earnings = hasDashboard
                ? _formatCurrency(wallet?.totalEarned)
                : _earningsText(completed);

            final isPopulated =
                matches.isNotEmpty || requests.isNotEmpty || hasDashboard;
            final attentionCount =
                _pendingRequestCount(dashboard, requests.length);
            final displayName = _dashboardDisplayName(dashboard);
            final tabMatches =
                _selectedMatchTab == 0 ? liveMatches : upcomingMatches;
            // Figma canvas: card width 340 on a 390-wide frame.
            // Width is derived from the real viewport, height keeps the
            // Figma aspect ratio (340x148 live / 340x193 today).
            final tabCardWidth = MediaQuery.sizeOf(context).width * (340 / 390);
            final tabCardHeight = tabCardWidth *
                (_selectedMatchTab == 0 ? (148 / 340) : (193 / 340));

            return RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.only(bottom: 96 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        20 * scale,
                        4 * scale,
                        20 * scale,
                        0,
                      ),
                      child: _HomeHeader(
                        scale: scale,
                        wallet: _formatAmount(wallet?.balance),
                        displayName: displayName,
                        onWalletTap: () => context.push(AppRouter.walletRoute),
                        onBellTap: () =>
                            context.push(AppRouter.notificationSettingsRoute),
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                      child: _HomeSearchBar(scale: scale),
                    ),
                    SizedBox(height: 22 * scale),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _RefereeStatusCard(
                            scale: scale,
                            enabled: _statusEnabled,
                            onChanged: _setStatus,
                            onAvailability: widget.onAvailability ??
                                () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Availability settings'),
                                    ),
                                  );
                                },
                          ),
                          if (_requestsError != null) ...[
                            SizedBox(height: 8 * scale),
                            _RequestsSyncBanner(
                              scale: scale,
                              onRetry: _pollRequests,
                            ),
                          ],
                          if (attentionCount > 0) ...[
                            SizedBox(height: 12 * scale),
                            _NeedsAttentionBanner(
                              scale: scale,
                              count: attentionCount,
                              onTap: _openIncomingRequests,
                            ),
                          ],
                          SizedBox(height: 22 * scale),
                          if (isPopulated) ...[
                            _WalletBalanceCard(
                              scale: scale,
                              balance: _formatCurrency(wallet?.balance),
                              totalEarned: _formatCurrency(wallet?.totalEarned),
                              pending: _formatCurrency(wallet?.pendingEarnings),
                              onWithdraw: () =>
                                  context.push(AppRouter.walletRoute),
                            ),
                            SizedBox(height: 10 * scale),
                          ],
                          _HomeStatsRow(
                            scale: scale,
                            liveCount: liveCount,
                            upcomingCount: upcomingCount,
                            completedCount: completedCount,
                            earnings: earnings,
                          ),
                          if (isPopulated && matches.isNotEmpty) ...[
                            SizedBox(height: 22 * scale),
                            _MatchTabs(
                              scale: scale,
                              selectedIndex: _selectedMatchTab,
                              onSelected: (index) =>
                                  setState(() => _selectedMatchTab = index),
                            ),
                            SizedBox(height: 10 * scale),
                            if (tabMatches.isEmpty)
                              SizedBox(
                                height: tabCardHeight,
                                child: _NoMatchesCard(
                                  scale: scale,
                                  label: _selectedMatchTab == 0
                                      ? 'No live matches right now'
                                      : 'No matches scheduled',
                                ),
                              )
                            else
                              SizedBox(
                                height: tabCardHeight,
                                child: OverflowBox(
                                  alignment: Alignment.centerLeft,
                                  maxWidth: double.infinity,
                                  child: SizedBox(
                                    width: MediaQuery.sizeOf(context).width -
                                        20 * scale,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemCount: tabMatches.length,
                                      separatorBuilder: (_, __) =>
                                          SizedBox(width: 10 * scale),
                                      itemBuilder: (context, index) {
                                        final match = tabMatches[index];
                                        return SizedBox(
                                          width: tabCardWidth,
                                          child: _selectedMatchTab == 0
                                              ? _LiveMatchCard(
                                                  scale: scale,
                                                  match: match,
                                                )
                                              : _TodayMatchCard(
                                                  scale: scale,
                                                  match: match,
                                                ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                          ],
                          if (!isPopulated) ...[
                            SizedBox(height: 22 * scale),
                            _EmptyAssignedCard(scale: scale),
                          ],
                          if (requests.isNotEmpty) ...[
                            SizedBox(height: 22 * scale),
                            _IncomingRequestsSection(
                              scale: scale,
                              requests: requests,
                              onViewAll: _openIncomingRequests,
                              onTap: _openRequestDetails,
                              onAccept: _accept,
                              onDecline: _decline,
                            ),
                          ],
                          SizedBox(height: 22 * scale),
                          _AdsBanner(scale: scale),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  int _pendingRequestCount(
    RefereeDashboardResponse? dashboard,
    int bundleTotal,
  ) {
    if (dashboard == null) return bundleTotal;
    final raw = dashboard.raw;
    final hasStats = raw['stats'] is Map || raw['statistics'] is Map;
    if (!hasStats) return bundleTotal;
    return dashboard.statistics.pendingRequests;
  }

  String? _dashboardDisplayName(RefereeDashboardResponse? dashboard) {
    if (dashboard == null) return null;
    final rawProfile = dashboard.raw['profile'];
    if (rawProfile is Map) {
      final rawName = rawProfile['name']?.toString().trim() ?? '';
      if (rawName.isNotEmpty) return rawName;
    }
    final name = dashboard.profile.name.trim();
    if (name.isEmpty || name == 'Referee') return null;
    return name;
  }

  String _earningsText(List<RefereeMatchResponse> completed) {
    if (completed.isEmpty) return _formatCurrency(0);
    num total = 0;
    for (final match in completed) {
      final value =
          match.raw['earnings'] ?? match.raw['fee'] ?? match.raw['referee_fee'];
      final parsed =
          value is num ? value : num.tryParse(value?.toString() ?? '');
      total += parsed ?? 0;
    }
    return _formatCurrency(total);
  }

  /// Indian-grouped amount without the currency symbol (header shows a rupee
  /// icon separately).
  String _formatAmount(num? value) {
    final amount = (value ?? 0).round();
    final negative = amount < 0;
    final digits = amount.abs().toString();
    String grouped;
    if (digits.length <= 3) {
      grouped = digits;
    } else {
      final lastThree = digits.substring(digits.length - 3);
      var rest = digits.substring(0, digits.length - 3);
      final parts = <String>[];
      while (rest.length > 2) {
        parts.insert(0, rest.substring(rest.length - 2));
        rest = rest.substring(0, rest.length - 2);
      }
      if (rest.isNotEmpty) parts.insert(0, rest);
      grouped = '${parts.join(',')},$lastThree';
    }
    return negative ? '-$grouped' : grouped;
  }

  String _formatCurrency(num? value) => '₹${_formatAmount(value)}';
}

// =============================================================================
// Header
// =============================================================================
class _HomeHeader extends StatelessWidget {
  final double scale;
  final String wallet;
  final String? displayName;
  final VoidCallback? onWalletTap;
  final VoidCallback? onBellTap;

  const _HomeHeader({
    required this.scale,
    required this.wallet,
    this.displayName,
    this.onWalletTap,
    this.onBellTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 49 * scale,
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RefereeGradientText(
                  _greetingFor(DateTime.now()),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFED7B00), Color(0xFFCF9E24)],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w400,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 1 * scale),
                _RefereeDisplayName(scale: scale, name: displayName),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                button: true,
                label: 'Wallet',
                child: GestureDetector(
                  onTap: onWalletTap,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    height: 44 * scale,
                    child: Center(
                      child: Container(
                        height: 24 * scale,
                        decoration: BoxDecoration(
                          color: const Color(0x33767680),
                          borderRadius: BorderRadius.circular(6 * scale),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6 * scale,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SportoSvgIcon(
                                    SportoHomeRedesignIcons.rupee,
                                    width: 8.3 * scale,
                                    height: 12 * scale,
                                  ),
                                  SizedBox(width: 4 * scale),
                                  Text(
                                    wallet,
                                    style: TextStyle(
                                      fontSize: 16 * scale,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFFFFFFF),
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 25 * scale,
                              height: 24 * scale,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFED7B00),
                                    Color(0xFFCF9E24),
                                  ],
                                ),
                              ),
                              child: SportoSvgIcon(
                                SportoHomeRedesignIcons.plus,
                                size: 12 * scale,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10 * scale),
              Semantics(
                button: true,
                label: 'Notification settings',
                child: GestureDetector(
                  onTap: onBellTap,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 44 * scale,
                    height: 44 * scale,
                    child: Center(
                      child: SportoSvgIcon(
                        SportoHomeRedesignIcons.bell,
                        size: 24 * scale,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _greetingFor(DateTime now) {
  final hour = now.hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}

class _RefereeDisplayName extends StatefulWidget {
  final double scale;
  final String? name;

  const _RefereeDisplayName({required this.scale, this.name});

  @override
  State<_RefereeDisplayName> createState() => _RefereeDisplayNameState();
}

class _RefereeDisplayNameState extends State<_RefereeDisplayName> {
  late final Future<String> _nameFuture = _loadName();

  Future<String> _loadName() async {
    try {
      final user = await AuthRepositoryImpl().getCurrentUser();
      final name = user?.name.trim() ?? '';
      if (name.isNotEmpty) return name;
    } catch (_) {
      // Hive not ready in widget tests — fall through to the default.
    }
    return 'Referee';
  }

  @override
  Widget build(BuildContext context) {
    final provided = widget.name?.trim() ?? '';
    if (provided.isNotEmpty) {
      return _nameText(provided);
    }
    return FutureBuilder<String>(
      future: _nameFuture,
      builder: (context, snapshot) {
        return _nameText(snapshot.data ?? 'Referee');
      },
    );
  }

  Widget _nameText(String name) {
    return Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 18 * widget.scale,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFFFFFFF),
        height: 1.0,
      ),
    );
  }
}

// =============================================================================
// Search bar
// =============================================================================
class _HomeSearchBar extends StatelessWidget {
  final double scale;

  const _HomeSearchBar({required this.scale});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16 * scale),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 50 * scale,
          padding: EdgeInsets.symmetric(horizontal: 12 * scale),
          decoration: BoxDecoration(
            color: const Color(0x1F767680),
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(
              color: const Color(0x14FFFFFF),
              width: 1 * scale,
            ),
          ),
          child: Row(
            children: [
              SportoSvgIcon(
                SportoHomeRedesignIcons.search,
                size: 22 * scale,
              ),
              SizedBox(width: 20 * scale),
              Expanded(
                child: Text(
                  'Search cricket, football..',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFA0A0A0),
                  ),
                ),
              ),
              Container(
                width: 1 * scale,
                height: 30 * scale,
                color: const Color(0x33A0A0A0),
              ),
              SizedBox(width: 14 * scale),
              SportoSvgIcon(
                SportoHomeRedesignIcons.mic,
                size: 24 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Referee status
// =============================================================================
class _RefereeStatusCard extends StatelessWidget {
  final double scale;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final VoidCallback onAvailability;

  const _RefereeStatusCard({
    required this.scale,
    required this.enabled,
    required this.onChanged,
    required this.onAvailability,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * scale),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x0FF4B41A),
            Color(0x33F4B41A),
            Color(0x0FF4B41A),
          ],
          stops: [0.0, 0.52, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x38FFB020),
            blurRadius: 14 * scale,
            offset: Offset(2 * scale, 4 * scale),
          ),
        ],
      ),
      padding: EdgeInsets.all(0.8 * scale),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.2 * scale),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: enabled ? const Color(0xFF1C2026) : null,
                  gradient: enabled
                      ? null
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFF4B41A), Color(0xFFE5A100)],
                        ),
                ),
              ),
            ),
            if (enabled) ...[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF173824), Color(0xE60E2418)],
                      stops: [0.0, 0.7],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -50 * scale,
                right: -30 * scale,
                width: 150 * scale,
                height: 150 * scale,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFF2B705).withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -70 * scale,
                left: -40 * scale,
                width: 160 * scale,
                height: 160 * scale,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFE1263F).withValues(alpha: 0.28),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
            Padding(
              padding: EdgeInsets.fromLTRB(
                10 * scale,
                11 * scale,
                10 * scale,
                11 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Referee Status',
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w600,
                            color: enabled
                                ? const Color(0xFFA0A0A0)
                                : const Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                      Text(
                        enabled ? 'On' : 'Off',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w600,
                          color: enabled
                              ? const Color(0xFFA0A0A0)
                              : const Color(0xFF283040),
                        ),
                      ),
                      SizedBox(width: 6 * scale),
                      _StatusToggle(
                        scale: scale,
                        value: enabled,
                        onChanged: onChanged,
                      ),
                    ],
                  ),
                  SizedBox(height: 2 * scale),
                  Text(
                    enabled
                        ? 'Ready for your next match'
                        : 'Not taking new matches',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w700,
                      color: enabled
                          ? const Color(0xFFFFFFFF)
                          : const Color(0xFF0E0C08),
                    ),
                  ),
                  SizedBox(height: 2 * scale),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          enabled
                              ? 'New referee requests can reach you.'
                              : "You won't receive new referee requests.",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11 * scale,
                            fontWeight: FontWeight.w500,
                            color: enabled
                                ? const Color(0xFFA0A0A0)
                                : const Color(0xFF373435),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onAvailability,
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            enabled
                                ? RefereeGradientText(
                                    'Availability',
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF7AD3FF),
                                        Color(0xFF4FBAF0),
                                      ],
                                    ),
                                    style: TextStyle(
                                      fontSize: 11 * scale,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : Text(
                                    'Availability',
                                    style: TextStyle(
                                      fontSize: 11 * scale,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1B2335),
                                    ),
                                  ),
                            SizedBox(width: 2 * scale),
                            if (enabled)
                              SportoSvgIcon(
                                SportoHomeRedesignIcons.arrowRight,
                                width: 12 * scale,
                                height: 8 * scale,
                              )
                            else
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 13 * scale,
                                color: const Color(0xFF1B2335),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusToggle extends StatelessWidget {
  final double scale;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _StatusToggle({
    required this.scale,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: 'Referee availability',
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 44 * scale,
          child: Center(
            child: Container(
              width: 40 * scale,
              height: 20 * scale,
              padding: EdgeInsets.all(2 * scale),
              decoration: BoxDecoration(
                color:
                    value ? const Color(0xFF0E0C08) : const Color(0xFFFFE7A3),
                borderRadius: BorderRadius.circular(10 * scale),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 16 * scale,
                  height: 16 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: value
                        ? const LinearGradient(
                            colors: [Color(0xFFED7B00), Color(0xFFCF9E24)],
                          )
                        : null,
                    color: value ? null : const Color(0xFFFFFFFF),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x33000000),
                        blurRadius: 2 * scale,
                        offset: Offset(-1 * scale, 0.5 * scale),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Needs attention banner
// =============================================================================
class _NeedsAttentionBanner extends StatelessWidget {
  final double scale;
  final int count;
  final VoidCallback onTap;

  const _NeedsAttentionBanner({
    required this.scale,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 53 * scale,
        padding: EdgeInsets.symmetric(
          horizontal: 12 * scale,
          vertical: 10 * scale,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16 * scale),
          gradient: const LinearGradient(
            colors: [Color(0xFFDF3F00), Color(0xFFF65800)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x4DEA4B00),
              blurRadius: 20 * scale,
              offset: Offset(2 * scale, 4 * scale),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32 * scale,
              height: 32 * scale,
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(10 * scale),
              ),
              child: Center(
                child: SportoSvgIcon(
                  SportoHomeRedesignIcons.danger,
                  size: 24 * scale,
                ),
              ),
            ),
            SizedBox(width: 8 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Needs Your Attention',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFFFFFF),
                      height: 1.1,
                    ),
                  ),
                  Text(
                    '$count pending request${count == 1 ? '' : 's'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFFFFFFF),
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14 * scale,
              color: const Color(0xFFFFFFFF),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Wallet balance
// =============================================================================
class _RequestsSyncBanner extends StatelessWidget {
  final double scale;
  final VoidCallback onRetry;

  const _RequestsSyncBanner({
    required this.scale,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 6 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0x1AFFB020),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0x33F4B41A)),
      ),
      child: Row(
        children: [
          SportoSvgIcon(
            SportoHomeRedesignIcons.danger,
            size: 16 * scale,
          ),
          SizedBox(width: 6 * scale),
          Expanded(
            child: Text(
              'Requests may be out of date',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12 * scale,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFA0A0A0),
              ),
            ),
          ),
          Semantics(
            button: true,
            label: 'Retry loading incoming requests',
            child: GestureDetector(
              onTap: onRetry,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                height: 44 * scale,
                child: Center(
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFF4B41A),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletBalanceCard extends StatelessWidget {
  final double scale;
  final String balance;
  final String totalEarned;
  final String pending;
  final VoidCallback? onWithdraw;

  const _WalletBalanceCard({
    required this.scale,
    required this.balance,
    required this.totalEarned,
    required this.pending,
    this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16 * scale),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF1C2026),
                border: Border.all(color: const Color(0x33FFD572), width: 0.5),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0x292BB673), Color(0x29F4B41A)],
                  stops: [0.0, 0.45],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              10 * scale,
              10 * scale,
              10 * scale,
              10 * scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Wallet Balance',
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFA0A0A0),
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Withdraw from wallet',
                      child: GestureDetector(
                        onTap: onWithdraw,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 30 * scale,
                          padding: EdgeInsets.symmetric(
                            horizontal: 12 * scale,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF4B41A), Color(0xFFCF9E24)],
                            ),
                            borderRadius: BorderRadius.circular(20 * scale),
                          ),
                          child: Text(
                            'Withdraw',
                            style: TextStyle(
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0E0C08),
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6 * scale),
                Text(
                  balance,
                  style: TextStyle(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF4B41A),
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Container(height: 0.5 * scale, color: const Color(0x33FFFFFF)),
                SizedBox(height: 6 * scale),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '$totalEarned Total earned',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6 * scale),
                      child: Container(
                        width: 2 * scale,
                        height: 2 * scale,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFA0A0A0),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        '$pending Pending',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFA0A0A0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Stats row
// =============================================================================
class _HomeStatsRow extends StatelessWidget {
  final double scale;
  final int liveCount;
  final int upcomingCount;
  final int completedCount;
  final String earnings;

  const _HomeStatsRow({
    required this.scale,
    required this.liveCount,
    required this.upcomingCount,
    required this.completedCount,
    required this.earnings,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54 * scale,
      child: Row(
        children: [
          Expanded(
            flex: 75,
            child: _statCard(
              value: '$liveCount',
              label: 'Live Now',
              labelColor: const Color(0xFFFFFFFF),
              border: const LinearGradient(
                colors: [
                  Color(0x00FE595C),
                  Color(0x4DFE595C),
                  Color(0x00FE595C)
                ],
                stops: [0.0, 0.52, 1.0],
              ),
              showLiveDot: true,
            ),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            flex: 71,
            child: _statCard(
              value: '$upcomingCount',
              label: 'Upcoming',
              labelGradient: const LinearGradient(
                colors: [Color(0xFFFF9364), Color(0xFFF25F33)],
              ),
              border: const LinearGradient(
                colors: [
                  Color(0x00FE595C),
                  Color(0x4DFE595C),
                  Color(0x00FE595C)
                ],
                stops: [0.0, 0.52, 1.0],
              ),
            ),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            flex: 75,
            child: _statCard(
              value: '$completedCount',
              label: 'Completed',
              labelColor: const Color(0xFF2BB673),
              border: const LinearGradient(
                colors: [
                  Color(0x0F2BB673),
                  Color(0x332BB673),
                  Color(0x0F2BB673)
                ],
                stops: [0.0, 0.52, 1.0],
              ),
            ),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            flex: 99,
            child: _statCard(
              value: earnings,
              valueColor: const Color(0xFFF4B41A),
              label: 'Earnings',
              labelColor: const Color(0xFFFFFFFF),
              border: const LinearGradient(
                colors: [
                  Color(0x0FF4B41A),
                  Color(0x33F4B41A),
                  Color(0x0FF4B41A)
                ],
                stops: [0.0, 0.52, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String value,
    required String label,
    Color? valueColor,
    Color? labelColor,
    Gradient? labelGradient,
    required Gradient border,
    bool showLiveDot = false,
  }) {
    return Container(
      height: 54 * scale,
      padding: EdgeInsets.all(0.8 * scale),
      decoration: BoxDecoration(
        gradient: border,
        borderRadius: BorderRadius.circular(14 * scale),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 4 * scale,
          vertical: 9 * scale,
        ),
        decoration: BoxDecoration(
          color: const Color(0x661B2335),
          borderRadius: BorderRadius.circular(13.2 * scale),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w700,
                color: valueColor ?? const Color(0xFFFFFFFF),
                height: 1.0,
              ),
            ),
            SizedBox(height: 4 * scale),
            if (showLiveDot)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6 * scale,
                    height: 6 * scale,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFF4444), Color(0xFFFF1919)],
                      ),
                    ),
                  ),
                  SizedBox(width: 4 * scale),
                  Flexible(
                    child: _label(
                      label,
                      fontSize: 11 * scale,
                      color: labelColor,
                      gradient: labelGradient,
                    ),
                  ),
                ],
              )
            else
              _label(
                label,
                fontSize: 11 * scale,
                color: labelColor,
                gradient: labelGradient,
              ),
          ],
        ),
      ),
    );
  }

  Widget _label(
    String label, {
    required double fontSize,
    Color? color,
    Gradient? gradient,
  }) {
    final child = gradient != null
        ? RefereeGradientText(
            label,
            gradient: gradient,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
          )
        : Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: color ?? const Color(0xFFFFFFFF),
              height: 1.0,
            ),
          );
    return FittedBox(fit: BoxFit.scaleDown, child: child);
  }
}

// =============================================================================
// Match tabs + cards
// =============================================================================
class _MatchTabs extends StatelessWidget {
  final double scale;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _MatchTabs({
    required this.scale,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20 * scale,
      child: Row(
        children: [
          Flexible(
            child: GestureDetector(
              onTap: () => onSelected(0),
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10 * scale,
                    height: 10 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF4444), Color(0xFFFF1919)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x33FE464B),
                          blurRadius: 12 * scale,
                          offset: Offset(0, 5 * scale),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6 * scale),
                  Flexible(
                    child: selectedIndex == 0
                        ? RefereeGradientText(
                            'Live Now',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFE6C6C), Color(0xFFFE464B)],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : Text(
                            'Live Now',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF666666),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 20 * scale),
          Flexible(
            child: GestureDetector(
              onTap: () => onSelected(1),
              behavior: HitTestBehavior.opaque,
              child: selectedIndex == 1
                  ? RefereeGradientText(
                      "Today's Match",
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9364), Color(0xFFF25F33)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Text(
                      "Today's Match",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF666666),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveMatchCard extends StatelessWidget {
  final double scale;
  final RefereeMatchResponse match;

  const _LiveMatchCard({required this.scale, required this.match});

  @override
  Widget build(BuildContext context) {
    return MatchLiveScore(
      matchId: match.id,
      builder: (context, score, isLoading) {
        final teamAId = match.teamA?.id;
        final teamBId = match.teamB?.id;
        final team1Score = isLoading
            ? '…'
            : (teamAId == null
                ? '—'
                : (liveTeamScore(score, teamAId) ?? 'Yet to Bat'));
        final team2Score = isLoading
            ? '…'
            : (teamBId == null
                ? '—'
                : (liveTeamScore(score, teamBId) ?? 'Waiting to Bat'));
        final overs = isLoading
            ? ''
            : (liveOversText(score) ?? 'Over - 0.0')
                .replaceFirst('Over - ', 'Over ');

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16 * scale),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x33B40003),
                Color(0x33ED7B00),
                Color(0x26CF9E24),
              ],
            ),
            border:
                Border.all(color: const Color(0x4DF53E02), width: 0.8 * scale),
            boxShadow: [
              BoxShadow(
                color: const Color(0x80512813),
                blurRadius: 8 * scale,
                offset: Offset(0, 1 * scale),
              ),
            ],
          ),
          padding: EdgeInsets.all(10 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    requestSport(match),
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2BB673),
                    ),
                  ),
                  _dot(scale),
                  Text(
                    requestCode(match),
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF666666),
                    ),
                  ),
                  if (requestSourceLabel(match).isNotEmpty) ...[
                    _dot(scale),
                    Flexible(
                      child: RefereeGradientText(
                        requestSourceLabel(match),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF58DD), Color(0xFFDC65AC)],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 3 * scale),
              Text(
                match.displayTournament,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
              SizedBox(height: 5 * scale),
              Container(height: 0.5 * scale, color: const Color(0x33FFFFFF)),
              SizedBox(height: 5 * scale),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.displayTeamA,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFA0A0A0),
                          ),
                        ),
                        Text(
                          team1Score,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                    child: Text(
                      'Vs',
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFAAAAAA),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          match.displayTeamB,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFA0A0A0),
                          ),
                        ),
                        Text(
                          team2Score,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5 * scale),
              Container(height: 0.5 * scale, color: const Color(0x33FFFFFF)),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      overs,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFA0A0A0),
                      ),
                    ),
                  ),
                  SizedBox(width: 6 * scale),
                  SizedBox(
                    width: 134 * scale,
                    height: 30 * scale,
                    child: _GradientButton(
                      scale: scale,
                      label: 'Continue Scoring',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFDF3F00), Color(0xFFF65800)],
                      ),
                      textColor: const Color(0xFFFFFFFF),
                      onTap: () => context.push(
                        '${AppRouter.liveScoringRoute}?matchId=${match.id}&matchCode=SPT-${match.id}',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dot(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6 * scale),
      child: Container(
        width: 2 * scale,
        height: 2 * scale,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFA0A0A0),
        ),
      ),
    );
  }
}

class _TodayMatchCard extends StatelessWidget {
  final double scale;
  final RefereeMatchResponse match;

  const _TodayMatchCard({required this.scale, required this.match});

  @override
  Widget build(BuildContext context) {
    final countdown = countdownText(parseMatchStart(match));
    final sourceLabel = requestSourceLabel(match);
    final scheduleText = requestScheduleText(match);
    final location = requestLocationText(match);
    final distance = requestDistanceText(match);
    final timeRange = requestTimeRangeText(match);
    final hasLocationRow = location.isNotEmpty || distance != null;
    return Container(
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: const Color(0x26FF58DD), width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RefereeGradientText(
                'Upcoming',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9364), Color(0xFFF25F33)],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (sourceLabel.isNotEmpty) ...[
                SizedBox(width: 8 * scale),
                Flexible(
                  child: _Pill(
                    scale: scale,
                    label: sourceLabel.replaceFirst('by ', 'By '),
                    gradient: const LinearGradient(
                      colors: [Color(0x1AFF58DD), Color(0x1ADC65AC)],
                    ),
                    textGradient: const LinearGradient(
                      colors: [Color(0xFFFF58DD), Color(0xFFDC65AC)],
                    ),
                  ),
                ),
              ],
              if (scheduleText.isNotEmpty) ...[
                SizedBox(width: 8 * scale),
                Flexible(
                  child: Text(
                    scheduleText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFAAAAAA),
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 10 * scale),
          Row(
            children: [
              Text(
                requestSport(match),
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2BB673),
                ),
              ),
              _dot(scale),
              Text(
                requestCode(match),
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF666666),
                ),
              ),
            ],
          ),
          SizedBox(height: 2 * scale),
          Text(
            match.displayTournament,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFFFFF),
            ),
          ),
          if (hasLocationRow) ...[
            SizedBox(height: 10 * scale),
            Row(
              children: [
                Expanded(
                  child: location.isEmpty
                      ? const SizedBox.shrink()
                      : Row(
                          children: [
                            SportoSvgIcon(
                              SportoRefereeBookingIcons.pinGreenSmall,
                              size: 16 * scale,
                            ),
                            SizedBox(width: 2 * scale),
                            Expanded(
                              child: Text(
                                location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12 * scale,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFFA0A0A0),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                if (distance != null) ...[
                  SizedBox(width: 4 * scale),
                  RefereeDistancePill(scale: scale, label: distance),
                ],
              ],
            ),
          ],
          if (countdown != null) ...[
            SizedBox(height: 10 * scale),
            Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Starts in ',
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                        TextSpan(
                          text: countdown,
                          style: TextStyle(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2BB673),
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (timeRange.isNotEmpty)
                  Text(
                    'At $timeRange',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFFFFFFF),
                    ),
                  ),
              ],
            ),
          ],
          const Spacer(),
          SizedBox(
            height: 34 * scale,
            width: double.infinity,
            child: _GradientButton(
              scale: scale,
              label: 'START SESSION',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              gradient: const LinearGradient(
                colors: [Color(0xFF2BB673), Color(0xFF2BB673)],
              ),
              textColor: const Color(0xFF090C10),
              onTap: () => _onMatchAction(context, match),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6 * scale),
      child: Container(
        width: 2 * scale,
        height: 2 * scale,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFA0A0A0),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final double scale;
  final String label;
  final Gradient gradient;
  final Gradient textGradient;

  const _Pill({
    required this.scale,
    required this.label,
    required this.gradient,
    required this.textGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6 * scale,
        vertical: 2 * scale,
      ),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: RefereeGradientText(
        label,
        gradient: textGradient,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12 * scale,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
      ),
    );
  }
}

// =============================================================================
// Incoming requests (home section)
// =============================================================================
class _IncomingRequestsSection extends StatelessWidget {
  final double scale;
  final List<RefereeMatchRequestResponse> requests;
  final VoidCallback onViewAll;
  final ValueChanged<RefereeMatchRequestResponse> onTap;
  final ValueChanged<RefereeMatchRequestResponse> onAccept;
  final ValueChanged<RefereeMatchRequestResponse> onDecline;

  const _IncomingRequestsSection({
    required this.scale,
    required this.requests,
    required this.onViewAll,
    required this.onTap,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final preview = requests.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20 * scale,
          child: Row(
            children: [
              Expanded(
                child: RefereeGradientText(
                  'Incoming Requests (${requests.length})',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF99FFA3), Color(0xFF68EE76)],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              GestureDetector(
                onTap: onViewAll,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFA0A0A0),
                      ),
                    ),
                    SizedBox(width: 2 * scale),
                    SportoSvgIcon(
                      SportoRefereeBookingIcons.chevronRight,
                      width: 13 * scale,
                      height: 8 * scale,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        for (var i = 0; i < preview.length; i++) ...[
          if (i > 0) SizedBox(height: 10 * scale),
          RefereeRequestCard(
            scale: scale,
            request: preview[i],
            onTap: () => onTap(preview[i]),
            onAccept: () => onAccept(preview[i]),
            onDecline: () => onDecline(preview[i]),
          ),
        ],
        if (requests.length > preview.length) ...[
          SizedBox(height: 8 * scale),
          GestureDetector(
            onTap: onViewAll,
            behavior: HitTestBehavior.opaque,
            child: Text(
              'View all ${requests.length} requests',
              style: TextStyle(
                fontSize: 12 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF7AD3FF),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// =============================================================================
// Empty / ads / buttons
// =============================================================================
class _EmptyAssignedCard extends StatelessWidget {
  final double scale;

  const _EmptyAssignedCard({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        30 * scale,
        20 * scale,
        20 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(30 * scale),
      ),
      child: Column(
        children: [
          Container(
            width: 140 * scale,
            height: 120 * scale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10 * scale),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B2B22), Color(0xFF2A2018)],
              ),
            ),
          ),
          SizedBox(height: 20 * scale),
          Text(
            'No Assigned Matches',
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFFFFFFF),
            ),
          ),
          SizedBox(height: 10 * scale),
          RefereeGradientText(
            'Enjoy your day!',
            gradient: const LinearGradient(
              colors: [Color(0xFF99FFA3), Color(0xFF68EE76)],
            ),
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20 * scale),
          Container(height: 0.8 * scale, color: const Color(0xFF283040)),
          SizedBox(height: 20 * scale),
          Text(
            "We'll notify you when new matches are assigned.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFA0A0A0),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoMatchesCard extends StatelessWidget {
  final double scale;
  final String label;

  const _NoMatchesCard({required this.scale, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340 * scale,
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14 * scale,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFA0A0A0),
          ),
        ),
      ),
    );
  }
}

class _AdsBanner extends StatelessWidget {
  final double scale;

  const _AdsBanner({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60 * scale,
      padding:
          EdgeInsets.fromLTRB(20 * scale, 12 * scale, 20 * scale, 12 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * scale),
        gradient: const LinearGradient(
          colors: [Color(0xFFED7B00), Color(0xFFCF9E24)],
        ),
      ),
      child: Row(
        children: [
          Text(
            'Ads Banner',
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFFFFFF),
              shadows: [
                Shadow(
                  color: const Color(0x33000000),
                  blurRadius: 4 * scale,
                  offset: Offset(0, 1 * scale),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            width: 36 * scale,
            height: 36 * scale,
            padding: EdgeInsets.all(8 * scale),
            // decoration: BoxDecoration(
            //   color: const Color(0x1AFFFFFF),
            //   borderRadius: BorderRadius.circular(10 * scale),
            // ),
            child: SportoSvgIcon(
              SportoRefereeBookingIcons.chevronRight,
              width: 6 * scale,
              height: 6 * scale,
              color: const Color(0xFFFFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final double scale;
  final String label;
  final double fontSize;
  final FontWeight fontWeight;
  final Gradient gradient;
  final Color textColor;
  final VoidCallback onTap;

  const _GradientButton({
    required this.scale,
    required this.label,
    required this.fontSize,
    required this.fontWeight,
    required this.gradient,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10 * scale),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSize * scale,
                fontWeight: fontWeight,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Error + skeleton
// =============================================================================
class _HomeErrorCard extends StatelessWidget {
  final double scale;
  final String message;
  final VoidCallback onRetry;

  const _HomeErrorCard({
    required this.scale,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2026),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0x66FE464B)),
      ),
      child: Column(
        children: [
          Text(
            'Unable to load assigned matches',
            style: TextStyle(
              fontSize: 15 * scale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFFFFFFF),
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12 * scale,
              color: const Color(0xFFA0A0A0),
            ),
          ),
          SizedBox(height: 14 * scale),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2BB673),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10 * scale),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _HomeSkeleton extends StatefulWidget {
  final double scale;

  const _HomeSkeleton({required this.scale});

  @override
  State<_HomeSkeleton> createState() => _HomeSkeletonState();
}

class _HomeSkeletonState extends State<_HomeSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _box({
    double? width,
    required double height,
    double radius = 8,
  }) {
    final s = widget.scale;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: width == null ? double.infinity : width * s,
          height: height * s,
          decoration: BoxDecoration(
            color: const Color(0xFF283040).withValues(alpha: _animation.value),
            borderRadius: BorderRadius.circular(radius * s),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20 * s, 4 * s, 20 * s, 40 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(width: 80, height: 12),
                  SizedBox(height: 6 * s),
                  _box(width: 120, height: 18),
                ],
              ),
              const Spacer(),
              _box(width: 85, height: 24, radius: 6),
            ],
          ),
          SizedBox(height: 14 * s),
          _box(height: 50, radius: 16),
          SizedBox(height: 22 * s),
          _box(height: 81, radius: 16),
          SizedBox(height: 22 * s),
          Row(
            children: [
              Expanded(child: _box(width: 75, height: 54, radius: 14)),
              SizedBox(width: 10 * s),
              Expanded(child: _box(width: 71, height: 54, radius: 14)),
              SizedBox(width: 10 * s),
              Expanded(child: _box(width: 75, height: 54, radius: 14)),
              SizedBox(width: 10 * s),
              Expanded(child: _box(width: 99, height: 54, radius: 14)),
            ],
          ),
          SizedBox(height: 22 * s),
          _box(height: 193, radius: 14),
          SizedBox(height: 22 * s),
          _box(height: 170, radius: 16),
          SizedBox(height: 22 * s),
          _box(height: 60, radius: 20),
        ],
      ),
    );
  }
}

void _onMatchAction(BuildContext context, RefereeMatchResponse match) {
  if (match.isBooking) {
    final matchId = match.bookingMatchId;
    context.push(
      '${AppRouter.bookingSessionRoute}?bookingId=${match.id}'
      '${matchId == null ? '' : '&matchId=$matchId'}',
    );
    return;
  }
  final resolved = resolveMatchAction(match);
  switch (resolved.action) {
    case MatchAction.continueScoring:
    case MatchAction.startScoring:
      context.push(
        '${AppRouter.liveScoringRoute}?matchId=${match.id}&matchCode=SPT-${match.id}',
      );
    case MatchAction.viewReport:
      context.push(
        '${AppRouter.matchSummaryRoute}?matchId=${match.id}',
        extra: match,
      );
    case MatchAction.toss:
      context.push('${AppRouter.conductTossRoute}?matchId=${match.id}');
    case MatchAction.verify:
      context.push('${AppRouter.matchVerificationRoute}?matchId=${match.id}');
    case MatchAction.blocked:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resolved.blockedReason ?? 'Unavailable')),
      );
  }
}
