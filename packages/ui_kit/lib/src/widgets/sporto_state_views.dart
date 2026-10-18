import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../theme/sporto_design_tokens.dart';
import '../theme/sporto_text_styles.dart';
import 'sporto_glass_surface.dart';
import 'sporto_shimmer.dart';

/// The four render states every data-driven widget must handle.
enum SportoUiStatus { loading, error, empty, data }

/// Builds the error UI. `retry` re-fires the original data call.
typedef SportoErrorBuilder = Widget Function(Object? error, VoidCallback? retry);

/// Centered error view: icon, headline, description and a retry button.
class SportoErrorView extends StatelessWidget {
  final IconData icon;
  final String headline;
  final String? description;
  final String retryLabel;
  final VoidCallback? onRetry;

  const SportoErrorView({
    super.key,
    this.icon = Icons.error_outline_rounded,
    this.headline = 'Something went wrong',
    this.description,
    this.retryLabel = 'Retry',
    this.onRetry,
  });

  /// No connectivity variant.
  const SportoErrorView.noInternet({super.key, this.onRetry, this.retryLabel = 'Retry'})
      : icon = Icons.wifi_off_rounded,
        headline = 'No internet connection',
        description = 'Check your connection and try again.';

  /// Server error variant.
  const SportoErrorView.server({super.key, this.onRetry, this.retryLabel = 'Retry'})
      : icon = Icons.cloud_off_rounded,
        headline = 'Server error',
        description = 'The server is unavailable right now. Please try again.';

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    return _StateScaffold(
      icon: icon,
      iconColor: tokens.live,
      headline: headline,
      description: description,
      action: onRetry == null
          ? null
          : _StateButton(label: retryLabel, onTap: onRetry!),
    );
  }
}

/// Centered empty view: icon, headline, description and an optional action.
class SportoEmptyView extends StatelessWidget {
  final IconData icon;
  final String headline;
  final String? description;
  final String? action;
  final VoidCallback? onAction;

  const SportoEmptyView({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.headline = 'Nothing here yet',
    this.description,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    return _StateScaffold(
      icon: icon,
      iconColor: tokens.muted,
      headline: headline,
      description: description,
      action: (action != null && onAction != null)
          ? _StateButton(label: action!, onTap: onAction!)
          : null,
    );
  }
}

class _StateScaffold extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String headline;
  final String? description;
  final Widget? action;

  const _StateScaffold({
    required this.icon,
    required this.iconColor,
    required this.headline,
    this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final gap = context.sportoLayout;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(gap.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: iconColor),
            SizedBox(height: gap.space16),
            Text(
              headline,
              textAlign: TextAlign.center,
              style: SportoTextStyles.text(
                size: SportoTextStyles.size16,
                weight: SportoTextStyles.semiBold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (description != null) ...[
              SizedBox(height: gap.space8),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: SportoTextStyles.text(
                  size: SportoTextStyles.size13,
                  weight: SportoTextStyles.medium,
                  color: tokens.muted,
                  height: 1.4,
                ),
              ),
            ],
            if (action != null) ...[
              SizedBox(height: gap.space20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class _StateButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _StateButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tokens = context.sporto;
    final layout = context.sportoLayout;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SportoGlassSurface(
        radius: layout.radius16,
        gradient: tokens.primaryGradient,
        shadows: layout.ctaGlow,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        child: Text(
          label,
          style: SportoTextStyles.text(
            size: SportoTextStyles.size15,
            weight: SportoTextStyles.semiBold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Generic, status-driven state wrapper. Screens pass the current [status]
/// plus the data/error and it renders the right view.
///
/// ```dart
/// AsyncStateView<List<Booking>>(
///   status: status,
///   data: bookings,
///   error: failure,
///   onRetry: () => context.read<BookingBloc>().add(const Load()),
///   skeleton: const SportoSkeletonList(itemCount: 3, itemBuilder: ...),
///   empty: const SportoEmptyView(headline: 'No bookings'),
///   builder: (items) => BookingList(items),
/// )
/// ```
class AsyncStateView<T> extends StatelessWidget {
  final SportoUiStatus status;
  final T? data;
  final Object? error;
  final Widget Function(T data) builder;
  final Widget? skeleton;
  final Widget? empty;
  final SportoErrorBuilder? errorBuilder;
  final VoidCallback? onRetry;

  const AsyncStateView({
    super.key,
    required this.status,
    required this.builder,
    this.data,
    this.error,
    this.skeleton,
    this.empty,
    this.errorBuilder,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case SportoUiStatus.loading:
        return skeleton ?? const SportoSkeletonCard(height: 120);
      case SportoUiStatus.error:
        return errorBuilder?.call(error, onRetry) ??
            SportoErrorView(onRetry: onRetry);
      case SportoUiStatus.empty:
        return empty ?? const SportoEmptyView();
      case SportoUiStatus.data:
        final value = data as T;
        return builder(value);
    }
  }
}

/// Bloc-aware state wrapper. Maps a Bloc state to a [SportoUiStatus] and the
/// data/error, then delegates to [AsyncStateView].
///
/// ```dart
/// SportoBlocStateView<BookingBloc, BookingState, List<Booking>>(
///   bloc: context.read<BookingBloc>(),
///   statusOf: (s) => s.isLoading ? SportoUiStatus.loading
///       : s.hasError ? SportoUiStatus.error
///       : s.items.isEmpty ? SportoUiStatus.empty : SportoUiStatus.data,
///   dataOf: (s) => s.items,
///   errorOf: (s) => s.error,
///   onRetry: () => context.read<BookingBloc>().add(const Load()),
///   skeleton: const BookingListSkeleton(),
///   builder: (items) => BookingList(items),
/// )
/// ```
class SportoBlocStateView<B extends StateStreamable<S>, S, T>
    extends StatelessWidget {
  final B bloc;
  final SportoUiStatus Function(S state) statusOf;
  final T? Function(S state) dataOf;
  final Object? Function(S state)? errorOf;
  final VoidCallback? onRetry;
  final Widget Function(T data) builder;
  final Widget? skeleton;
  final Widget? empty;
  final Widget Function(Object? error)? errorBuilder;

  const SportoBlocStateView({
    super.key,
    required this.bloc,
    required this.statusOf,
    required this.dataOf,
    required this.builder,
    this.errorOf,
    this.onRetry,
    this.skeleton,
    this.empty,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      bloc: bloc,
      builder: (context, state) {
        return AsyncStateView<T>(
          status: statusOf(state),
          data: dataOf(state),
          error: errorOf?.call(state),
          onRetry: onRetry,
          skeleton: skeleton,
          empty: empty,
          errorBuilder: errorBuilder == null
              ? null
              : (error, retry) => errorBuilder!(error),
          builder: builder,
        );
      },
    );
  }
}

/// Future-based variant for non-Bloc loads (`FutureBuilder` + [AsyncStateView]).
class SportoFutureStateView<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T data) builder;
  final Widget? skeleton;
  final Widget? empty;
  final SportoErrorBuilder? errorBuilder;
  final VoidCallback? onRetry;
  final bool Function(T data)? isEmpty;

  const SportoFutureStateView({
    super.key,
    required this.future,
    required this.builder,
    this.skeleton,
    this.empty,
    this.errorBuilder,
    this.onRetry,
    this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return skeleton ?? const SportoSkeletonCard(height: 120);
          default:
            if (snapshot.hasError) {
              return errorBuilder?.call(snapshot.error, onRetry) ??
                  SportoErrorView(onRetry: onRetry);
            }
            final data = snapshot.data;
            if (data == null || (isEmpty?.call(data) ?? false)) {
              return empty ?? const SportoEmptyView();
            }
            return builder(data);
        }
      },
    );
  }
}
