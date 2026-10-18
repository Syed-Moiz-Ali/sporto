import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../application/booking_bloc.dart';
import '../../application/booking_models.dart';

/// Screens 4-7 - the Game Location screen (Figma E1-04 -> E1-07).
///
/// ONE route (`/book-referee/location`) driven by [BookingState.locationStep]:
/// search -> detected -> venue -> bookingType.
class BookingLocationScreen extends StatelessWidget {
  const BookingLocationScreen({super.key});

  static const Location _detected = Location(
    id: 'current',
    venue: 'Kompally',
    area: 'Kompally, Hyderabad',
  );
  static const Location _venue = Location(
    id: 'venue',
    venue: 'KPHB Indoor Stadium',
    area: 'Kompally, Hyderabad',
  );

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    return MediaQuery.withNoTextScaling(
      child: Scaffold(
        backgroundColor: tokens.canvas,
        appBar: SportoBookingAppBar(
          title: 'Game Location',
          subtitle: 'Book A Referee',
          onBack: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        body: SafeArea(
          top: false,
          child: BlocBuilder<BookingBloc, BookingState>(
            builder: (context, state) {
              switch (state.locationStep) {
                case LocationStep.search:
                  return const _SearchState();
                case LocationStep.detected:
                  return _DetectedState(
                    location: state.selectedLocation ?? _detected,
                  );
                case LocationStep.venue:
                  return _VenueState(
                    location:
                        state.confirmedLocation ?? state.selectedLocation ?? _venue,
                  );
                case LocationStep.bookingType:
                  return _BookingTypeState(
                    sport: state.selectedSport?.name ?? 'Cricket',
                    location: state.confirmedLocation ?? state.selectedLocation ?? _venue,
                  );
              }
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// State 0 - search (E1-04)
// ---------------------------------------------------------------------------

class _SearchState extends StatelessWidget {
  const _SearchState();

  @override
  Widget build(BuildContext context) {
    final gap = context.sportoLayout;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, gap.space10, 20, gap.space20),
      children: [
        const _SportSummaryCard(),
        SizedBox(height: gap.space20),
        const _PromptAndFields(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// State 1 - detected (E1-05)
// ---------------------------------------------------------------------------

class _DetectedState extends StatelessWidget {
  final Location location;
  const _DetectedState({required this.location});

  @override
  Widget build(BuildContext context) {
    final gap = context.sportoLayout;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, gap.space10, 20, gap.space20),
      children: [
        const _SportSummaryCard(),
        SizedBox(height: gap.space20),
        const _PromptAndFields(),
        SizedBox(height: gap.space30),
        _GameLocationSection(
          label: 'Current Location',
          venue: null,
          area: location.area,
        ),
        SizedBox(height: gap.space30),
        Row(
          children: [
            SizedBox(
              width: 140,
              child: _Button(
                label: 'Change Location',
                color: context.sporto.border,
                onTap: () => context
                    .read<BookingBloc>()
                    .add(const BookingResetLocation()),
              ),
            ),
            SizedBox(width: gap.space14),
            SizedBox(
              width: 196,
              child: _Button(
                label: 'Confirm & Continue',
                gradient: context.sporto.primaryGradient,
                glow: true,
                onTap: () => context
                    .read<BookingBloc>()
                    .add(const BookingConfirmLocation()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// State 2 - venue (E1-06)
// ---------------------------------------------------------------------------

class _VenueState extends StatelessWidget {
  final Location location;
  const _VenueState({required this.location});

  @override
  Widget build(BuildContext context) {
    final gap = context.sportoLayout;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, gap.space10, 20, gap.space20),
      children: [
        const _SportSummaryCard(),
        SizedBox(height: gap.space20),
        const _PromptAndFields(),
        SizedBox(height: gap.space20),
        _GameLocationSection(
          label: 'Current Location',
          venue: location.venue,
          area: location.area,
        ),
        SizedBox(height: gap.space20),
        Center(
          child: SizedBox(
            width: 270,
            child: _Button(
              label: 'Confirm & Continue',
              gradient: context.sporto.primaryGradient,
              glow: true,
              onTap: () => context
                  .read<BookingBloc>()
                  .add(const BookingSelectBookingType()),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// State 3 - booking type (E1-07)
// ---------------------------------------------------------------------------

class _BookingTypeState extends StatelessWidget {
  final String sport;
  final Location location;
  const _BookingTypeState({required this.sport, required this.location});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final gap = context.sportoLayout;
    return ListView(
      padding: EdgeInsets.fromLTRB(20, gap.space10, 20, gap.space20),
      children: [
        _VenueHeaderCard(sport: sport, location: location),
        SizedBox(height: gap.space20),
        SportoGradientText(
          'How would you like to book?',
          gradient: tokens.gradientBlue,
          style: SportoTextStyles.text(
            size: SportoTextStyles.size14,
            weight: SportoTextStyles.semiBold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: gap.space20),
        _BookingModeCard(
          icon: const SportoSvgIcon(SportoRefereeBookingIcons.flashGreen, size: 20),
          title: 'Find Me a Referee',
          description:
              "Send your request to available referees nearby. SPOTO automatically finds a suitable match \u2014 you don't pick a specific referee.",
          bullets: const [
            'Faster booking',
            'Nearby, eligible referees',
            'First valid acceptance wins',
          ],
          cardGradient:
              _flatGradient(tokens.accentGreen.withValues(alpha: 0.06)),
          cardBorder: tokens.accentGreen.withValues(alpha: 0.2),
          buttonColor: tokens.accentGreen,
          buttonLabel: 'Quick Book',
          bulletIcon: SportoRefereeBookingIcons.checkGreen,
          onTap: () {
            context.read<BookingBloc>().add(const BookingChooseMode(BookingMode.quick));
            context.go('/book-referee/schedule');
          },
        ),
        SizedBox(height: gap.space20),
        _BookingModeCard(
          icon:
              const SportoSvgIcon(SportoRefereeBookingIcons.profileTwoUser, size: 20),
          title: 'Choose Your Referee',
          description:
              'Browse referee profiles and pick the one you want. Compare rating, experience, distance and price.',
          bullets: const [
            'Compare ratings & reviews',
            'See distance & pricing upfront',
            'Pick exactly who you want',
          ],
          // Figma: gradientBlue at 6% alpha, 20%-alpha gradient hairline.
          cardGradient: _alphaGradient(tokens.gradientBlue, 0.06),
          cardBorderGradient: _alphaGradient(tokens.gradientBlue, 0.2),
          cardBorder: null,
          buttonColor: null,
          buttonGradient: tokens.gradientBlue,
          buttonLabel: 'Browse Referees',
          bulletIcon: SportoRefereeBookingIcons.checkBlue,
          onTap: () {
            context.read<BookingBloc>().add(const BookingChooseMode(BookingMode.choose));
            context.go('/book-referee/referee');
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Shared pieces
// ---------------------------------------------------------------------------

class _SportSummaryCard extends StatelessWidget {
  const _SportSummaryCard();

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        final sport = state.selectedSport?.name ?? 'Cricket';
        final pink = LinearGradient(
          colors: tokens.gradientPink.colors
              .map((c) => c.withValues(alpha: 0.1))
              .toList(),
        );
        return SportoGlassSurface(
          radius: layout.radius16,
          gradient: pink,
          blur: layout.glassBlur,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Text(
                'Sport',
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size12,
                  weight: SportoTextStyles.medium,
                  color: tokens.muted,
                ),
              ),
              const Spacer(),
              const SportoSvgIcon(SportoRefereeBookingIcons.sport,
                  width: 17, height: 16),
              SizedBox(width: layout.space8),
              Text(
                sport,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size12,
                  weight: SportoTextStyles.bold,
                  color: tokens.accentGreen,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PromptAndFields extends StatelessWidget {
  const _PromptAndFields();

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final gap = context.sportoLayout;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SportoGradientText(
          'Where is your game?',
          gradient: tokens.gradientBlue,
          style: SportoTextStyles.text(
            size: SportoTextStyles.size14,
            weight: SportoTextStyles.semiBold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: gap.space10),
        Text(
          "The referee needs to know exactly where they're expected to report.",
          style: SportoTextStyles.text(
            size: SportoTextStyles.size14,
            weight: SportoTextStyles.regular,
            color: tokens.muted,
            height: 1.3,
          ),
        ),
        SizedBox(height: gap.space20),
        _Field(
          leading: const SportoSvgIcon(SportoRefereeBookingIcons.gps, size: 24),
          text: 'Use My Current Location',
          textColor: Theme.of(context).colorScheme.onSurface,
          onTap: () => context
              .read<BookingBloc>()
              .add(const BookingSelectLocation(BookingLocationScreen._detected)),
        ),
        SizedBox(height: gap.space20),
        Text(
          'Or search venue, area or address',
          style: SportoTextStyles.text(
            size: SportoTextStyles.size12,
            weight: SportoTextStyles.medium,
            color: tokens.muted,
          ),
        ),
        SizedBox(height: gap.space8),
        _Field(
          text: 'Search venue, area or address',
          textColor: tokens.muted,
          trailing: SportoSvgIcon(
            SportoRefereeBookingIcons.search,
            width: 19.5,
            height: 20,
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final Widget? leading;
  final String text;
  final Color textColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _Field({
    this.leading,
    required this.text,
    required this.textColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SportoGlassSurface(
        height: 48,
        radius: layout.radius14,
        blur: layout.glassBlur,
        color: tokens.cardElevated,
        borderGradient: SportoGlassBorders.white,
        padding: EdgeInsets.symmetric(
            horizontal: layout.space16, vertical: layout.space6),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              SizedBox(width: layout.space10),
            ],
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size14,
                  weight: SportoTextStyles.medium,
                  color: textColor,
                ),
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _GameLocationSection extends StatelessWidget {
  final String label;
  final String? venue;
  final String area;

  const _GameLocationSection({
    required this.label,
    required this.venue,
    required this.area,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Your Game Location',
          style: SportoTextStyles.text(
            size: SportoTextStyles.size14,
            weight: SportoTextStyles.medium,
            color: tokens.accentGreen,
          ),
        ),
        SizedBox(height: layout.space10),
        SportoGlassSurface(
          radius: layout.radius16,
          blur: layout.glassBlur,
          gradient: _flatGradient(tokens.accentGreen.withValues(alpha: 0.06)),
          borderColor: tokens.accentGreen.withValues(alpha: 0.2),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size15,
                  weight: SportoTextStyles.medium,
                  color: tokens.muted,
                ),
              ),
              SizedBox(height: layout.space4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SportoSvgIcon(SportoRefereeBookingIcons.pinGreen,
                      width: 11, height: 12),
                  SizedBox(width: layout.space4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (venue != null)
                          Text(
                            venue!,
                            style: SportoTextStyles.text(
                              size: SportoTextStyles.size18,
                              weight: SportoTextStyles.medium,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        Text(
                          area,
                          style: SportoTextStyles.text(
                            size: venue != null
                                ? SportoTextStyles.size18
                                : SportoTextStyles.size18,
                            weight: SportoTextStyles.medium,
                            color: venue != null ? tokens.muted : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: layout.space8),
        Text(
          'This is where your referee will be required to report.',
          style: SportoTextStyles.text(
            size: SportoTextStyles.size15,
            weight: SportoTextStyles.medium,
            color: tokens.muted,
          ),
        ),
      ],
    );
  }
}

class _VenueHeaderCard extends StatelessWidget {
  final String sport;
  final Location location;
  const _VenueHeaderCard({required this.sport, required this.location});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    final pink = LinearGradient(
      colors:
          tokens.gradientPink.colors.map((c) => c.withValues(alpha: 0.1)).toList(),
    );
    return SportoGlassSurface(
      radius: layout.radius20,
      gradient: pink,
      blur: layout.glassBlur,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const SportoSvgIcon(SportoRefereeBookingIcons.sport,
                  width: 17, height: 16),
              SizedBox(width: layout.space8),
              Text(
                sport,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size12,
                  weight: SportoTextStyles.bold,
                  color: tokens.accentGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: layout.space6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SportoSvgIcon(SportoRefereeBookingIcons.pinGreen,
                  width: 11, height: 12),
              SizedBox(width: layout.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      location.venue,
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size14,
                        weight: SportoTextStyles.medium,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      location.area,
                      style: SportoTextStyles.text(
                        size: SportoTextStyles.size12,
                        weight: SportoTextStyles.regular,
                        color: tokens.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingModeCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final String description;
  final List<String> bullets;
  final Gradient cardGradient;
  final Color? cardBorder;
  final Gradient? cardBorderGradient;
  final Color? buttonColor;
  final Gradient? buttonGradient;
  final String buttonLabel;
  final String bulletIcon;
  final VoidCallback onTap;

  const _BookingModeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.bullets,
    required this.cardGradient,
    required this.cardBorder,
    required this.buttonLabel,
    required this.bulletIcon,
    required this.onTap,
    this.cardBorderGradient,
    this.buttonColor,
    this.buttonGradient,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return SportoGlassSurface(
      radius: layout.radius20,
      gradient: cardGradient,
      blur: layout.glassBlur,
      borderColor: cardBorder,
      borderGradient: cardBorderGradient,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              icon,
              SizedBox(width: layout.space4),
              Expanded(
                child: Text(
                  title,
                  style: SportoTextStyles.text(
                    size: SportoTextStyles.size16,
                    weight: SportoTextStyles.semiBold,
                    color: onSurface,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: layout.space8),
          Text(
            description,
            style: SportoTextStyles.text(
              size: SportoTextStyles.size12,
              weight: SportoTextStyles.medium,
              color: tokens.muted,
              height: 1.5,
            ),
          ),
          SizedBox(height: layout.space12),
          for (final bullet in bullets) ...[
            Row(
              children: [
                SportoSvgIcon(bulletIcon, width: 8.7, height: 6),
                SizedBox(width: layout.space6),
                Expanded(
                  child: Text(
                    bullet,
                    style: SportoTextStyles.text(
                      size: SportoTextStyles.size11,
                      weight: SportoTextStyles.medium,
                      color: tokens.muted,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: layout.space4),
          ],
          SizedBox(height: layout.space12),
          Center(
            child: SizedBox(
              width: 270,
              height: 42,
              child: _Button(
                label: buttonLabel,
                color: buttonColor,
                gradient: buttonGradient,
                textColor: tokens.canvas,
                weight: SportoTextStyles.bold,
                onTap: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final String label;
  final Color? color;
  final Gradient? gradient;
  final bool glow;
  final Color? textColor;
  final FontWeight weight;
  final VoidCallback onTap;

  const _Button({
    required this.label,
    this.color,
    this.gradient,
    this.glow = false,
    this.textColor,
    this.weight = SportoTextStyles.semiBold,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final layout = context.sportoLayout;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 48,
        child: SportoGlassSurface(
          radius: layout.radius16,
          color: gradient == null ? color : null,
          gradient: gradient,
          shadows: glow ? layout.ctaGlow : null,
          child: Center(
            child: Text(
              label,
              style: SportoTextStyles.text(
                size: SportoTextStyles.size14,
                weight: weight,
                color: textColor ?? Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Applies [alpha] to every stop of [g] (used for the Figma 6%-alpha cards).
LinearGradient _alphaGradient(Gradient g, double alpha) {
  final lg = g is LinearGradient ? g : null;
  return LinearGradient(
    begin: lg?.begin ?? Alignment.topLeft,
    end: lg?.end ?? Alignment.bottomRight,
    colors: g.colors.map((c) => c.withValues(alpha: alpha)).toList(),
    stops: lg?.stops,
  );
}

/// Flat single-colour fill expressed as a gradient (Figma solid card fills).
LinearGradient _flatGradient(Color c) => LinearGradient(colors: [c, c]);

