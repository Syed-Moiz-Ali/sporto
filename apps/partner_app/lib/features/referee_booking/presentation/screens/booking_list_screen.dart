import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../application/booking_bloc.dart';
import '../../application/booking_models.dart';
import '../widgets/booking_tile.dart';

/// Screen 1 - Booking list (Figma `01_Referees`).
class BookingListScreen extends StatelessWidget {
  const BookingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withNoTextScaling(
      child: Scaffold(
        backgroundColor: context.sporto.canvas,
        appBar: SportoBookingAppBar(
          title: 'Book A Referee',
          subtitle: 'Certified officials for your next match.',
          onBack: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        body: SportoBlocStateView<BookingBloc, BookingState, List<Booking>>(
          bloc: context.read<BookingBloc>(),
          statusOf: (s) => s.isLoading
              ? SportoUiStatus.loading
              : s.hasError
                  ? SportoUiStatus.error
                  : s.bookings.isEmpty
                      ? SportoUiStatus.empty
                      : SportoUiStatus.data,
          dataOf: (s) => s.bookings,
          errorOf: (s) => s.error,
          onRetry: () => context.read<BookingBloc>().add(const BookingRetry()),
          skeleton: const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: SportoSkeletonList(
              itemCount: 3,
              itemBuilder: _bookingSkeleton,
            ),
          ),
          empty: SportoEmptyView(
            headline: 'No referee bookings yet',
            action: 'Book Now',
            onAction: () => context.go('/book-referee/sport'),
          ),
          builder: (bookings) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => BookingTile(
              booking: bookings[i],
              onTap: () => context.go('/bookings/${bookings[i].id}'),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _bookingSkeleton(BuildContext context) => const BookingListItemSkeleton();
