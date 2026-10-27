import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:referee_data/referee_data.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/di/dependency_injector.dart';
import '../widgets/referee_request_widgets.dart';

/// Figma `04_Incoming_Requests` — full list of booking requests.
class IncomingRequestsScreen extends StatefulWidget {
  final Future<List<RefereeMatchRequestResponse>>? requestsFuture;

  const IncomingRequestsScreen({super.key, this.requestsFuture});

  @override
  State<IncomingRequestsScreen> createState() => _IncomingRequestsScreenState();
}

class _IncomingRequestsScreenState extends State<IncomingRequestsScreen> {
  late Future<List<RefereeMatchRequestResponse>> _future;
  int? _processingId;

  RefereeRemoteDataSource get _remote =>
      DependencyInjector.instance.refereeRemoteDataSource;

  @override
  void initState() {
    super.initState();
    _future = widget.requestsFuture ?? _load();
  }

  Future<List<RefereeMatchRequestResponse>> _load() =>
      _remote.listMatchRequestsData();

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _decline(RefereeMatchRequestResponse request) async {
    final id = request.assignmentId ?? request.id;
    setState(() => _processingId = id);
    try {
      await _remote.rejectMatchRequest(id);
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
    } finally {
      if (mounted) setState(() => _processingId = null);
    }
  }

  Future<void> _openAccept(RefereeMatchRequestResponse request) async {
    await context.push(
      '${AppRouter.acceptBookingRoute}?requestId=${request.assignmentId ?? request.id}',
      extra: request,
    );
    if (mounted) await _refresh();
  }

  Future<void> _openDetails(RefereeMatchRequestResponse request) async {
    await context.push(
      '${AppRouter.requestDetailsRoute}?requestId=${request.assignmentId ?? request.id}',
      extra: request,
    );
    if (mounted) await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.sportoScale;
    return Scaffold(
      backgroundColor: const Color(0xFF090C10),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _RequestsHeader(scale: scale),
            SizedBox(height: 12 * scale),
            Expanded(
              child: FutureBuilder<List<RefereeMatchRequestResponse>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _RequestsSkeleton(scale: scale);
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                        child: Text(
                          'Unable to load requests\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13 * scale,
                            color: const Color(0xFFA0A0A0),
                          ),
                        ),
                      ),
                    );
                  }
                  final requests =
                      snapshot.data ?? const <RefereeMatchRequestResponse>[];
                  if (requests.isEmpty) {
                    return Center(
                      child: Text(
                        'No incoming requests',
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFA0A0A0),
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        20 * scale,
                        6 * scale,
                        20 * scale,
                        40 * scale,
                      ),
                      itemCount: requests.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12 * scale),
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        final processing = _processingId ==
                            (request.assignmentId ?? request.id);
                        return RefereeRequestCard(
                          scale: scale,
                          request: request,
                          isProcessing: processing,
                          onTap: () => _openDetails(request),
                          onAccept: () => _openAccept(request),
                          onDecline: () => _decline(request),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestsHeader extends StatelessWidget {
  final double scale;

  const _RequestsHeader({required this.scale});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44 * scale,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20 * scale),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 36 * scale,
                height: 36 * scale,
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Center(
                  child: SportoSvgIcon(
                    SportoRefereeBookingIcons.back,
                    width: 6 * scale,
                    height: 12 * scale,
                  ),
                ),
              ),
            ),
            SizedBox(width: 10 * scale),
            Expanded(
              child: Text(
                'Incoming Requests',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFFFFFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestsSkeleton extends StatelessWidget {
  final double scale;

  const _RequestsSkeleton({required this.scale});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        6 * scale,
        20 * scale,
        40 * scale,
      ),
      children: [
        for (var i = 0; i < 2; i++) ...[
          Container(
            height: 170 * scale,
            decoration: BoxDecoration(
              color: const Color(0xFF1C2026),
              borderRadius: BorderRadius.circular(16 * scale),
            ),
          ),
          SizedBox(height: 12 * scale),
        ],
      ],
    );
  }
}
