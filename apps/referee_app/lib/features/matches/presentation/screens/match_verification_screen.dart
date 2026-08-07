import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ui_kit/ui_kit.dart';
import '../../../../app/router/app_router.dart';

// ============================================================
// MATCH VERIFICATION SCREEN
// ============================================================
class MatchVerificationScreen extends StatefulWidget {
  const MatchVerificationScreen({super.key});

  @override
  State<MatchVerificationScreen> createState() =>
      _MatchVerificationScreenState();
}

class _MatchVerificationScreenState extends State<MatchVerificationScreen> {
  // Checklist State
  bool _team1Verified = true;
  bool _team2Verified = true;
  bool _tossDone = false;

  // Team Presence State (true = Present, false = Absent)
  bool _team1Present = true;
  bool _team2Present = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Match Verification',
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface)),
            Text('Match #SPT-20481',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Match Header Card ---
            SportoCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SportoBadge(
                            text: 'Quarter Final',
                            color: cs.secondary,
                            outlined: true),
                        Text('Today, 06:30 PM',
                            style: TextStyle(
                                color: cs.onSurfaceVariant, fontSize: 12)),
                        SportoBadge(text: 'Upcoming', color: Colors.orange),
                      ]),
                  const SizedBox(height: 12),
                  Text('Asia Cup 2026',
                      style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.location_on_outlined,
                        size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('Hyderabad',
                        style:
                            TextStyle(color: cs.onSurfaceVariant, fontSize: 12))
                  ]),
                  const SizedBox(height: 16),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Delhi Warriors',
                            style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        Text('Vs',
                            style: TextStyle(
                                color: cs.onSurfaceVariant, fontSize: 12)),
                        Text('Hyd Highlanders',
                            style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ]),
                  const SizedBox(height: 16),
                  Container(
                      width: double.infinity,
                      height: 1,
                      color: SportoCard.defaultBorder),
                  const SizedBox(height: 12),
                  Center(
                    child: RichText(
                        text:
                            TextSpan(style: TextStyle(fontSize: 13), children: [
                      TextSpan(
                          text: 'Starts in ',
                          style: TextStyle(color: cs.onSurfaceVariant)),
                      TextSpan(
                          text: '24 mins',
                          style: TextStyle(
                              color: cs.secondary,
                              fontWeight: FontWeight.w700)),
                      TextSpan(
                          text: ' • at 06:30 PM',
                          style: TextStyle(color: cs.onSurfaceVariant)),
                    ])),
                  ),
                ])),
            const SizedBox(height: 24),

            // --- Team Verification Section ---
            Text('Team Verification',
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),

            // Team 1 Card
            SportoTeamVerificationCard(
              teamName: 'Team 1',
              subName: 'Delhi Warriors',
              players: [
                'Shrvn Prajapati (Captain)',
                'Amit Kumar',
                'Manish K',
                'Sumit Nai',
                'Mayank S'
              ],
              isPresent: _team1Present,
              onTogglePresent: () =>
                  setState(() => _team1Present = !_team1Present),
            ),
            const SizedBox(height: 16),

            // Team 2 Card
            SportoTeamVerificationCard(
              teamName: 'Team 2',
              subName: 'Hyd Highlanders',
              players: [
                'Vikram Reddy (Captain)',
                'Dev Kumar',
                'Pankaj S',
                'Rohan A',
                'Vinayak L'
              ],
              isPresent: _team2Present,
              onTogglePresent: () =>
                  setState(() => _team2Present = !_team2Present),
            ),
            const SizedBox(height: 24),

            // --- Final Checklist ---
            Text('Final Checklist',
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SportoCard(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(children: [
                  _ChecklistItem(
                      label: 'Team 1',
                      checked: _team1Verified,
                      onTap: () =>
                          setState(() => _team1Verified = !_team1Verified)),
                  _ChecklistItem(
                      label: 'Team 2',
                      checked: _team2Verified,
                      onTap: () =>
                          setState(() => _team2Verified = !_team2Verified)),
                  _ChecklistItem(
                      label: 'Toss',
                      checked: _tossDone,
                      onTap: () => setState(() => _tossDone = !_tossDone)),
                ])),
            const SizedBox(height: 32),

            // --- Ready To Toss Button ---
            PrimaryButton(
                width: double.infinity,
                height: 56,
                label: 'Ready To Toss',
                onPressed: () => context.push(AppRouter.conductTossRoute)),
          ],
        ),
      ),
    );
  }
}

// Reusable Checklist Item
class _ChecklistItem extends StatelessWidget {
  final String label;
  final bool checked;
  final VoidCallback onTap;

  const _ChecklistItem(
      {required this.label, required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: GestureDetector(
        onTap: onTap,
        child: SportoCheckBox(checked: checked),
      ),
      title: Text(label,
          style: TextStyle(
              color: checked ? cs.secondary : cs.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
