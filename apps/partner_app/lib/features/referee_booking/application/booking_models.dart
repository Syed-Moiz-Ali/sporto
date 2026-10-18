import 'package:equatable/equatable.dart';

/// Domain models for the referee-booking flow.
///
/// Kept local to the feature; the repository can be swapped for a real API
/// implementation without touching the screens or the bloc.

enum BookingStatus { upcoming, ongoing, completed }

/// A bookable sport.
class Sport extends Equatable {
  final String id;
  final String name;
  final String? iconAsset;

  const Sport({required this.id, required this.name, this.iconAsset});

  @override
  List<Object?> get props => [id, name, iconAsset];
}

/// A venue / game location.
class Location extends Equatable {
  final String id;
  final String venue;
  final String area;
  final double? distanceKm;

  const Location({
    required this.id,
    required this.venue,
    required this.area,
    this.distanceKm,
  });

  @override
  List<Object?> get props => [id, venue, area, distanceKm];
}

/// A referee available for booking.
class Referee extends Equatable {
  final String id;
  final String name;
  final String sport;
  final int level;
  final double rating;
  final int matches;
  final double pricePerMatch;
  final double? distanceKm;

  const Referee({
    required this.id,
    required this.name,
    required this.sport,
    required this.level,
    required this.rating,
    required this.matches,
    required this.pricePerMatch,
    this.distanceKm,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        sport,
        level,
        rating,
        matches,
        pricePerMatch,
        distanceKm,
      ];
}

/// A payment method.
class Payment extends Equatable {
  final String id;
  final String label;
  final bool selected;

  const Payment({required this.id, required this.label, this.selected = false});

  @override
  List<Object?> get props => [id, label, selected];
}

/// A submitted rating/review.
class Rating extends Equatable {
  final int stars;
  final List<String> tags;
  final String? review;

  const Rating({required this.stars, this.tags = const [], this.review});

  @override
  List<Object?> get props => [stars, tags, review];
}

/// A referee booking shown in lists / details.
class Booking extends Equatable {
  final String id;
  final BookingStatus status;
  final String refereeName;
  final String sport;
  final int level;
  final String durationLabel;
  final String dateLabel;
  final String timeLabel;
  final double price;

  const Booking({
    required this.id,
    required this.status,
    required this.refereeName,
    required this.sport,
    required this.level,
    required this.durationLabel,
    required this.dateLabel,
    required this.timeLabel,
    required this.price,
  });

  @override
  List<Object?> get props => [
        id,
        status,
        refereeName,
        sport,
        level,
        durationLabel,
        dateLabel,
        timeLabel,
        price,
      ];
}

/// Generic failure surfaced to the UI error state.
class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}
