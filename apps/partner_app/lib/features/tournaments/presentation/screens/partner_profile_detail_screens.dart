import 'package:flutter/material.dart';
import 'package:partner_data/partner_data.dart';
import 'package:ui_kit/ui_kit.dart';

const _profileGold = Color(0xFFFFB600);
const _profileGreen = Color(0xFF20C783);
const _profileBlue = Color(0xFF57C8F5);
const _profileMuted = Color(0xFFA19DA5);

class _ProfileDetailShell extends StatelessWidget {
  const _ProfileDetailShell({
    required this.title,
    required this.child,
    this.trailing,
    this.showBack = true,
  });

  final String title;
  final Widget child;
  final Widget? trailing;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: child,
    );

    return SportoScreenShell(
      body: MediaQuery.withNoTextScaling(
        child: SafeArea(
          child: SportoResponsiveContent(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SizedBox(
                  height: 64,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        if (showBack)
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.chevron_left_rounded),
                            iconSize: 26,
                            color: Colors.white,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints.tightFor(
                                width: 36, height: 36),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF262B31),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 36),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (trailing != null) trailing!,
                      ],
                    ),
                  ),
                ),
                Expanded(child: content),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PartnerEditProfileScreen extends StatefulWidget {
  const PartnerEditProfileScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.mobile,
  });
  final String firstName;
  final String lastName;
  final String mobile;

  @override
  State<PartnerEditProfileScreen> createState() =>
      _PartnerEditProfileScreenState();
}

class _PartnerEditProfileScreenState extends State<PartnerEditProfileScreen> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.firstName);
    _lastName = TextEditingController(text: widget.lastName);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileDetailShell(
      title: 'Edit Profile',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SportoTextField(
            label: 'First Name',
            hint: 'Enter your first name',
            controller: _firstName,
            height: 48,
          ),
          const SizedBox(height: 20),
          SportoTextField(
            label: 'Last Name',
            hint: 'Enter your last name',
            controller: _lastName,
            height: 48,
          ),
          const SizedBox(height: 20),
          SportoTextField(
            label: 'Mobile Number',
            hint: widget.mobile.isEmpty
                ? 'Verified mobile number'
                : widget.mobile,
            readOnly: true,
            height: 48,
            prefix: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('+91', style: TextStyle(color: _profileMuted)),
                Container(
                  width: 1,
                  height: 18,
                  margin: const EdgeInsets.only(left: 12),
                  color: const Color(0xFF4A4D53),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Verified via OTP - contact support to change your number.',
            style: TextStyle(color: _profileMuted, fontSize: 10),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            label: 'Save Changes',
            width: double.infinity,
            height: 48,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile changes saved.')),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class PartnerTournamentsHistoryScreen extends StatefulWidget {
  const PartnerTournamentsHistoryScreen({super.key, required this.tournaments});
  final List<PartnerTournamentResponse> tournaments;

  @override
  State<PartnerTournamentsHistoryScreen> createState() =>
      _PartnerTournamentsHistoryScreenState();
}

class _PartnerTournamentsHistoryScreenState
    extends State<PartnerTournamentsHistoryScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final items = widget.tournaments.isEmpty
        ? const [
            _TournamentViewData('Hitech City Super Over Cup', 41, 64, 3800),
            _TournamentViewData('Hitech City Super Over Cup', 41, 64, 3800),
          ]
        : widget.tournaments
            .map((item) => _TournamentViewData(
                  item.name,
                  item.registeredTeams ?? 0,
                  item.maximumTeams ?? 0,
                  3800,
                ))
            .toList();

    return _ProfileDetailShell(
      title: 'Tournaments History',
      showBack: false,
      trailing: SportoPillButton(
        label: '+ Create',
        color: _profileBlue,
        filled: true,
        foregroundColor: Colors.black,
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        fontSize: 11,
        onTap: () => Navigator.of(context).pop(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SportoFilterChip(
                label: 'Completed',
                active: _tab == 0,
                inactiveFill: true,
                onTap: () => setState(() => _tab = 0),
              ),
              const SizedBox(width: 8),
              SportoFilterChip(
                label: 'Cancelled',
                active: _tab == 1,
                inactiveFill: true,
                onTap: () => setState(() => _tab = 1),
              ),
              const Spacer(),
              const Icon(Icons.sort_rounded, color: Colors.white, size: 20),
            ],
          ),
          const SizedBox(height: 18),
          if (_tab == 1)
            const _EmptyState(
              icon: Icons.event_busy_outlined,
              title: 'No cancelled tournaments',
              subtitle: 'Cancelled tournaments will appear here.',
            )
          else
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _TournamentHistoryCard(item: item),
                )),
        ],
      ),
    );
  }
}

class _TournamentHistoryCard extends StatelessWidget {
  const _TournamentHistoryCard({required this.item});
  final _TournamentViewData item;

  @override
  Widget build(BuildContext context) => SportoCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              SportoBadge(text: 'Local', color: _profileGreen, radius: 12),
              Spacer(),
              SportoBadge(text: 'Approved', color: _profileGreen, radius: 12),
            ]),
            const SizedBox(height: 12),
            Text(item.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text('Hitech Box Cricket Arena  ·  Aug 5',
                style: TextStyle(color: _profileMuted, fontSize: 10)),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFF262B33), height: 1),
            const SizedBox(height: 9),
            Row(children: [
              Text('${item.teams}/${item.capacity}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              const Text(' Teams',
                  style: TextStyle(color: _profileMuted, fontSize: 11)),
              const Spacer(),
              Text('₹ ${item.earnings}',
                  style: const TextStyle(color: _profileGold, fontSize: 12)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              for (final label in const ['View', 'Manage', 'Earnings']) ...[
                Expanded(
                  child: Container(
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E1116),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(label,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ),
                if (label != 'Earnings') const SizedBox(width: 8),
              ],
            ]),
          ],
        ),
      );
}

class PartnerScoreScreen extends StatelessWidget {
  const PartnerScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const scores = [
      ('Tournament Quality', 94, _profileGreen),
      ('Play Satisfaction', 91, _profileGreen),
      ('Team Satisfaction', 89, _profileGold),
      ('Match Management', 96, _profileGreen),
      ('Referee Management', 88, _profileGold),
      ('Tournament Completion Rate', 93, _profileGreen),
    ];
    return _ProfileDetailShell(
      title: 'Partner Score',
      child: Column(
        children: [
          SportoCard(
            child: Column(
              children: const [
                Text.rich(TextSpan(children: [
                  TextSpan(
                      text: '80',
                      style: TextStyle(
                          color: _profileGold,
                          fontSize: 28,
                          fontWeight: FontWeight.w800)),
                  TextSpan(
                      text: '/100',
                      style: TextStyle(color: _profileMuted, fontSize: 16)),
                ])),
                SizedBox(height: 12),
                LinearProgressIndicator(
                    value: .80,
                    minHeight: 6,
                    backgroundColor: Color(0xFF243046),
                    color: _profileGold),
                SizedBox(height: 11),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: _profileGreen, size: 13),
                    SizedBox(width: 4),
                    Text('Excellent Standing - Top 15% of Spoto Partners',
                        style: TextStyle(color: _profileGreen, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...scores.map((score) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SportoCard(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(children: [
                    Row(children: [
                      Expanded(
                          child: Text(score.$1,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600))),
                      Text('${score.$2}%',
                          style: TextStyle(
                              color: score.$3,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                        value: score.$2 / 100,
                        minHeight: 4,
                        backgroundColor: const Color(0xFF243046),
                        color: score.$3),
                  ]),
                ),
              )),
        ],
      ),
    );
  }
}

class PartnerWalletScreen extends StatelessWidget {
  const PartnerWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ProfileDetailShell(
      title: 'Wallet',
      showBack: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BalanceCard(
            label: 'Available Balance',
            value: '₹ 3,800',
            action: 'Withdraw / Settlement',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const PartnerSettlementsScreen(),
            )),
          ),
          const SizedBox(height: 20),
          const Row(children: [
            Expanded(child: _WalletStat('₹ 98,600', 'Pending Settlement')),
            SizedBox(width: 12),
            Expanded(child: _WalletStat('₹ 8.40L', 'Total Earnings')),
          ]),
          const SizedBox(height: 12),
          const _WalletStat('₹ 43,600', 'Total Platform Fees'),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(
                child: SecondaryButton(
                    label: 'Transaction History',
                    height: 40,
                    radius: 14,
                    fontSize: 11,
                    onPressed: () {})),
            const SizedBox(width: 10),
            Expanded(
                child: SecondaryButton(
                    label: 'Download Statement',
                    icon: Icons.download_outlined,
                    iconSize: 15,
                    height: 40,
                    radius: 14,
                    fontSize: 11,
                    onPressed: () {})),
          ]),
          const SizedBox(height: 22),
          const Text('Recent Settlements',
              style: TextStyle(color: _profileMuted, fontSize: 13)),
          const SizedBox(height: 10),
          const _SettlementRow('Gachibowli Super Over Qualifier', 'Processing',
              '₹ 3,000', _profileGold),
          const SizedBox(height: 10),
          const _SettlementRow('Hyd Super Over Premier League', 'Processing',
              '₹ 95,600', _profileGold),
          const SizedBox(height: 10),
          const _SettlementRow(
              'Hitech City Super Over Cup', 'Paid', '₹ 3,800', _profileGreen),
        ],
      ),
    );
  }
}

class PartnerSettlementsScreen extends StatelessWidget {
  const PartnerSettlementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _ProfileDetailShell(
      title: 'Settlements & Transactions',
      child: Column(
        children: [
          _BalanceCard(
            label: 'Wallet balance',
            value: '₹ 1,20,400',
            action: 'Withdraw to bank',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const PartnerBankAccountScreen(),
            )),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xB329230F),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0x665C4700)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Settlement releases after prize dispersal',
                    style: TextStyle(color: Colors.white, fontSize: 11)),
                SizedBox(height: 6),
                Text(
                    'Spoto first disburses prize money to the winning team, then releases your partner settlement for that tournament. Your payout stays locked until winners are paid.',
                    style: TextStyle(
                        color: _profileMuted, fontSize: 9, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const _SettlementSummary(),
          const SizedBox(height: 14),
          const _SettlementPipeline(),
        ],
      ),
    );
  }
}

class PartnerBankAccountScreen extends StatefulWidget {
  const PartnerBankAccountScreen({super.key});

  @override
  State<PartnerBankAccountScreen> createState() =>
      _PartnerBankAccountScreenState();
}

class _PartnerBankAccountScreenState extends State<PartnerBankAccountScreen> {
  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileDetailShell(
      title: 'Bank Account',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SportoCard(
            child: Column(children: [
              Row(children: [
                Expanded(
                    child: Text('XXXX XXXX 4521',
                        style: TextStyle(color: Colors.white, fontSize: 15))),
                Icon(Icons.visibility_outlined, color: _profileMuted, size: 16),
                Spacer(),
                SportoBadge(
                    text: 'Verified',
                    color: _profileGreen,
                    icon: Icons.check_circle_outline_rounded,
                    radius: 12),
              ]),
              Divider(color: Color(0xFF252A31), height: 22),
              _BankLine('Bank', 'HDFC Bank'),
              SizedBox(height: 6),
              _BankLine('IFSC', 'HDFC0001234'),
              SizedBox(height: 6),
              _BankLine('Account holder', 'Rajesh Kumar'),
              SizedBox(height: 6),
              _BankLine('UPI ID', 'turfenergy@okhdfcbank'),
            ]),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                child: SecondaryButton(
                    label: 'Add Bank Account',
                    icon: Icons.add_rounded,
                    iconSize: 15,
                    height: 40,
                    radius: 14,
                    fontSize: 11,
                    onPressed: () {})),
            const SizedBox(width: 12),
            Expanded(
                child: SecondaryButton(
                    label: 'Change Bank Account',
                    icon: Icons.check_circle_outline_rounded,
                    iconSize: 15,
                    height: 40,
                    radius: 14,
                    fontSize: 11,
                    onPressed: () {})),
          ]),
          const SizedBox(height: 12),
          SecondaryButton(
              label: 'Re-verify Bank Account',
              icon: Icons.check_circle_outline_rounded,
              iconSize: 15,
              height: 40,
              radius: 14,
              fontSize: 11,
              onPressed: () => _message('Bank re-verification started.')),
          const SizedBox(height: 14),
          const Text(
              'Your 50% revenue share and prize settlements are paid to this account. Changing it requires re-verification.',
              style:
                  TextStyle(color: _profileMuted, fontSize: 11, height: 1.45)),
        ],
      ),
    );
  }
}

class PartnerVerificationScreen extends StatefulWidget {
  const PartnerVerificationScreen({super.key});

  @override
  State<PartnerVerificationScreen> createState() =>
      _PartnerVerificationScreenState();
}

class _PartnerVerificationScreenState extends State<PartnerVerificationScreen> {
  bool _businessUploaded = false;

  @override
  Widget build(BuildContext context) {
    const documents = [
      'PAN Card',
      'Aadhaar / Identity Proof',
      'Business Registration',
      'Address Proof',
      'Bank Verification',
    ];
    return _ProfileDetailShell(
      title: 'Verification & Documents',
      showBack: false,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xA8211C0F),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0x665C4700)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, color: _profileGold, size: 16),
                    SizedBox(width: 6),
                    Text('KYC In Progress',
                        style: TextStyle(color: _profileGold, fontSize: 14)),
                  ],
                ),
                SizedBox(height: 5),
                Text('One or more documents are still under review.',
                    style: TextStyle(color: _profileMuted, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...documents.map((document) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DocumentRow(document, verified: true),
              )),
          _DocumentRow(
            'Business Registration',
            verified: _businessUploaded,
            onUpload: () => setState(() => _businessUploaded = true),
          ),
        ],
      ),
    );
  }
}

class PartnerAccountSettingsScreen extends StatelessWidget {
  const PartnerAccountSettingsScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.mobile,
  });
  final String firstName;
  final String lastName;
  final String mobile;

  @override
  Widget build(BuildContext context) {
    void notice(String text) => ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$text settings opened.')));
    return _ProfileDetailShell(
      title: 'Account Settings',
      child: Column(
        children: [
          _SettingsRow(
            icon: Icons.person_outline,
            label: 'Edit Profile',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => PartnerEditProfileScreen(
                firstName: firstName,
                lastName: lastName,
                mobile: mobile,
              ),
            )),
          ),
          const SizedBox(height: 10),
          _SettingsRow(
              icon: Icons.business_outlined,
              label: 'Business Details',
              suffix: '(GST/PAN)',
              onTap: () => notice('Business details')),
          const SizedBox(height: 10),
          _SettingsRow(
              icon: Icons.location_on_outlined,
              label: 'Address Details',
              onTap: () => notice('Address')),
          const SizedBox(height: 20),
          _SettingsRow(
              icon: Icons.language_rounded,
              label: 'Language -',
              suffix: 'English',
              suffixColor: _profileBlue,
              onTap: () => notice('Language')),
          const SizedBox(height: 10),
          _SettingsRow(
              icon: Icons.currency_rupee_rounded,
              label: 'Currency',
              suffix: '(INR ₹)',
              onTap: () => notice('Currency')),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard(
      {required this.label,
      required this.value,
      required this.action,
      required this.onTap});
  final String label;
  final String value;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFB718),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(children: [
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.black, fontSize: 11)),
              const SizedBox(height: 7),
              Text(value,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
            ],
          )),
          SportoPillButton(
            label: action,
            color: const Color(0x1A000000),
            filled: true,
            bordered: false,
            foregroundColor: Colors.black,
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            fontSize: 11,
            onTap: onTap,
          ),
        ]),
      );
}

class _WalletStat extends StatelessWidget {
  const _WalletStat(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        height: 66,
        decoration: BoxDecoration(
          color: const Color(0xFF1C2026),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF29303A)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _profileMuted, fontSize: 10)),
        ]),
      );
}

class _SettlementRow extends StatelessWidget {
  const _SettlementRow(this.name, this.status, this.amount, this.color);
  final String name;
  final String status;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) => SportoCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(name,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
                const SizedBox(height: 3),
                Text(status, style: TextStyle(color: color, fontSize: 10)),
              ])),
          Text(amount, style: TextStyle(color: color, fontSize: 12)),
        ]),
      );
}

class _SettlementSummary extends StatelessWidget {
  const _SettlementSummary();

  @override
  Widget build(BuildContext context) => const SportoCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Settlement',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 12),
          _MoneyLine('Registration collection', '₹3,84,000'),
          SizedBox(height: 8),
          _MoneyLine('Prize money → winners', '-₹2,50,000'),
          SizedBox(height: 8),
          _MoneyLine('Platform fee (10%)', '-₹38,400'),
          Divider(color: Color(0xFF29303A), height: 18),
          _MoneyLine('Your settlement', '₹95,600',
              valueColor: _profileGreen, strong: true),
        ]),
      );
}

class _SettlementPipeline extends StatelessWidget {
  const _SettlementPipeline();

  @override
  Widget build(BuildContext context) => const SportoCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Settlement Pipeline',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 20),
          _PipelineTournament(
              'Hyderabad Super Cup',
              'Prize disbursed to winners',
              '₹15,000 awaiting payout',
              'Partner settlement locked',
              '₹3,000 until prize dispersal completes'),
          SizedBox(height: 22),
          _PipelineTournament(
              'Telangana Super Over Premier League',
              'Prize disbursed to winners',
              '₹250,000 paid out',
              'Partner settlement ready to release',
              '₹3,000 until prize dispersal completes',
              ready: true),
          SizedBox(height: 22),
          _PipelineTournament(
              'Hitech City Super Over Cup',
              'Prize disbursed to winners',
              '₹25,000 paid out',
              'Partner settlement released',
              '₹3,800 credited to wallet'),
        ]),
      );
}

class _PipelineTournament extends StatelessWidget {
  const _PipelineTournament(
      this.name, this.first, this.firstNote, this.second, this.secondNote,
      {this.ready = false});
  final String name;
  final String first;
  final String firstNote;
  final String second;
  final String secondNote;
  final bool ready;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
        const SizedBox(height: 12),
        _PipelineLine(first, firstNote),
        const SizedBox(height: 13),
        _PipelineLine(second, secondNote,
            color: ready ? _profileGold : Colors.white),
      ]);
}

class _PipelineLine extends StatelessWidget {
  const _PipelineLine(this.label, this.note, {this.color = _profileMuted});
  final String label;
  final String note;
  final Color color;

  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Color(0xFF283247))),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: color, fontSize: 12)),
          const SizedBox(height: 2),
          Text(note, style: const TextStyle(color: _profileMuted, fontSize: 9)),
        ])),
      ]);
}

class _MoneyLine extends StatelessWidget {
  const _MoneyLine(this.label, this.value,
      {this.valueColor = Colors.white, this.strong = false});
  final String label;
  final String value;
  final Color valueColor;
  final bool strong;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: Text(label,
                style: TextStyle(
                    color: strong ? Colors.white : _profileMuted,
                    fontSize: 12))),
        Text(value,
            style: TextStyle(
                color: valueColor,
                fontSize: 12,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w400)),
      ]);
}

class _BankLine extends StatelessWidget {
  const _BankLine(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(color: _profileMuted, fontSize: 11))),
        Text(value, style: const TextStyle(color: _profileMuted, fontSize: 11)),
      ]);
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow(this.label, {required this.verified, this.onUpload});
  final String label;
  final bool verified;
  final VoidCallback? onUpload;

  @override
  Widget build(BuildContext context) => SportoCard(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        child: Row(children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500))),
          if (verified)
            const SportoBadge(
                text: 'Verified',
                color: _profileGreen,
                icon: Icons.check_circle_outline_rounded,
                radius: 12)
          else
            SportoPillButton(
              label: 'Upload',
              color: _profileGold,
              filled: true,
              foregroundColor: Colors.black,
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              fontSize: 11,
              onTap: onUpload ?? () {},
            ),
        ]),
      );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.suffix,
      this.suffixColor});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? suffix;
  final Color? suffixColor;

  @override
  Widget build(BuildContext context) => SportoCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: _profileGreen.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: const Color(0xFF697078), size: 18)),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
          if (suffix != null) ...[
            const SizedBox(width: 4),
            Flexible(
                child: Text(suffix!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: suffixColor ?? _profileMuted, fontSize: 12))),
          ],
          const Spacer(),
          const Icon(Icons.chevron_right_rounded,
              color: _profileBlue, size: 18),
        ]),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Center(
            child: Column(children: [
          Icon(icon, color: _profileMuted, size: 42),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Text(subtitle,
              style: const TextStyle(color: _profileMuted, fontSize: 11)),
        ])),
      );
}

class _TournamentViewData {
  const _TournamentViewData(
      this.name, this.teams, this.capacity, this.earnings);
  final String name;
  final int teams;
  final int capacity;
  final int earnings;
}
