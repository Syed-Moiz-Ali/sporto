import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:shared_domain/shared_domain.dart';
import '../bloc/tournament_bloc.dart';
import 'create_tournament_wizard_modal.dart';

class PartnerMainScreen extends StatefulWidget {
  const PartnerMainScreen({super.key});

  @override
  State<PartnerMainScreen> createState() => _PartnerMainScreenState();
}

class _PartnerMainScreenState extends State<PartnerMainScreen> {
  int _currentIndex = 0;
  SportType? _selectedSportFilter;

  @override
  void initState() {
    super.initState();
    context.read<TournamentBloc>().add(const LoadTournamentsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events, color: colorScheme.primary, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'SPORTO Partner',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                    ),
                  ],
                ),
                BlocBuilder<ConnectivityBloc, ConnectivityState>(
                  builder: (context, state) {
                    final isConn = state is ConnectivityStatusState ? state.isConnected : true;
                    final pending = state is ConnectivityStatusState ? state.pendingItemsCount : 0;
                    final isSyncing = state is ConnectivityStatusState ? state.isSyncing : false;

                    return SyncIndicatorBadge(
                      isConnected: isConn,
                      isSyncing: isSyncing,
                      pendingItemsCount: pending,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: _buildCurrentTab(colorScheme),
      bottomNavigationBar: GlassNavBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        items: const [
          GlassNavItem(icon: Icons.emoji_events, label: 'Tournaments'),
          GlassNavItem(icon: Icons.sensors, label: 'Live'),
          GlassNavItem(icon: Icons.grass, label: 'Grounds'),
          GlassNavItem(icon: Icons.account_balance_wallet, label: 'Earnings'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              icon: const Icon(Icons.add),
              label: const Text('New Tournament', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                GlassModal.show(
                  context: context,
                  title: 'Create Tournament Wizard',
                  child: const CreateTournamentWizardModal(),
                );
              },
            )
          : null,
    );
  }

  Widget _buildCurrentTab(ColorScheme colorScheme) {
    switch (_currentIndex) {
      case 0:
        return _buildTournamentsTab(colorScheme);
      case 1:
        return _buildLiveTab(colorScheme);
      case 2:
        return _buildGroundsTab(colorScheme);
      case 3:
        return _buildEarningsTab(colorScheme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTournamentsTab(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tournaments Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
              ),
              DropdownButton<SportType?>(
                value: _selectedSportFilter,
                hint: Text('All Sports', style: TextStyle(color: colorScheme.primary)),
                dropdownColor: colorScheme.surface,
                items: [
                  const DropdownMenuItem<SportType?>(
                    value: null,
                    child: Text('All Sports'),
                  ),
                  ...SportType.values.map((s) => DropdownMenuItem<SportType?>(
                        value: s,
                        child: Text(s.name.toUpperCase()),
                      )),
                ],
                onChanged: (val) {
                  setState(() => _selectedSportFilter = val);
                  context.read<TournamentBloc>().add(LoadTournamentsEvent(filterSport: val));
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: BlocConsumer<TournamentBloc, TournamentState>(
              listener: (context, state) {
                if (state is TournamentSuccessState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: colorScheme.primary),
                  );
                }
              },
              builder: (context, state) {
                if (state is TournamentLoadingState) {
                  return Center(child: CircularProgressIndicator(color: colorScheme.primary));
                } else if (state is TournamentLoadedState) {
                  if (state.tournaments.isEmpty) {
                    return const Center(
                      child: Text('No tournaments found. Tap + to create one!'),
                    );
                  }
                  return ListView.builder(
                    itemCount: state.tournaments.length,
                    itemBuilder: (context, index) {
                      final t = state.tournaments[index];
                      return GlassContainer(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        borderRadius: 20,
                        backgroundColor: colorScheme.surfaceContainer,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    t.name,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: colorScheme.primary),
                                  ),
                                  child: Text(
                                    t.status,
                                    style: TextStyle(color: colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('${t.sportType.name.toUpperCase()} • ${t.category} • ${t.totalTeams} Teams',
                                style: TextStyle(color: colorScheme.onSurfaceVariant)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Entry: \$${t.entryFee.toInt()}', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                                Text('Prize Pool: \$${t.prizePool.toInt()}',
                                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text('Initialize Tournaments...'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTab(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Match Monitor Across Grounds',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                GlassContainer(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  backgroundColor: colorScheme.surfaceContainer,
                  borderColor: colorScheme.error,
                  hasGlow: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.fiber_manual_record, color: colorScheme.error, size: 12),
                              const SizedBox(width: 6),
                              Text('LIVE NOW • Ground 1', style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text('Overs 14.2/20', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('🏏 Royal Strikers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('142/3', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('⚡ Thunderbolts', style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant)),
                          Text('Yet to Bat', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroundsTab(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Turf & Ground Slot Listings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                GlassContainer(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('National Stadium Pitch 1', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Full Pitch • Night Floodlights', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$45/hr', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Available', style: TextStyle(color: colorScheme.secondary, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                GlassContainer(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sporto Arena Turf A', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('Box Cricket Turf • High Impact Net', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$30/hr', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Booked', style: TextStyle(color: colorScheme.error, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsTab(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Financial Revenue Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const SizedBox(height: 12),
          GlassContainer(
            padding: const EdgeInsets.all(20),
            hasGlow: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Tournament Collections', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text('\$7,500.00', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                const SizedBox(height: 8),
                Text('Active Tournaments Revenue: \$5,000 | Ground Bookings: \$2,500',
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
